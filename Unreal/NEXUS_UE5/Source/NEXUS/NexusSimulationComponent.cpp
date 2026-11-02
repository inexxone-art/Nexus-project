#include "NexusSimulationComponent.h"
#include "Net/UnrealNetwork.h"

UNexusSimulationComponent::UNexusSimulationComponent()
{
    PrimaryComponentTick.bCanEverTick=false;
    SetIsReplicatedByDefault(true);
}
void UNexusSimulationComponent::InitializeWorld()
{
    if(!GetOwner() || !GetOwner()->HasAuthority() || !Sectors.IsEmpty())return;
    const FName Regions[]={
      TEXT("adlerklamm"),TEXT("aurelia"),TEXT("stahlhafen"),
      TEXT("silberkueste"),TEXT("bergstadt"),TEXT("ignis_prime"),
      TEXT("sahra_ix"),TEXT("nivora"),TEXT("vesper"),TEXT("umbra"),
      TEXT("terra_nova")
    };
    for(const FName Region:Regions)
    {
        FNexusSectorMemory State;State.Sector=Region;
        if(Region==TEXT("ignis_prime"))State.WeatherSeverity=85;
        if(Region==TEXT("sahra_ix"))State.WeatherSeverity=65;
        Sectors.Add(State);
    }
}
FNexusSectorMemory* UNexusSimulationComponent::FindSectorMutable(FName Name)
{
    for(FNexusSectorMemory& S:Sectors) if(S.Sector==Name)return &S;
    return nullptr;
}
void UNexusSimulationComponent::SetRoadDamage(FName Sector,int32 Damage)
{
    if(!GetOwner() || !GetOwner()->HasAuthority())return;
    if(auto* S=FindSectorMutable(Sector))
    {
        S->BridgeIntegrity=FMath::Clamp(S->BridgeIntegrity-FMath::Max(Damage,0),0,100);
        if(S->BridgeIntegrity<25)
        {
            S->BlockedRoads=1;
            S->TradeSupply=FMath::Clamp(S->TradeSupply-30,0,100);
            S->MedicalStock=FMath::Clamp(S->MedicalStock-15,0,100);
            S->Safety=FMath::Clamp(S->Safety-20,0,100);
            S->PowerPercent=FMath::Clamp(S->PowerPercent-8,0,100);
        }
    }
}
void UNexusSimulationComponent::SetBridgeRepaired(FName Sector)
{
    if(!GetOwner() || !GetOwner()->HasAuthority())return;
    if(auto* S=FindSectorMutable(Sector))
    {
        S->BridgeIntegrity=100;
        S->BlockedRoads=0;
        S->TradeSupply=FMath::Clamp(S->TradeSupply+30,0,100);
        S->MedicalStock=FMath::Clamp(S->MedicalStock+15,0,100);
        S->Safety=FMath::Clamp(S->Safety+20,0,100);
        S->PowerPercent=FMath::Clamp(S->PowerPercent+8,0,100);
        S->RescueReputation+=3;
        S->RebuildEffort+=1;
    }
}
void UNexusSimulationComponent::RecordRescue(FName CitizenId,FName Sector)
{
    if(!GetOwner() || !GetOwner()->HasAuthority())return;
    FNexusCitizenMemory* Memory=nullptr;
    for(auto& Citizen:Citizens)
        if(Citizen.CitizenId==CitizenId){Memory=&Citizen;break;}
    if(!Memory)
    {
        FNexusCitizenMemory NewCitizen;NewCitizen.CitizenId=CitizenId;
        Citizens.Add(NewCitizen);
        Memory=&Citizens.Last();
    }
    Memory->RescuedTimes++;
    Memory->Trust=FMath::Clamp(Memory->Trust+35,-100,100);
    if(auto* S=FindSectorMutable(Sector))
    {
        S->RescueReputation++;
        S->Safety=FMath::Clamp(S->Safety+5,0,100);
    }
}
FName UNexusSimulationComponent::EvaluateIncident(FName Sector,int32 TeamSize)
{
    if(!GetOwner() || !GetOwner()->HasAuthority())return NAME_None;
    auto* S=FindSectorMutable(Sector);
    if(!S)return NAME_None;
    // Deterministic, state-dependent incident chosen once per sector/day,
    // rather than a stream of arbitrary, repeated random missions.
    for(const auto& Previous:EventHistory)
        if(Previous.GameDay==GameDay && Previous.Sector==Sector)return NAME_None;
    FName Candidate=NAME_None;
    if(S->BlockedRoads>0 && S->MedicalStock<90)
        Candidate=TEXT("medical_supply_emergency");
    else if(S->PowerPercent<65)
        Candidate=TEXT("power_grid_blackout");
    else if(S->WeatherSeverity>=80 && S->Safety<90)
        Candidate=TEXT("weather_evacuation");
    else if(S->TradeSupply<70)
        Candidate=TEXT("trade_convoy_shortage");
    else
    {
        FRandomStream Rng(WorldSeed+GameDay*7919+int32(GetTypeHash(Sector))+(TeamSize*103));
        if(Rng.RandRange(0,99)<12)
            Candidate=TeamSize>1?TEXT("coop_rescue_patrol"):TEXT("scout_distress");
    }
    if(Candidate!=NAME_None)
    {
        FNexusIncidentMemory Incident;
        Incident.EventType=Candidate;
        Incident.Sector=Sector;
        Incident.GameDay=GameDay;
        EventHistory.Add(Incident);
    }
    return Candidate;
}
FString UNexusSimulationComponent::SectorReport(FName Sector) const
{
    for(const auto& S:Sectors) if(S.Sector==Sector)
        return FString::Printf(TEXT("%s | Route %d | Handel %d | Medizin %d | Energie %d | Sicherheit %d"),
            *Sector.ToString(),S.BridgeIntegrity,S.TradeSupply,S.MedicalStock,S.PowerPercent,S.Safety);
    return TEXT("Sektor nicht geladen.");
}
void UNexusSimulationComponent::Restore(const TArray<FNexusSectorMemory>& Regions,
    const TArray<FNexusCitizenMemory>& People,const TArray<FNexusIncidentMemory>& Events,int32 Day)
{
    if(!GetOwner() || !GetOwner()->HasAuthority())return;
    if(!Regions.IsEmpty())Sectors=Regions;
    Citizens=People;
    EventHistory=Events;
    GameDay=FMath::Max(1,Day);
}
void UNexusSimulationComponent::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const
{
    Super::GetLifetimeReplicatedProps(Out);
    DOREPLIFETIME(UNexusSimulationComponent,Sectors);
    DOREPLIFETIME(UNexusSimulationComponent,Citizens);
    DOREPLIFETIME(UNexusSimulationComponent,GameDay);
}
