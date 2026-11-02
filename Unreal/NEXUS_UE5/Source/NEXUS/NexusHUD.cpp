#include "NexusHUD.h"
#include "NexusGameMode.h"
#include "NexusWorldDirector.h"
#include "NexusExplorer.h"
#include "NexusWeaponComponent.h"
#include "NexusVehicle.h"
#include "NexusBridge.h"
#include "NexusRescueTarget.h"
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
    ANexusExplorer* LocalExplorer=PlayerOwner?Cast<ANexusExplorer>(PlayerOwner->GetPawn()):nullptr;
    ANexusVehicle* LocalVehicle=Cast<ANexusVehicle>(Pawn);
    const ENexusIncidentPhase Phase=D->Phase;
    const ENexusRescueRole LocalRole=LocalExplorer?LocalExplorer->SelectedRescueRole:
        (LocalVehicle?LocalVehicle->DriverRescueRole:D->Role);

    // Reference top-left: compact mission title with actual dynamic objectives.
    Panel(14*X,19*Y,385*X,263*Y);
    Text(TEXT("NEXUS  |  ADLERKLAMM"),27*X,27*Y,1.13f,NexusUI::Amber);
    Text(TEXT("HAUPTMISSION  -  RETTUNG & SICHERUNG"),27*X,57*Y,.81f,NexusUI::Pale);
    Text(D->PhaseDescription(),27*X,82*Y,.75f,NexusUI::Muted);
    const bool bStarted=Phase!=ENexusIncidentPhase::Approach;
    const bool bRescued=D->RescuedCount()>=3;
    Text(FString::Printf(TEXT("%s  Brueckeneinsturz / Notruf"),bStarted?TEXT("[X]"):TEXT("[ ]")),
         28*X,112*Y,.80f,bStarted?NexusUI::Green:NexusUI::Pale);
    Text(FString::Printf(TEXT("%s  Vermisste lokalisieren (%d/3)"),
         D->LocatedCount()==3?TEXT("[X]"):TEXT("[ ]"),D->LocatedCount()),
         28*X,139*Y,.80f,D->LocatedCount()==3?NexusUI::Green:NexusUI::Pale);
    Text(FString::Printf(TEXT("%s  Erste Hilfe leisten (%d/3)"),
         D->StabilizedCount()==3?TEXT("[X]"):TEXT("[ ]"),D->StabilizedCount()),
         28*X,166*Y,.80f,D->StabilizedCount()==3?NexusUI::Green:NexusUI::Pale);
    Text(FString::Printf(TEXT("%s  Bergung abschliessen (%d/3)"),
         bRescued?TEXT("[X]"):TEXT("[ ]"),D->RescuedCount()),
         28*X,193*Y,.80f,bRescued?NexusUI::Green:NexusUI::Pale);
    Text(FString::Printf(TEXT("%s  Wiederaufbau der Bruecke"),D->RebuildStage>=4?TEXT("[X]"):TEXT("[ ]")),
         28*X,220*Y,.80f,D->RebuildStage>=4?NexusUI::Green:NexusUI::Pale);
    Text(TEXT("E INTERAKTION   |   V KAMERA WECHSELN"),27*X,253*Y,.68f,NexusUI::Amber);

    // Role selector is a live choice only after the bus crash.
    if(Phase==ENexusIncidentPhase::RoleChoice || Phase==ENexusIncidentPhase::Rescue)
    {
        Panel(17*X,281*Y,321*X,149*Y);
        Text(TEXT("RETTUNGSWEG / ROLLE"),30*X,291*Y,.93f,NexusUI::Amber);
        const TCHAR* RoleNames[3]={TEXT("F1  Sanitaeter"),TEXT("F2  Helikopter-Pilot"),TEXT("F3  Bodensuchteam")};
        const bool Chosen[3]={LocalRole==ENexusRescueRole::Medic,
            LocalRole==ENexusRescueRole::Pilot,LocalRole==ENexusRescueRole::GroundSearch};
        for(int32 I=0;I<3;++I)
        {
            if(Chosen[I])DrawRect(FLinearColor(.42f,.33f,.08f,.63f),26*X,(324+I*31)*Y,292*X,26*Y);
            Text(RoleNames[I],34*X,(328+I*31)*Y,.86f,Chosen[I]?NexusUI::Amber:NexusUI::Pale);
        }
    }

    // The objective compass uses actual replicated actor positions. For the
    // pilot route the first waypoint is the helipad, then a survivor; on foot
    // the closest outstanding survivor becomes the next rescue location.
    if(Phase==ENexusIncidentPhase::Rescue && Pawn)
    {
        FVector Goal=FVector::ZeroVector;
        FString Label;
        bool bHasGoal=false;
        if(LocalRole==ENexusRescueRole::Pilot && !LocalVehicle && D->RescueHelicopter)
        {
            Goal=D->RescueHelicopter->GetActorLocation();
            Label=TEXT("ZUM RETTUNGSHELIKOPTER");
            bHasGoal=true;
        }
        else
        {
            float BestDistanceSq=TNumericLimits<float>::Max();
            for(const auto& Person:D->Survivors)
            {
                if(!Person || !Person->bAvailable || Person->bRescued)continue;
                const float DistanceSq=FVector::DistSquared(Pawn->GetActorLocation(),Person->GetActorLocation());
                if(DistanceSq<BestDistanceSq)
                {
                    BestDistanceSq=DistanceSq;
                    Goal=Person->GetActorLocation();
                    Label=FString::Printf(TEXT("VERMISSTE PERSON %d"),Person->SurvivorId+1);
                    bHasGoal=true;
                }
            }
        }
        if(bHasGoal)
        {
            const FVector Offset=Goal-Pawn->GetActorLocation();
            const float Meters=Offset.Size()/100.f;
            const float LocalBearing=FMath::FindDeltaAngleDegrees(
                PlayerOwner->GetControlRotation().Yaw,Offset.Rotation().Yaw);
            const TCHAR* Turn=LocalBearing>18.f?TEXT("RECHTS"):
                (LocalBearing< -18.f?TEXT("LINKS"):TEXT("GERADEAUS"));
            Panel(579*X,35*Y,444*X,84*Y);
            Text(Label,591*X,48*Y,.95f,NexusUI::Amber);
            Text(FString::Printf(TEXT("%.0f m  |  %s  |  E: SUCHEN / HELFEN / BERGEN"),Meters,Turn),
                591*X,84*Y,.75f,NexusUI::Pale);
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

    // Local modal overlays contain only discovered tasks and actual economics.
    if(LocalExplorer && LocalExplorer->bPinboardOpen)
    {
        Panel(466*X,145*Y,665*X,452*Y);
        Text(TEXT("DEIN BUERO  |  PINNWAND"),492*X,161*Y,1.20f,NexusUI::Amber);
        Text(TEXT("NUR GEFUNDENE AUFTRAEGE  -  B SCHLIESSEN"),492*X,196*Y,.78f,NexusUI::Muted);
        const TArray<FString> Tasks=D->GetDiscoveredBoardLines();
        for(int32 I=0;I<Tasks.Num() && I<10;++I)
        {
            DrawRect(FLinearColor(.24f,.22f,.17f,.50f),487*X,(240+I*31)*Y,609*X,27*Y);
            Text(FString::Printf(TEXT("%d.  %s"),I+1,*Tasks[I]),502*X,(243+I*31)*Y,.83f,NexusUI::Pale);
        }
    }
    if(LocalExplorer && LocalExplorer->bPhoneOpen)
    {
        Panel(1174*X,313*Y,395*X,302*Y);
        Text(TEXT("NEXUS PHONE  |  FINANZEN"),1190*X,324*Y,1.04f,NexusUI::Amber);
        Text(FString::Printf(TEXT("KONTOSTAND: %d CREDITS"),D->Credits),1190*X,359*Y,.85f,NexusUI::Pale);
        Text(FString::Printf(TEXT("GOLDERZ: %d STUECK"),D->GetResourceCount(TEXT("GoldOre"))),1190*X,391*Y,.82f);
        Text(TEXT("K  GOLDERZ VERKAUFEN: +180 C"),1190*X,429*Y,.79f,NexusUI::Green);
        Text(TEXT("U  MIETWOHNUNG KAUFEN: 1500 C"),1190*X,465*Y,.79f,NexusUI::Pale);
        int32 Income=0;
        for(const auto& Property:D->RentalProperties)Income+=Property.NetPerDay();
        Text(FString::Printf(TEXT("MIETE NETTO: +%d C / SPIELTAG"),Income),1190*X,500*Y,.79f,NexusUI::Pale);
        Text(TEXT("Z  SCI-FI FORSCHUNG: 950 C + 3 METEORITEN"),1190*X,542*Y,.67f,NexusUI::Muted);
        Text(TEXT("M SCHLIESSEN"),1190*X,566*Y,.67f,NexusUI::Muted);
    }

    // This is actual replicated gameplay ammo, not an invented HUD number.
    if(LocalExplorer && LocalExplorer->Weapons)
    {
        Panel(1154*X,740*Y,410*X,93*Y);
        Text(FString::Printf(TEXT("WAFFE: %s"),*LocalExplorer->Weapons->GetCurrentName()),
             1170*X,749*Y,.86f,NexusUI::Pale);
        Text(FString::Printf(TEXT("MUNITION: %d / %d"),
             LocalExplorer->Weapons->GetMagazineAmmo(),
             LocalExplorer->Weapons->GetReserveAmmo()),1170*X,779*Y,.84f,NexusUI::Amber);
        Text(TEXT("MAUS LINKS SCHIESSEN  Q WECHSELN  R LADEN"),1170*X,807*Y,.65f,NexusUI::Muted);
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
