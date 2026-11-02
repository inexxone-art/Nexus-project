#include "NexusCampaignComponent.h"
#include "Dom/JsonObject.h"
#include "Serialization/JsonSerializer.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Net/UnrealNetwork.h"

UNexusCampaignComponent::UNexusCampaignComponent()
{
    PrimaryComponentTick.bCanEverTick=false;
    SetIsReplicatedByDefault(true);
}
bool UNexusCampaignComponent::LoadCampaignData()
{
    FString Source;
    if(!FFileHelper::LoadFileToString(Source,*(FPaths::ProjectContentDir()/TEXT("Data/nexus_campaign.json"))))
    {
        UE_LOG(LogTemp,Error,TEXT("NEXUS: campaign.json missing - story disabled"));
        return false;
    }
    TSharedPtr<FJsonObject> Root;
    TSharedRef<TJsonReader<>> Reader=TJsonReaderFactory<>::Create(Source);
    if(!FJsonSerializer::Deserialize(Reader,Root) || !Root.IsValid())return false;
    const TArray<TSharedPtr<FJsonValue>>* RawMissions=nullptr;
    if(!Root->TryGetArrayField(TEXT("missions"),RawMissions) || !RawMissions)return false;
    TArray<FNexusMissionDefinition> Parsed;
    for(const auto& Entry:*RawMissions)
    {
        if(!Entry.IsValid() || Entry->Type!=EJson::Object) return false;
        const auto Mission=Entry->AsObject();
        FNexusMissionDefinition Definition;
        if(!Mission->TryGetStringField(TEXT("id"),Definition.Id)
           || !Mission->TryGetStringField(TEXT("title"),Definition.Title)
           || !Mission->TryGetStringField(TEXT("region"),Definition.Region)
           || !Mission->TryGetStringField(TEXT("hook"),Definition.Hook))return false;
        const TArray<TSharedPtr<FJsonValue>>* Phases=nullptr;
        if(!Mission->TryGetArrayField(TEXT("phases"),Phases) || !Phases || Phases->Num()!=7)return false;
        for(const auto& Phase:*Phases)
        {
            if(!Phase.IsValid() || Phase->Type!=EJson::Object)return false;
            FString Stage,Action;
            if(!Phase->AsObject()->TryGetStringField(TEXT("id"),Stage)
               || !Phase->AsObject()->TryGetStringField(TEXT("objective_id"),Action))return false;
            FNexusObjective Objective;
            Objective.Stage=FName(*Stage);
            Objective.Action=FName(*Action);
            Definition.Stages.Add(Objective);
        }
        Parsed.Add(Definition);
    }
    if(Parsed.Num()!=18)return false;
    MissionCatalog=MoveTemp(Parsed);
    return true;
}
bool UNexusCampaignComponent::IsFinished() const {return CompletedChapters>=18;}
FString UNexusCampaignComponent::GetObjectiveText() const
{
    if(IsFinished())return TEXT("STORY: Alle 18 Kapitel abgeschlossen.");
    if(!MissionCatalog.IsValidIndex(ActiveMissionIndex))return TEXT("STORY: Keine Kapiteldaten geladen.");
    const FNexusMissionDefinition& Mission=MissionCatalog[ActiveMissionIndex];
    if(!Mission.Stages.IsValidIndex(ActivePhaseIndex))return TEXT("STORY: Missionsphase ungueltig.");
    const FNexusObjective& Stage=Mission.Stages[ActivePhaseIndex];
    return FString::Printf(TEXT("STORY %02d/18 - %s | %s: %s"),
        ActiveMissionIndex+1,*Mission.Title,*Stage.Stage.ToString(),*Stage.Action.ToString());
}
bool UNexusCampaignComponent::AdvancePhase()
{
    if(!MissionCatalog.IsValidIndex(ActiveMissionIndex))return false;
    ++ActivePhaseIndex;
    if(ActivePhaseIndex==7)
    {
        ++CompletedChapters;
        ActiveMissionIndex=FMath::Min(CompletedChapters,17);
        ActivePhaseIndex=0;
    }
    return true;
}
bool UNexusCampaignComponent::CompleteObjective(FName Action)
{
    if(!GetOwner() || !GetOwner()->HasAuthority() || IsFinished())return false;
    if(!MissionCatalog.IsValidIndex(ActiveMissionIndex))return false;
    const auto& Mission=MissionCatalog[ActiveMissionIndex];
    if(!Mission.Stages.IsValidIndex(ActivePhaseIndex))return false;
    const auto& Stage=Mission.Stages[ActivePhaseIndex];
    if(Stage.Stage==FName(TEXT("choice")))return false; // irreversible choice requires ResolveChoice.
    if(Stage.Action!=Action)return false; // no skipping stages, no fake story time
    return AdvancePhase();
}
bool UNexusCampaignComponent::ResolveChoice(FName Choice,FName RequiredObjective)
{
    if(!GetOwner() || !GetOwner()->HasAuthority() || IsFinished())return false;
    if(Choice!=FName(TEXT("protect_civilians")) && Choice!=FName(TEXT("secure_critical_data")))return false;
    if(!MissionCatalog.IsValidIndex(ActiveMissionIndex))return false;
    const auto& Stage=MissionCatalog[ActiveMissionIndex].Stages[ActivePhaseIndex];
    if(Stage.Stage!=FName(TEXT("choice")) || Stage.Action!=RequiredObjective)return false;
    DecisionJournal.Add(FString::Printf(TEXT("%s:%s"),
        *MissionCatalog[ActiveMissionIndex].Id,*Choice.ToString()));
    return AdvancePhase();
}
void UNexusCampaignComponent::Restore(int32 MissionIndex,int32 PhaseIndex,int32 Done,const TArray<FString>& Decisions)
{
    if(!GetOwner() || !GetOwner()->HasAuthority())return;
    CompletedChapters=FMath::Clamp(Done,0,18);
    ActiveMissionIndex=FMath::Clamp(MissionIndex,0,17);
    ActivePhaseIndex=FMath::Clamp(PhaseIndex,0,6);
    if(CompletedChapters<18 && ActiveMissionIndex<CompletedChapters)
        ActiveMissionIndex=CompletedChapters;
    DecisionJournal=Decisions;
}
void UNexusCampaignComponent::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const
{
    Super::GetLifetimeReplicatedProps(Out);
    DOREPLIFETIME(UNexusCampaignComponent,ActiveMissionIndex);
    DOREPLIFETIME(UNexusCampaignComponent,ActivePhaseIndex);
    DOREPLIFETIME(UNexusCampaignComponent,CompletedChapters);
}
