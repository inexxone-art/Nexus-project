#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "NexusAlpineRiver.generated.h"
class USceneComponent;
class UProceduralMeshComponent;

// Real cross-section: eroding outer cliff / deep fast current / shallower
// depositional inner sandbar. Dimensions and flows are gameplay prototypes.
UCLASS(Blueprintable)
class NEXUS_API ANexusAlpineRiver : public AActor
{
    GENERATED_BODY()
public:
    ANexusAlpineRiver();
    virtual void BeginPlay() override;
    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const override;

    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<USceneComponent> RiverRoot;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UProceduralMeshComponent> RiverSurface;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UProceduralMeshComponent> Riverbed;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UProceduralMeshComponent> LeftShore;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UProceduralMeshComponent> RightShore;

    UPROPERTY(EditAnywhere,BlueprintReadWrite,Category="NEXUS|Hydrology") float HalfWidth=1150.f;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,Category="NEXUS|Hydrology") float BaseWaterHeight=-195.f;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,Category="NEXUS|Hydrology",meta=(ClampMin="16",ClampMax="300")) int32 SegmentCount=96;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,Category="NEXUS|Hydrology") float FlowMetersPerSecond=3.2f;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,ReplicatedUsing=OnRep_Flood) float RainFloodLevel=0.f;

    UFUNCTION() void OnRep_Flood();
    UFUNCTION(BlueprintCallable) void GenerateRiver();
    UFUNCTION(BlueprintCallable) void SetFloodSeverity(int32 Severity);

    // Returns false beyond river banks. Surface, bed and lateral coordinate
    // refer to the ACTUAL curved stream, not a rectangular volume.
    UFUNCTION(BlueprintCallable,Category="NEXUS|Swimming")
    bool SampleWater(const FVector& Position,float& SurfaceZ,float& BedZ,
                     FVector& CurrentVelocity,float& LateralOffset) const;
    UFUNCTION(BlueprintPure,Category="NEXUS|Swimming")
    FVector WaterFlowAt(const FVector& WorldLocation) const;

private:
    FVector RiverCenterAt(float Alpha) const;
    FVector WaterNormalAt(float Alpha) const;
    float ErodingOuterSide(float Alpha) const;
    float BedDepthAt(float Alpha,float Lateral) const;
    FVector RiverPoint(float Alpha,float Lateral,float Z) const;
    void CreateGrid(UProceduralMeshComponent* Target,int32 Mode);
};
