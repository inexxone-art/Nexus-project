#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "NexusAlpineRiver.generated.h"
class USceneComponent;
class UProceduralMeshComponent;

// Curved 3D river with 2-bank riverbed, current direction and animated
// surface vertex offsets. The production water shader is loaded if present.
UCLASS(Blueprintable)
class NEXUS_API ANexusAlpineRiver : public AActor
{
    GENERATED_BODY()
public:
    ANexusAlpineRiver();
    virtual void BeginPlay() override;
    virtual void Tick(float DeltaSeconds) override;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<USceneComponent> RiverRoot;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UProceduralMeshComponent> RiverSurface;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UProceduralMeshComponent> LeftShore;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UProceduralMeshComponent> RightShore;

    UPROPERTY(EditAnywhere,BlueprintReadWrite,Category="NEXUS|River") float HalfWidth=1150.f;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,Category="NEXUS|River") float BaseWaterHeight=-195.f;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,Category="NEXUS|River") int32 SegmentCount=80;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,Category="NEXUS|River") float FlowMetersPerSecond=3.2f;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,ReplicatedUsing=OnRep_Flood) float RainFloodLevel=0.f;
    UFUNCTION() void OnRep_Flood();
    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const override;
    UFUNCTION(BlueprintCallable) void GenerateRiver();
    UFUNCTION(BlueprintPure) FVector WaterFlowAt(const FVector& WorldLocation) const;
    UFUNCTION(BlueprintCallable) void SetFloodSeverity(int32 Severity);
private:
    FVector RiverCenterAt(float Alpha) const;
    void GenerateStrip(UProceduralMeshComponent* Target,float Inner,float Outer,float HeightOffset,bool bWater);
    float SurfaceTime=0.f;
};
