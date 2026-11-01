#pragma once
#include "CoreMinimal.h"
#include "NexusTypes.generated.h"

UENUM(BlueprintType)
enum class ENexusRescueRole : uint8 { None, Medic, Pilot, GroundSearch };

UENUM(BlueprintType)
enum class ENexusIncidentPhase : uint8 { Approach, Collapse, RoleChoice, Rescue, Reconstruction, Complete };

UENUM(BlueprintType)
enum class ENexusIndustry : uint8 { Quarry, Smelter, OilPlatform, Refinery, CementPlant, AsphaltPlant };

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
