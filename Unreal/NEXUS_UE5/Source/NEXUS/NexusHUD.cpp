#include "NexusHUD.h"
#include "NexusGameMode.h"
#include "NexusWorldDirector.h"
#include "NexusExplorer.h"
#include "NexusCampaignComponent.h"
#include "NexusSimulationComponent.h"
#include "NexusAlpineWeather.h"
#include "NexusAlpineRiver.h"
#include "NexusUnderwaterEvidence.h"
#include "Engine/Canvas.h"
#include "Engine/Engine.h"
#include "EngineUtils.h"
#include "GameFramework/PlayerController.h"

void ANexusHUD::Panel(float X,float Y,float W,float H)
{
    DrawRect(FLinearColor(0.008f,0.018f,0.026f,0.86f),X,Y,W,H);
    DrawRect(FLinearColor(0.25f,0.32f,0.35f,0.75f),X,Y,W,2.f);
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
    ANexusGameMode* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>();
    const float X=Canvas->ClipX/1600.f,Y=Canvas->ClipY/900.f;
    Panel(15*X,55*Y,410*X,270*Y);
    Text(TEXT("NEXUS | ADLERKLAMM HAUPTMISSION"),28*X,67*Y,1.20f,FLinearColor(1.f,0.75f,0.16f,1.f));
    Text(D->PhaseDescription(),28*X,102*Y,0.85f);
    if(D->Weather)
        Text(D->Weather->WeatherReport(),28*X,238*Y,.84f,FLinearColor(.55f,.83f,1.f));
    if(D->Story)
        Text(D->Story->GetObjectiveText(),28*X,122*Y,0.65f,FLinearColor(0.86f,0.92f,0.81f));
    Text(FString::Printf(TEXT("[ ]  Ueberlebende finden (%d/3)"),D->RescuedCount()),28*X,143*Y,0.86f);
    Text(TEXT("[ ]  Medizinische Versorgung oder Bergung"),28*X,174*Y,0.82f);
    Text(TEXT("[ ]  Bruecke sichern / Wiederaufbau planen"),28*X,205*Y,0.82f);
    Text(TEXT("F1 SANITAETER  |  F2 PILOT  |  F3 SUCHTEAM"),28*X,271*Y,0.86f,FLinearColor(1.f,0.75f,0.16f,1.f));

    // Real-time swimming HUD for the owning player; it never shows another
    // co-op player's oxygen/underwater status.
    ANexusExplorer* LocalExplorer=PlayerOwner?Cast<ANexusExplorer>(PlayerOwner->GetPawn()):nullptr;
    if(LocalExplorer && LocalExplorer->bIsSwimming)
    {
        Panel(1080*X,330*Y,480*X,165*Y);
        Text(TEXT("SCHWIMMEN | ADLERKLAMM"),1100*X,349*Y,1.08f,
             FLinearColor(.55f,.85f,1.f));
        Text(FString::Printf(TEXT("STROEMUNG: %.1f m/s"),LocalExplorer->WaterSpeedMetersPerSecond),
             1100*X,379*Y,.92f);
        Text(FString::Printf(TEXT("ATEMLUFT: %.0f SEK. %s"),
             LocalExplorer->OxygenSeconds,
             LocalExplorer->bHeadUnderwater?TEXT("TAUCHEN"):TEXT("AN DER OBERFLAECHE")),
             1100*X,409*Y,.83f);
        DrawRect(FLinearColor(.09f,.16f,.23f,1.f),1100*X,441*Y,380*X,12*Y);
        DrawRect(LocalExplorer->OxygenSeconds<12.f?FLinearColor(.9f,.24f,.18f):
                 FLinearColor(.22f,.72f,.85f),
                 1100*X,441*Y,380*X*FMath::Clamp(LocalExplorer->OxygenSeconds/45.f,0.f,1.f),12*Y);
        if(D->Evidence && D->Evidence->bAvailable &&
           FVector::Dist(LocalExplorer->GetActorLocation(),D->Evidence->GetActorLocation())<800.f)
            Text(TEXT("SIGNAL: VERSUNKENE BLACKBOX  [E]"),1100*X,471*Y,.70f,
                 FLinearColor(.95f,.79f,.23f));
        else
            Text(TEXT("WASD SCHWIMMEN  SPACE AUF  STRG AB"),
                 1100*X,467*Y,.78f);
    }
    Panel(1110*X,50*Y,470*X,254*Y);
    Text(TEXT("ROHSTOFFE & WIRTSCHAFT"),1125*X,68*Y,1.2f,FLinearColor(1.f,0.75f,0.16f,1.f));
    Text(FString::Printf(TEXT("Holz: %d       Eisen: %d      Eisenerz: %d"),
        D->GetResourceCount(TEXT("Wood")),D->GetResourceCount(TEXT("Iron")),D->GetResourceCount(TEXT("IronOre"))),
        1125*X,118*Y,0.91f);
    Text(FString::Printf(TEXT("Zement: %d   Asphalt: %d"),
        D->GetResourceCount(TEXT("Cement")),D->GetResourceCount(TEXT("Asphalt"))),
        1125*X,159*Y,0.91f);
    Text(FString::Printf(TEXT("Rohoel: %d     Bitumen: %d     Diesel: %d"),
        D->GetResourceCount(TEXT("CrudeOil")),D->GetResourceCount(TEXT("Bitumen")),D->GetResourceCount(TEXT("Diesel"))),
        1125*X,199*Y,0.91f);
    Text(FString::Printf(TEXT("CREDITS: %d"),D->Credits),1125*X,245*Y,1.0f,FLinearColor(0.94f,0.9f,0.53f));

    Panel(1270*X,540*Y,305*X,185*Y);
    Text(TEXT("BRUECKE: WIEDERAUFBAU"),1285*X,559*Y,1.04f);
    const TCHAR* Steps[4]={TEXT("1. Schutt entfernen"),TEXT("2. Stahltraeger einsetzen"),TEXT("3. Beton und Zement"),TEXT("4. Asphalt / Freigabe")};
    for(int32 I=0;I<4;I++)
        Text(FString::Printf(TEXT("%s %s"),I<D->RebuildStage?TEXT("[X]"):TEXT("[ ]"),Steps[I]),
          1285*X,(604+I*27)*Y,0.78f,I<D->RebuildStage?FLinearColor(0.45f,0.94f,0.53f):FLinearColor::White);

    Panel(450*X,819*Y,700*X,69*Y);
    Text(TEXT("1 GEWEHR  |  2 PISTOLE  |  3 SANITAET  |  4 BAUWERKZEUG"),
        477*X,841*Y,0.95f);
    Text(TEXT("F6 SPURENSUCHE  F7 ZIVILISTEN  F8 BEWEISE"),455*X,805*Y,0.69f,FLinearColor(0.86f,0.85f,0.75f));
    Text(TEXT("WASD BEWEGEN/FAHREN  E INTERAKTION  F AUSSTEIGEN"),
        455*X,891*Y,0.73f,FLinearColor(0.86f,0.85f,0.75f));
    if(GM && GM->Explorer)
    {
        const int32 Slot=GM->Explorer->EquipmentSlot;
        Text(FString::Printf(TEXT("AKTIV: SLOT %d"),Slot+1),477*X,871*Y,0.75f,FLinearColor(1.f,0.75f,0.16f));
    }
    Panel(26*X,720*Y,392*X,90*Y);
    Text(TEXT("MISSION / NOTRUF"),40*X,732*Y,0.91f,FLinearColor(0.95f,0.74f,0.2f));
    Text(D->RadioMessage,40*X,764*Y,0.7f);
    if(D->WorldMemory)
        Text(D->WorldMemory->SectorReport(TEXT("adlerklamm")),40*X,791*Y,0.60f);
    DrawLine(Canvas->ClipX*0.5f-9,Canvas->ClipY*0.5f,Canvas->ClipX*0.5f+9,Canvas->ClipY*0.5f,FLinearColor::White,1.f);
    DrawLine(Canvas->ClipX*0.5f,Canvas->ClipY*0.5f-9,Canvas->ClipX*0.5f,Canvas->ClipY*0.5f+9,FLinearColor::White,1.f);
}
