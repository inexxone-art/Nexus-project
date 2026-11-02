#pragma once
#include "CoreMinimal.h"
#include "NexusTypes.generated.h"

UENUM(BlueprintType)
enum class ENexusRescueRole : uint8 { None, Medic, Pilot, GroundSearch };

UENUM(BlueprintType)
enum class ENexusIncidentPhase : uint8 { Approach, Collapse, RoleChoice, Rescue, Reconstruction, Complete };

UENUM(BlueprintType)
enum class ENexusIndustry : uint8 { LoggingCamp, Quarry, Smelter, OilPlatform, Refinery, CementPlant, AsphaltPlant, GoldMine, Sawmill };

USTRUCT(BlueprintType)
struct FNexusResourceStock
{
    GENERATED_BODY()
    UPROPERTY(EditAnywhere, BlueprintReadWrite, SaveGame)
    TMap<FName, int32> Values;
    int32 Get(FName Key) const { return Values.FindRef(Key); }
    void Add(FName Key, int32 Amount) { Values.FindOrAdd(Key) = FMath::Max(0, Get(Key)+Amount); }
    bool CanSpend(const TMap<FName,int32>& Costs) const
    {
        for (const auto& Pair : Costs) if (Get(Pair.Key) < Pair.Value || Pair.Value < 0) return false;
        return true;
    }
    bool Spend(const TMap<FName,int32>& Costs)
    {
        if (!CanSpend(Costs)) return false;
        for (const auto& Pair : Costs) Add(Pair.Key,-Pair.Value);
        return true;
    }
};

USTRUCT(BlueprintType)
struct FNexusNetworkResource
{
    GENERATED_BODY()
    UPROPERTY(BlueprintReadOnly) FName Key;
    UPROPERTY(BlueprintReadOnly) int32 Amount=0;
};

USTRUCT(BlueprintType)
struct FNexusRentalProperty
{
    GENERATED_BODY()
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) FName PropertyId=NAME_None;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) int32 PurchasePrice=0;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) int32 GrossRentPerDay=0;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) int32 UpkeepPerDay=0;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,SaveGame) int32 LastPaidDay=1;
    int32 NetPerDay() const {return GrossRentPerDay-UpkeepPerDay;}
};
