#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "NexusAlpineWeather.generated.h"

class USceneComponent;
class UDirectionalLightComponent;
class UExponentialHeightFogComponent;
class USkyLightComponent;
class UNiagaraComponent;

UENUM(BlueprintType)
enum class ENexusClimate : uint8 { Clear, Rain, Storm, Snow, Dust };

// Network-safe time-of-day and climate controller. It produces actual dynamic
// sunlight/fog/wetness; optional Niagara effects require real UE5 particle assets.
UCLASS(Blueprintable)
class NEXUS_API ANexusAlpineWeather : public AActor
{
    GENERATED_BODY()
public:
    ANexusAlpineWeather();
    virtual void BeginPlay() override;
    virtual void Tick(float DeltaSeconds) override;
    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const override;

    UPROPERTY(VisibleAnywhere) TObjectPtr<USceneComponent> WeatherRoot;
    UPROPERTY(VisibleAnywhere) TObjectPtr<UDirectionalLightComponent> Sun;
    UPROPERTY(VisibleAnywhere) TObjectPtr<UExponentialHeightFogComponent> Fog;
    UPROPERTY(VisibleAnywhere) TObjectPtr<USkyLightComponent> SkyAmbient;
    UPROPERTY(VisibleAnywhere) TObjectPtr<UNiagaraComponent> RainParticles;

    UPROPERTY(EditAnywhere,BlueprintReadWrite,ReplicatedUsing=OnRep_Climate) ENexusClimate Climate=ENexusClimate::Clear;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,ReplicatedUsing=OnRep_Climate) int32 Severity=15;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,ReplicatedUsing=OnRep_Climate) int32 MinuteOfDay=790;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,Category="NEXUS|Time") float DayLengthRealSeconds=2700.f;

    UFUNCTION(BlueprintCallable) void SetClimate(ENexusClimate NewClimate,int32 NewSeverity);
    UFUNCTION(BlueprintCallable) void SetClockMinutes(int32 Minutes);
    UFUNCTION(BlueprintPure) float RoadTractionMultiplier() const;
    UFUNCTION(BlueprintPure) float VisibilityMultiplier() const;
    UFUNCTION(BlueprintPure) FString WeatherReport() const;
    UFUNCTION() void OnRep_Climate();
private:
    float SecondsIntoMinute=0.f;
    void ApplySkyAndFog();
};
