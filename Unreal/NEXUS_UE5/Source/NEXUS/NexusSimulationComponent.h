#pragma once
#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "NexusSimulationComponent.generated.h"

USTRUCT(BlueprintType)
struct FNexusSectorMemory
{
    GENERATED_BODY()
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) FName Sector=TEXT("adlerklamm");
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) int32 BridgeIntegrity=100;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) int32 PowerPercent=100;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) int32 MedicalStock=100;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) int32 TradeSupply=100;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) int32 Safety=100;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) int32 WeatherSeverity=25;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) int32 RescueReputation=0;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) int32 BlockedRoads=0;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) int32 RebuildEffort=0;
};

USTRUCT(BlueprintType)
struct FNexusCitizenMemory
{
    GENERATED_BODY()
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) FName CitizenId;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) int32 Trust=0;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) int32 RescuedTimes=0;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) bool bPromisedHelp=false;
};

USTRUCT(BlueprintType)
struct FNexusIncidentMemory
{
    GENERATED_BODY()
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) FName EventType;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) FName Sector;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) int32 GameDay=0;
};

UCLASS(ClassGroup=(NEXUS),meta=(BlueprintSpawnableComponent))
class NEXUS_API UNexusSimulationComponent : public UActorComponent
{
    GENERATED_BODY()
public:
    UNexusSimulationComponent();
    UPROPERTY(BlueprintReadOnly,Replicated) TArray<FNexusSectorMemory> Sectors;
    UPROPERTY(BlueprintReadOnly,Replicated) TArray<FNexusCitizenMemory> Citizens;
    UPROPERTY(BlueprintReadOnly) TArray<FNexusIncidentMemory> EventHistory;
    UPROPERTY(EditAnywhere,BlueprintReadWrite) int32 WorldSeed=63027;
    UPROPERTY(BlueprintReadOnly,Replicated) int32 GameDay=1;
    UFUNCTION(BlueprintCallable) void InitializeWorld();
    UFUNCTION(BlueprintCallable) void SetRoadDamage(FName Sector,int32 Damage);
    UFUNCTION(BlueprintCallable) void SetBridgeRepaired(FName Sector);
    UFUNCTION(BlueprintCallable) void RecordRescue(FName CitizenId,FName Sector);
    UFUNCTION(BlueprintCallable) FName EvaluateIncident(FName Sector,int32 TeamSize);
    UFUNCTION(BlueprintPure) FString SectorReport(FName Sector) const;
    FNexusSectorMemory* FindSectorMutable(FName Name);
    void Restore(const TArray<FNexusSectorMemory>& Regions,
       const TArray<FNexusCitizenMemory>& People,const TArray<FNexusIncidentMemory>& Events,int32 Day);
    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Props) const override;
};
