#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Net/UnrealNetwork.h"
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
class ANexusCompanion;
class ANexusAlpineWeather;
class ANexusAlpineRiver;
class ANexusUnderwaterEvidence;
class ANexusStarterHome;
class ANexusCityDistrict;

UCLASS(Blueprintable)
class NEXUS_API ANexusWorldDirector : public AActor
{
    GENERATED_BODY()
public:
    ANexusWorldDirector();
    virtual void BeginPlay() override;
    virtual void Tick(float DeltaSeconds) override;
    UPROPERTY(BlueprintReadOnly,Replicated) TArray<FName> DiscoveredTopics;
    UPROPERTY(BlueprintReadOnly,Replicated) TArray<FNexusRentalProperty> RentalProperties;
    UPROPERTY(BlueprintReadOnly) TObjectPtr<ANexusStarterHome> StarterHome;
    UPROPERTY(BlueprintReadOnly) TObjectPtr<ANexusCityDistrict> CityDistrict;
    UPROPERTY(BlueprintReadOnly) TArray<TObjectPtr<ANexusVehicle>> Fleet;
    UFUNCTION(BlueprintCallable) TArray<FString> GetDiscoveredBoardLines() const;
    UFUNCTION(BlueprintCallable) bool SellGoldOre();
    UFUNCTION(BlueprintCallable) bool PurchaseRentalProperty();
    void UnlockTopic(FName Topic);
    void TeleportToStarterHome(ANexusExplorer* Explorer);
    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const override;
    UPROPERTY(BlueprintReadOnly,Replicated) TObjectPtr<ANexusAlpineWeather> Weather;
    UPROPERTY(BlueprintReadOnly,Replicated) TObjectPtr<ANexusAlpineRiver> River;
    UPROPERTY(BlueprintReadOnly,Replicated) TObjectPtr<ANexusUnderwaterEvidence> Evidence;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UNexusSimulationComponent> WorldMemory;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UNexusCampaignComponent> Story;
    UPROPERTY(BlueprintReadOnly) TArray<TObjectPtr<ANexusCompanion>> RescueHelpers;
    UPROPERTY(BlueprintReadOnly) TObjectPtr<ANexusBridge> Bridge;
    UPROPERTY(BlueprintReadOnly) TObjectPtr<ANexusBus> Bus;
    UPROPERTY(BlueprintReadOnly) TObjectPtr<ANexusVehicle> RescueTruck;
    UPROPERTY(BlueprintReadOnly) TObjectPtr<ANexusVehicle> RescueHelicopter;
    UPROPERTY(BlueprintReadOnly) TArray<TObjectPtr<ANexusRescueTarget>> Survivors;
    UPROPERTY(BlueprintReadOnly) TArray<TObjectPtr<ANexusIndustrySite>> Industry;
    UPROPERTY(BlueprintReadOnly) FNexusResourceStock Stock;
    UPROPERTY(BlueprintReadOnly,Replicated) TArray<FNexusNetworkResource> ReplicatedInventory;
    UFUNCTION(BlueprintPure) int32 GetResourceCount(FName Key) const;
    void PublishInventory();
    UPROPERTY(BlueprintReadOnly,Replicated) int32 Credits=3000;
    UPROPERTY(BlueprintReadOnly,Replicated) ENexusIncidentPhase Phase=ENexusIncidentPhase::Approach;
    UPROPERTY(BlueprintReadOnly,Replicated) ENexusRescueRole Role=ENexusRescueRole::None;
    UPROPERTY(BlueprintReadOnly,Replicated) int32 RebuildStage=0;
    UPROPERTY(BlueprintReadOnly) bool bPaidRescue=false;
    UPROPERTY(BlueprintReadOnly) bool bEnteredSpan=false;
    UPROPERTY(BlueprintReadOnly,Replicated) FString RadioMessage;
    void VehicleAdvanced(ANexusVehicle* Vehicle);
    void ChooseRescueRole(ENexusRescueRole NewRole);
    UFUNCTION(BlueprintCallable) void CommandRescueHelpers(int32 OrderCode);
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
    int32 PreviousClockMinutes=-1;
    void SettleRentAtMidnight();
    bool RescuePerson(ANexusRescueTarget* Person);
    bool HasCosts(const TMap<FName,int32>& Need) const;
    void Inform(const FString& Message);
    void CreateStageWorld();
    void CreateRescueTargets();
    void CreateFactories();
    void CreateFleet();
    void CreateSceneryBox(FVector Position,FVector Scale,FRotator Rotation,const TCHAR* Name);
};
