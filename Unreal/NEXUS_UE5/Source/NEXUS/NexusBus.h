#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "NexusBus.generated.h"
class UStaticMeshComponent;

UCLASS(Blueprintable)
class NEXUS_API ANexusBus : public AActor
{
    GENERATED_BODY()
public:
    ANexusBus();
    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const override;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UStaticMeshComponent> PhysicsBody;
    UPROPERTY(EditDefaultsOnly,BlueprintReadWrite,Category="NEXUS|AAA Art")
    TSoftObjectPtr<UStaticMesh> HighPolyBus;
    UPROPERTY(BlueprintReadOnly,Replicated) bool bReleased=false;
    // The bus follows the player's road vehicle at a believable distance.
    // Only the server advances traffic; built-in movement replication handles clients.
    void AdvanceConvoy(const FVector& LeadPosition,float DeltaSeconds);
    void PositionForBridgeImpact();
    UFUNCTION(BlueprintCallable) void DropBehindPlayer();
    UFUNCTION(BlueprintCallable) void ResetBus();
    virtual void BeginPlay() override;
private:
    FTransform InitialTransform;
};
