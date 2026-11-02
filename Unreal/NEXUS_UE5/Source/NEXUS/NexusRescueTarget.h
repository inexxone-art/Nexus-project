#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "NexusRescueTarget.generated.h"
class UCapsuleComponent;
class UStaticMeshComponent;
class UTextRenderComponent;

UCLASS(Blueprintable)
class NEXUS_API ANexusRescueTarget : public AActor
{
    GENERATED_BODY()
public:
    ANexusRescueTarget();
    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const override;

    UPROPERTY(VisibleAnywhere) TObjectPtr<UCapsuleComponent> Collider;
    UPROPERTY(VisibleAnywhere) TObjectPtr<UStaticMeshComponent> Body;
    UPROPERTY(VisibleAnywhere) TObjectPtr<UTextRenderComponent> DistressMarker;

    UPROPERTY(EditAnywhere,BlueprintReadWrite,Replicated) int32 SurvivorId=0;
    UPROPERTY(BlueprintReadOnly,ReplicatedUsing=OnRep_RescueState) bool bRescued=false;
    UPROPERTY(BlueprintReadOnly,ReplicatedUsing=OnRep_RescueState) bool bAvailable=false;
    UPROPERTY(BlueprintReadOnly,ReplicatedUsing=OnRep_RescueState) bool bLocated=false;
    UPROPERTY(BlueprintReadOnly,ReplicatedUsing=OnRep_RescueState) bool bStabilized=false;

    UFUNCTION(BlueprintCallable) void LocateSurvivor();
    UFUNCTION(BlueprintCallable) void StabilizeSurvivor();
    UFUNCTION(BlueprintCallable) void MarkRescued();
    UFUNCTION(BlueprintCallable) void SetAvailable(bool Available);
    UFUNCTION() void OnRep_RescueState();
};
