#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "NexusStarterHome.generated.h"

class USceneComponent;
class UStaticMeshComponent;
class UTextRenderComponent;

// First playable house blockout. Interior walkable, doorway open, office board.
// Real architecturally detailed mesh is loaded if imported; do not call this AAA.
UCLASS(Blueprintable)
class NEXUS_API ANexusStarterHome : public AActor
{
    GENERATED_BODY()
public:
    ANexusStarterHome();
    virtual void BeginPlay() override;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<USceneComponent> HouseRoot;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UTextRenderComponent> OfficeLabel;
    UPROPERTY(Transient) TArray<TObjectPtr<UStaticMeshComponent>> BuildingPieces;
    UFUNCTION(BlueprintPure) bool IsNearPinboard(FVector PlayerWorldPos) const;
    UFUNCTION(BlueprintPure) FVector StarterSpawnLocation() const;
    UFUNCTION(BlueprintPure) FVector PinboardLocation() const;
private:
    void Part(FName Name,FVector LocalPosition,FVector DimensionsCm,bool bSolid=true);
};
