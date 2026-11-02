#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "NexusTypes.h"
#include "NexusWorldDirector.generated.h"
class ANexusBridge;
class ANexusBus;
class ANexusVehicle;
class ANexusExplorer;
class ANexusRescueTarget;
class ANexusIndustrySite;
class UStaticMeshComponent;
class UNexusSimulationComponent;
class UNexusCampaignComponent;

UCLASS(Blueprintable)
class NEXUS_API ANexusWorldDirector : public AActor
{
    GENERATED_BODY()
public:
    ANexusWorldDirector();
    virtual void BeginPlay() override;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UNexusSimulationComponent> WorldMemory;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UNexusCampaignComponent> Story;
    UPROPERTY(BlueprintReadOnly) TObjectPtr<ANexusBridge> Bridge;
    UPROPERTY(BlueprintReadOnly) TObjectPtr<ANexusBus> Bus;
    UPROPERTY(BlueprintReadOnly) TObjectPtr<ANexusVehicle> RescueTruck;
    UPROPERTY(BlueprintReadOnly) TObjectPtr<ANexusVehicle> RescueHelicopter;
    UPROPERTY(BlueprintReadOnly) TArray<TObjectPtr<ANexusRescueTarget>> Survivors;
    UPROPERTY(BlueprintReadOnly) TArray<TObjectPtr<ANexusIndustrySite>> Industry;
    UPROPERTY(BlueprintReadOnly) FNexusResourceStock Stock;
    UPROPERTY(BlueprintReadOnly) int32 Credits=3000;
    UPROPERTY(BlueprintReadOnly) ENexusIncidentPhase Phase=ENexusIncidentPhase::Approach;
    UPROPERTY(BlueprintReadOnly) ENexusRescueRole Role=ENexusRescueRole::None;
    UPROPERTY(BlueprintReadOnly) int32 RebuildStage=0;
    UPROPERTY(BlueprintReadOnly) bool bPaidRescue=false;
    UPROPERTY(BlueprintReadOnly) bool bEnteredSpan=false;
    UPROPERTY(BlueprintReadOnly) FString RadioMessage;
    void VehicleAdvanced(ANexusVehicle* Vehicle);
    void ChooseRescueRole(ENexusRescueRole NewRole);
    UFUNCTION(BlueprintCallable) bool InvestigateEvidence(const FVector& Position);
    UFUNCTION(BlueprintCallable) bool ChooseCampaignOutcome(bool bProtectCivilians);
    bool TryInteract(ANexusExplorer* Explorer);
    bool TryVehicleRescue(ANexusVehicle* Vehicle);
    bool TryBuildOrOperate(ANexusIndustrySite* Site);
    bool TryReconstruct();
    void SaveProgress();
    void LoadProgress();
    void TeleportToApproach(ANexusExplorer* Explorer);
    FString PhaseDescription() const;
    FString ResourceDescription() const;
    int32 RescuedCount() const;
private:
    bool RescuePerson(ANexusRescueTarget* Person);
    bool HasCosts(const TMap<FName,int32>& Need) const;
    void Inform(const FString& Message);
    void CreateStageWorld();
    void CreateRescueTargets();
    void CreateFactories();
    void CreateLighting();
    void CreateSceneryBox(FVector Position,FVector Scale,FRotator Rotation,const TCHAR* Name);
};
