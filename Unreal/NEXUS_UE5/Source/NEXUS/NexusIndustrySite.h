#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "NexusTypes.h"
#include "NexusIndustrySite.generated.h"
class UStaticMeshComponent;
class UTextRenderComponent;

UCLASS(Blueprintable)
class NEXUS_API ANexusIndustrySite : public AActor
{
    GENERATED_BODY()
public:
    ANexusIndustrySite();
    UPROPERTY(VisibleAnywhere) TObjectPtr<UStaticMeshComponent> Building;
    UPROPERTY(VisibleAnywhere) TObjectPtr<UTextRenderComponent> Label;
    UPROPERTY(EditAnywhere, BlueprintReadWrite) ENexusIndustry Facility=ENexusIndustry::Quarry;
    UPROPERTY(BlueprintReadOnly) bool bConstructed=false;
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="NEXUS|AAA Art") TSoftObjectPtr<UStaticMesh> FacilityMesh;
    UPROPERTY(BlueprintReadOnly) float NextWorkTime=0.f;
    UFUNCTION(BlueprintCallable) void SetConstructed(bool Value);
    UFUNCTION(BlueprintCallable) bool IsReady(float Now) const { return Now>=NextWorkTime; }
    UFUNCTION(BlueprintCallable) void Cooldown(float Now) { NextWorkTime=Now+5.0f; }
};
