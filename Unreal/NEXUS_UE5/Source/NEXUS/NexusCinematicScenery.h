#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "NexusCinematicScenery.generated.h"
class UHierarchicalInstancedStaticMeshComponent;
class USceneComponent;
// GPU-instanced landscape dressing for the Adlerklamm vertical slice.
// The meshes are REAL 3D assets imported to /Game/AAA/Geometry/Foliage,
// and must be upgraded to scanned Nanite hero assets for AAA approval.
UCLASS(Blueprintable)
class NEXUS_API ANexusCinematicScenery : public AActor
{
    GENERATED_BODY()
public:
    ANexusCinematicScenery();
    virtual void BeginPlay() override;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<USceneComponent> SceneryRoot;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UHierarchicalInstancedStaticMeshComponent> PineForestA;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UHierarchicalInstancedStaticMeshComponent> PineForestB;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UHierarchicalInstancedStaticMeshComponent> TalusBoulders;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UHierarchicalInstancedStaticMeshComponent> PhotoScannedRocks;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UHierarchicalInstancedStaticMeshComponent> AlpineShrubs;
    UPROPERTY(EditAnywhere,BlueprintReadWrite) int32 LandscapeSeed=18111;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,meta=(ClampMin="0",ClampMax="3000")) int32 TreeCount=800;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,meta=(ClampMin="0",ClampMax="2000")) int32 BoulderCount=440;
    UFUNCTION(BlueprintCallable) void PopulateLandscape();
private:
    bool LoadFoliageMesh(UHierarchicalInstancedStaticMeshComponent* Component,const TCHAR* Path);
    bool IsOnProtectedRoad(float X,float Y) const;
};
