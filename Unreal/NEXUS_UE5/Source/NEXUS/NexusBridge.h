#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "NexusBridge.generated.h"
class UStaticMeshComponent;
class USceneComponent;

UCLASS(Blueprintable)
class NEXUS_API ANexusBridge : public AActor
{
    GENERATED_BODY()
public:
    ANexusBridge();
    virtual void BeginPlay() override;
    UPROPERTY(EditDefaultsOnly,BlueprintReadWrite,Category="NEXUS|AAA Art")
    TSoftObjectPtr<UStaticMesh> NaniteBridgeSegment;
    UPROPERTY(VisibleAnywhere) TObjectPtr<USceneComponent> Base;
    UPROPERTY(BlueprintReadOnly) TArray<TObjectPtr<UStaticMeshComponent>> Segments;
    UPROPERTY(BlueprintReadOnly) bool bCollapsed=false;
    TArray<FTransform> OriginalLocalTransforms;
    void ReleaseSpan(int32 Index);
    // A real Niagara dust burst is shown on each peer if the authored asset exists.
    UFUNCTION(NetMulticast,Unreliable) void MulticastCollapseDust(FVector WorldLocation);
    UFUNCTION(BlueprintCallable) void Collapse();
    UFUNCTION(BlueprintCallable) void Reconstruct();
    UFUNCTION(BlueprintCallable) float GetBridgeHeight() const { return 1950.f; }
private:
    UStaticMesh* GetSegmentMesh() const;
};
