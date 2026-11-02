#pragma once
#include "CoreMinimal.h"
#include "GameFramework/GameModeBase.h"
#include "NexusGameMode.generated.h"
class ANexusWorldDirector;
class ANexusExplorer;
class ANexusVehicle;
class APlayerController;

UCLASS()
class NEXUS_API ANexusGameMode : public AGameModeBase
{
    GENERATED_BODY()
public:
    ANexusGameMode();
    virtual void StartPlay() override;
    virtual void PostLogin(APlayerController* NewPlayer) override;
    UPROPERTY(BlueprintReadOnly) TObjectPtr<ANexusWorldDirector> Director;
    UPROPERTY(BlueprintReadOnly) TObjectPtr<ANexusExplorer> Explorer;
    void Interact(ANexusExplorer* Player);
    bool InteractVehicle(ANexusVehicle* Vehicle);
    void ExitVehicle(ANexusVehicle* Vehicle);
    void ChooseRole(int32 Choice,APlayerController* Requester);
    void SaveProgress();
    void LoadProgress();
    void GoToApproach();
private:
    void EnterVehicle(ANexusVehicle* Vehicle, ANexusExplorer* Passenger);
    TMap<APlayerController*, ANexusExplorer*> SeatedFootPawns;
};
