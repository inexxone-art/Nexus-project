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
    UPROPERTY(VisibleAnywhere) TObjectPtr<UCapsuleComponent> Collider;
    UPROPERTY(VisibleAnywhere) TObjectPtr<UStaticMeshComponent> Body;
    UPROPERTY(VisibleAnywhere) TObjectPtr<UTextRenderComponent> DistressMarker;
    UPROPERTY(EditAnywhere,BlueprintReadWrite) int32 SurvivorId=0;
    UPROPERTY(BlueprintReadOnly) bool bRescued=false;
    UFUNCTION(BlueprintCallable) void MarkRescued();
};
