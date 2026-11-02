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
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UStaticMeshComponent> PhysicsBody;
    UPROPERTY(EditDefaultsOnly,BlueprintReadWrite,Category="NEXUS|AAA Art")
    TSoftObjectPtr<UStaticMesh> HighPolyBus;
    UPROPERTY(BlueprintReadOnly) bool bReleased=false;
    UFUNCTION(BlueprintCallable) void DropBehindPlayer();
    UFUNCTION(BlueprintCallable) void ResetBus();
    virtual void BeginPlay() override;
private:
    FTransform InitialTransform;
};
