#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "NexusPracticeTarget.generated.h"

class UStaticMeshComponent;
class UTextRenderComponent;

UCLASS(Blueprintable)
class NEXUS_API ANexusPracticeTarget : public AActor
{
    GENERATED_BODY()
public:
    ANexusPracticeTarget();
    virtual void BeginPlay() override;
    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const override;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UStaticMeshComponent> TargetVisual;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UTextRenderComponent> ScoreDisplay;
    UPROPERTY(BlueprintReadOnly,ReplicatedUsing=OnRep_Score) int32 Hits=0;
    UPROPERTY(BlueprintReadOnly,ReplicatedUsing=OnRep_Score) bool bTrainingCompleted=false;
    void ReceivePracticeHit(float ScorePoints);
    UFUNCTION() void OnRep_Score();
};
