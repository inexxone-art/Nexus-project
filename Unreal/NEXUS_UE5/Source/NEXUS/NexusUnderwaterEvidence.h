#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "NexusUnderwaterEvidence.generated.h"
class UStaticMeshComponent;
class UTextRenderComponent;
class UPointLightComponent;

// Salvageable recorder on the real meandering riverbed. Simple temporary
// GLB-ready prototype mesh, visible to all four co-op players.
UCLASS(Blueprintable)
class NEXUS_API ANexusUnderwaterEvidence : public AActor
{
    GENERATED_BODY()
public:
    ANexusUnderwaterEvidence();
    virtual void Tick(float DeltaSeconds) override;
    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const override;
    UPROPERTY(VisibleAnywhere) TObjectPtr<UStaticMeshComponent> RecorderMesh;
    UPROPERTY(VisibleAnywhere) TObjectPtr<UTextRenderComponent> BeaconLabel;
    UPROPERTY(VisibleAnywhere) TObjectPtr<UPointLightComponent> BeaconLight;
    UPROPERTY(BlueprintReadOnly,ReplicatedUsing=OnRep_SalvageState) bool bAvailable=false;
    UPROPERTY(BlueprintReadOnly,ReplicatedUsing=OnRep_SalvageState) bool bRecovered=false;

    UFUNCTION(BlueprintCallable) void SetAvailable(bool Available);
    UFUNCTION(BlueprintCallable) void Recover();
    UFUNCTION() void OnRep_SalvageState();
};
