#include "NexusHUD.h"
#include "NexusGameMode.h"
#include "NexusWorldDirector.h"
#include "NexusExplorer.h"
#include "NexusVehicle.h"
#include "NexusBridge.h"
#include "NexusCampaignComponent.h"
#include "NexusSimulationComponent.h"
#include "NexusAlpineWeather.h"
#include "NexusAlpineRiver.h"
#include "NexusUnderwaterEvidence.h"
#include "Engine/Canvas.h"
#include "Engine/Engine.h"
#include "EngineUtils.h"
#include "GameFramework/PlayerController.h"

// 1600x900 reference grid, scaled to the actual viewport. No gameplay numbers
// are fabricated: money, objectives, weather, rescue count and industry stock
// all come from the replicated game state.
namespace NexusUI {
const FLinearColor Amber(1.f,.76f,.19f,1.f);
const FLinearColor Pale(.91f,.94f,.94f,1.f);
const FLinearColor Muted(.64f,.73f,.74f,1.f);
const FLinearColor Green(.38f,.91f,.50f,1.f);
const FLinearColor Red(1.f,.39f,.33f,1.f);
}
void ANexusHUD::Panel(float X,float Y,float W,float H)
{
    DrawRect(FLinearColor(.011f,.019f,.029f,.80f),X,Y,W,H);
    DrawRect(FLinearColor(.44f,.48f,.45f,.56f),X,Y,W,1.1f);
    DrawRect(FLinearColor(.25f,.29f,.32f,.46f),X,Y+H-1.f,W,1.f);
}
void ANexusHUD::Text(const FString& Value,float X,float Y,float Scale,FLinearColor Tint)
{
    DrawText(Value,Tint,X,Y,GEngine?GEngine->GetSmallFont():nullptr,Scale,false);
}
void ANexusHUD::DrawHUD()
{
    Super::DrawHUD();
    if(!Canvas)return;
    ANexusWorldDirector* D=nullptr;
    for(TActorIterator<ANexusWorldDirector> It(GetWorld());It;++It){D=*It;break;}
    if(!D)return;
    const float X=Canvas->ClipX/1600.f,Y=Canvas->ClipY/900.f;
    APawn* Pawn=PlayerOwner?PlayerOwner->GetPawn():nullptr;
    ANexusExplorer* LocalExplorer=Cast<ANexusExplorer>(Pawn);
    ANexusVehicle* LocalVehicle=Cast<ANexusVehicle>(Pawn);
    const ENexusIncidentPhase Phase=D->Phase;

    // Reference top-left: compact mission title with actual dynamic objectives.
    Panel(14*X,19*Y,372*X,236*Y);
    Text(TEXT("NEXUS  |  ADLERKLAMM"),27*X,27*Y,1.13f,NexusUI::Amber);
    Text(TEXT("HAUPTMISSION  -  RETTUNG & SICHERUNG"),27*X,57*Y,.81f,NexusUI::Pale);
    Text(D->PhaseDescription(),27*X,82*Y,.75f,NexusUI::Muted);
    const bool bStarted=Phase!=ENexusIncidentPhase::Approach;
    const bool bRescued=D->RescuedCount()>=3;
    Text(FString::Printf(TEXT("%s  Brueckeneinsturz / Notruf"),bStarted?TEXT("[X]"):TEXT("[ ]")),
         28*X,112*Y,.80f,bStarted?NexusUI::Green:NexusUI::Pale);
    Text(FString::Printf(TEXT("%s  Ueberlebende lokalisieren (%d/3)"),
         bRescued?TEXT("[X]"):TEXT("[ ]"),D->RescuedCount()),
         28*X,139*Y,.80f,bRescued?NexusUI::Green:NexusUI::Pale);
    Text(FString::Printf(TEXT("%s  Medizinische Bergung abschliessen"),bRescued?TEXT("[X]"):TEXT("[ ]")),
         28*X,166*Y,.80f,bRescued?NexusUI::Green:NexusUI::Pale);
    Text(FString::Printf(TEXT("%s  Wiederaufbau der Bruecke"),D->RebuildStage>=4?TEXT("[X]"):TEXT("[ ]")),
         28*X,193*Y,.80f,D->RebuildStage>=4?NexusUI::Green:NexusUI::Pale);
    Text(TEXT("E INTERAKTION   |   V KAMERA WECHSELN"),27*X,226*Y,.68f,NexusUI::Amber);

    // Role selector is a live choice only after the bus crash.
    if(Phase==ENexusIncidentPhase::RoleChoice || Phase==ENexusIncidentPhase::Rescue)
    {
        Panel(17*X,281*Y,321*X,149*Y);
        Text(TEXT("RETTUNGSWEG / ROLLE"),30*X,291*Y,.93f,NexusUI::Amber);
        const TCHAR* RoleNames[3]={TEXT("F1  Sanitaeter"),TEXT("F2  Helikopter-Pilot"),TEXT("F3  Bodensuchteam")};
        const bool Chosen[3]={D->Role==ENexusRescueRole::Medic,
            D->Role==ENexusRescueRole::Pilot,D->Role==ENexusRescueRole::GroundSearch};
        for(int32 I=0;I<3;++I)
        {
            if(Chosen[I])DrawRect(FLinearColor(.42f,.33f,.08f,.63f),26*X,(324+I*31)*Y,292*X,26*Y);
            Text(RoleNames[I],34*X,(328+I*31)*Y,.86f,Chosen[I]?NexusUI::Amber:NexusUI::Pale);
        }
    }

    // Status ribbon and compact resource inventory, as in the supplied frame.
    if(D->Weather)
    {
        Text(FString::Printf(TEXT("TAG %d  |  %s"),
             D->WorldMemory?D->WorldMemory->GameDay:1,*D->Weather->WeatherReport()),
             1100*X,9*Y,.75f,NexusUI::Pale);
    }
    Panel(1310*X,36*Y,273*X,252*Y);
    Text(TEXT("ROHSTOFFE"),1322*X,45*Y,1.07f,NexusUI::Pale);
    const struct FResourceRow {const TCHAR* Name;const TCHAR* Key;} Resources[]={
        {TEXT("Holz"),TEXT("Wood")},{TEXT("Eisenerz"),TEXT("IronOre")},
        {TEXT("Eisen"),TEXT("Iron")},{TEXT("Zement"),TEXT("Cement")},
        {TEXT("Asphalt"),TEXT("Asphalt")},{TEXT("Rohoel"),TEXT("CrudeOil")},
        {TEXT("Diesel"),TEXT("Diesel")}};
    for(int32 I=0;I<7;++I)
    {
        const float YPos=(79+I*25)*Y;
        if(I%2==0)DrawRect(FLinearColor(.24f,.29f,.30f,.22f),1318*X,YPos-2*Y,251*X,24*Y);
        Text(Resources[I].Name,1327*X,YPos,.81f,NexusUI::Pale);
        Text(FString::Printf(TEXT("%d"),D->GetResourceCount(FName(Resources[I].Key))),
             1517*X,YPos,.84f,NexusUI::Pale);
    }
    Text(FString::Printf(TEXT("CREDITS %d"),D->Credits),1325*X,263*Y,.79f,NexusUI::Amber);

    // Lower-left tactical radar: world-space bridge bearing, not a fake map.
    const float CX=101.f*X,CY=763.f*Y,Radius=76.f;
    Panel(14*X,676*Y,174*X,174*Y);
    for(int32 I=0;I<48;++I)
    {
        const float A=I*2.f*PI/48.f,B=(I+1)*2.f*PI/48.f;
        DrawLine(CX+FMath::Cos(A)*Radius*X,CY+FMath::Sin(A)*Radius*Y,
                 CX+FMath::Cos(B)*Radius*X,CY+FMath::Sin(B)*Radius*Y,
                 FLinearColor(.64f,.76f,.70f,.76f),1.f);
    }
    DrawLine(CX-Radius*X,CY,CX+Radius*X,CY,FLinearColor(.39f,.57f,.50f,.47f),.8f);
    DrawLine(CX,CY-Radius*Y,CX,CY+Radius*Y,FLinearColor(.39f,.57f,.50f,.47f),.8f);
    Text(TEXT("N"),98*X,678*Y,.79f,NexusUI::Pale);
    Text(TEXT("S"),99*X,834*Y,.79f,NexusUI::Pale);
    Text(TEXT("W"),15*X,760*Y,.79f,NexusUI::Pale);
    Text(TEXT("E"),177*X,760*Y,.79f,NexusUI::Pale);
    DrawRect(NexusUI::Pale,CX-3*X,CY-3*Y,6*X,6*Y);
    if(Pawn && D->Bridge)
    {
        const FVector Bearing=D->Bridge->GetActorLocation()-Pawn->GetActorLocation();
        const float Yaw=PlayerOwner?PlayerOwner->GetControlRotation().Yaw:0.f;
        const float Theta=FMath::Atan2(Bearing.Y,Bearing.X)-FMath::DegreesToRadians(Yaw);
        const float Distance=FMath::Min(Bearing.Size2D()/15000.f,1.f);
        const float R=63.f*Distance;
        DrawRect(NexusUI::Amber,CX+(FMath::Cos(Theta)*R-4.f)*X,
                 CY+(FMath::Sin(Theta)*R-4.f)*Y,8*X,8*Y);
    }

    // Context-sensitive rebuild panel: never mark stages complete prematurely.
    if(Phase==ENexusIncidentPhase::Reconstruction || Phase==ENexusIncidentPhase::Complete)
    {
        Panel(1270*X,521*Y,314*X,201*Y);
        Text(TEXT("WIEDERAUFBAU - BRUECKE"),1284*X,532*Y,.90f,NexusUI::Pale);
        const TCHAR* Steps[4]={TEXT("Schutt entfernen"),TEXT("Stahltraeger montieren"),
            TEXT("Fahrbahn betonieren"),TEXT("Asphalt / Freigabe")};
        for(int32 I=0;I<4;++I)
        {
            const bool Ready=I<D->RebuildStage;
            Text(FString::Printf(TEXT("%s %s"),Ready?TEXT("[X]"):TEXT("[ ]"),Steps[I]),
                 1285*X,(569+I*31)*Y,.76f,Ready?NexusUI::Green:NexusUI::Muted);
            DrawRect(FLinearColor(.22f,.30f,.33f,.66f),1479*X,(573+I*31)*Y,78*X,9*Y);
            if(Ready)DrawRect(NexusUI::Green,1479*X,(573+I*31)*Y,78*X,9*Y);
        }
        Text(FString::Printf(TEXT("%d / 4 PHASEN"),D->RebuildStage),1285*X,703*Y,.71f,NexusUI::Amber);
    }

    // Quickbar with explicit active selection. No invented ammo/weapon counts.
    const float Cell=47.f;
    for(int32 I=0;I<4;++I)
    {
        const float Left=(697.f+(I-2)*54.f)*X;
        Panel(Left,817*Y,Cell*X,57*Y);
        const bool Active=LocalExplorer && LocalExplorer->EquipmentSlot==I;
        if(Active)DrawRect(NexusUI::Amber,Left,817*Y,Cell*X,3*Y);
        Text(FString::Printf(TEXT("%d"),I+1),Left+6*X,824*Y,.71f,
             Active?NexusUI::Amber:NexusUI::Muted);
        const TCHAR* Tools[4]={TEXT("Waffe"),TEXT("Pistole"),TEXT("Med"),TEXT("Bau")};
        Text(Tools[I],Left+5*X,848*Y,.73f,Active?NexusUI::Pale:NexusUI::Muted);
    }
    if(LocalExplorer)
        Text(LocalExplorer->bThirdPersonView?TEXT("3RD PERSON"):TEXT("EGO-PERSPEKTIVE"),
             687*X,889*Y,.67f,NexusUI::Muted);
    else if(LocalVehicle)
        Text(LocalVehicle->bCockpitView?TEXT("COCKPIT"):TEXT("FAHRZEUGKAMERA"),
             687*X,889*Y,.67f,NexusUI::Muted);
    Panel(195*X,775*Y,330*X,72*Y);
    Text(TEXT("FUNK / NOTRUF"),207*X,783*Y,.80f,NexusUI::Amber);
    Text(D->RadioMessage.Left(65),207*X,808*Y,.69f,NexusUI::Pale);

    // Real-time swimming HUD for the owning player only.
    if(LocalExplorer && LocalExplorer->bIsSwimming)
    {
        Panel(1090*X,340*Y,460*X,139*Y);
        Text(TEXT("SCHWIMMEN  |  ADLERKLAMM"),1100*X,349*Y,.96f,NexusUI::Amber);
        Text(FString::Printf(TEXT("STROEMUNG %.1f m/s   |   ATEMLUFT %.0f s"),
             LocalExplorer->WaterSpeedMetersPerSecond,LocalExplorer->OxygenSeconds),
             1100*X,379*Y,.80f);
        DrawRect(FLinearColor(.10f,.19f,.22f,1.f),1100*X,412*Y,412*X,12*Y);
        DrawRect(LocalExplorer->OxygenSeconds<12.f?NexusUI::Red:FLinearColor(.18f,.77f,.91f),
             1100*X,412*Y,412*X*FMath::Clamp(LocalExplorer->OxygenSeconds/
             FMath::Max(1.f,LocalExplorer->DiveDurationSeconds),0.f,1.f),12*Y);
        if(D->Evidence && D->Evidence->bAvailable &&
           FVector::Dist(LocalExplorer->GetActorLocation(),D->Evidence->GetActorLocation())<800.f)
            Text(TEXT("SIGNAL: VERSUNKENE BLACKBOX [E]"),1100*X,447*Y,.74f,NexusUI::Amber);
        else
            Text(TEXT("SPACE AUF  |  STRG AB"),1100*X,447*Y,.74f,NexusUI::Muted);
    }

    // Small crosshair, suppressed while piloting/driving.
    if(!LocalVehicle)
    {
        const float MX=Canvas->ClipX*.5f,MY=Canvas->ClipY*.5f;
        DrawLine(MX-9*X,MY,MX-3*X,MY,NexusUI::Pale,1.f);
        DrawLine(MX+3*X,MY,MX+9*X,MY,NexusUI::Pale,1.f);
        DrawLine(MX,MY-9*Y,MX,MY-3*Y,NexusUI::Pale,1.f);
        DrawLine(MX,MY+3*Y,MX,MY+9*Y,NexusUI::Pale,1.f);
    }
}
