#pragma once
#include "CoreMinimal.h"
#include "GameFramework/SaveGame.h"
#include "NexusTypes.h"
#include "NexusSaveGame.generated.h"

UCLASS()
class NEXUS_API UNexusSaveGame : public USaveGame
{
    GENERATED_BODY()
public:
    UPROPERTY(SaveGame) FNexusResourceStock Stock;
    UPROPERTY(SaveGame) TArray<ENexusIndustry> ConstructedSites;
    UPROPERTY(SaveGame) TArray<int32> RescuedIds;
    UPROPERTY(SaveGame) ENexusRescueRole Role = ENexusRescueRole::None;
    UPROPERTY(SaveGame) ENexusIncidentPhase Phase = ENexusIncidentPhase::Approach;
    UPROPERTY(SaveGame) int32 RebuildStage = 0;
    UPROPERTY(SaveGame) int32 Credits = 3000;
    UPROPERTY(SaveGame) bool bRewardPaid = false;
};
