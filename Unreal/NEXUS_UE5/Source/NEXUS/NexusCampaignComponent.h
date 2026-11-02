#pragma once
#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "NexusCampaignComponent.generated.h"

// Each phase is an objective with a verified gameplay action and one follow-up.
// The catalogue encodes 18 x 7 authored stages; NOT 48h of cinematics.
USTRUCT(BlueprintType)
struct FNexusObjective
{
    GENERATED_BODY()
    UPROPERTY(BlueprintReadOnly) FName Stage;
    UPROPERTY(BlueprintReadOnly) FName Action;
};
USTRUCT(BlueprintType)
struct FNexusMissionDefinition
{
    GENERATED_BODY()
    UPROPERTY(BlueprintReadOnly) FString Id;
    UPROPERTY(BlueprintReadOnly) FString Title;
    UPROPERTY(BlueprintReadOnly) FString Region;
    UPROPERTY(BlueprintReadOnly) FString Hook;
    UPROPERTY(BlueprintReadOnly) TArray<FNexusObjective> Stages;
};

UCLASS(ClassGroup=(NEXUS),meta=(BlueprintSpawnableComponent))
class NEXUS_API UNexusCampaignComponent : public UActorComponent
{
    GENERATED_BODY()
public:
    UNexusCampaignComponent();
    UPROPERTY(BlueprintReadOnly) TArray<FNexusMissionDefinition> MissionCatalog;
    UPROPERTY(BlueprintReadOnly,Replicated) int32 ActiveMissionIndex=0;
    UPROPERTY(BlueprintReadOnly,Replicated) int32 ActivePhaseIndex=0;
    UPROPERTY(BlueprintReadOnly,Replicated) int32 CompletedChapters=0;
    UPROPERTY(BlueprintReadOnly) TArray<FString> DecisionJournal;
    UFUNCTION(BlueprintCallable) bool LoadCampaignData();
    UFUNCTION(BlueprintCallable) bool CompleteObjective(FName Action);
    UFUNCTION(BlueprintCallable) bool ResolveChoice(FName Choice,FName RequiredObjective);
    UFUNCTION(BlueprintPure) FString GetObjectiveText() const;
    UFUNCTION(BlueprintPure) bool IsFinished() const;
    void Restore(int32 MissionIndex,int32 PhaseIndex,int32 Done,const TArray<FString>& Decisions);
    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const override;
private:
    bool AdvancePhase();
};
