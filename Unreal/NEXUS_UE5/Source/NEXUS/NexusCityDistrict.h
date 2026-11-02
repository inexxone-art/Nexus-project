#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "NexusCityDistrict.generated.h"

class USceneComponent;
class UStaticMeshComponent;
class UTextRenderComponent;

// 8 distinct enterable shell buildings: a district within the FIRST Earth map.
// Historical armored vehicles are deliberately not part of this actor.
UCLASS(Blueprintable)
class NEXUS_API ANexusCityDistrict : public AActor
{
    GENERATED_BODY()
public:
    ANexusCityDistrict();
    virtual void BeginPlay() override;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<USceneComponent> DistrictRoot;
    UPROPERTY(Transient,BlueprintReadOnly) TArray<TObjectPtr<UStaticMeshComponent>> Architecture;
private:
    void CreateFallbackBuilding(FString Name,FVector Position,int32 Width,int32 Depth,int32 Height);
    UStaticMeshComponent* MakePart(FString Name,FVector Center,FVector Extents);
};
