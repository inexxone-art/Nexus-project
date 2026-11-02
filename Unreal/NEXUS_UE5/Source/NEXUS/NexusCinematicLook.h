#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "NexusCinematicLook.generated.h"

class USceneComponent;
class USkyAtmosphereComponent;
class UPostProcessComponent;

// An in-engine, runtime camera grade. Not an imported screenshot: the grade
// works on whatever 3D assets are actually installed in the UE project.
UCLASS(Blueprintable)
class NEXUS_API ANexusCinematicLook : public AActor
{
    GENERATED_BODY()
public:
    ANexusCinematicLook();
    virtual void Tick(float DeltaSeconds) override;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<USceneComponent> LookRoot;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<USkyAtmosphereComponent> Sky;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UPostProcessComponent> PostProcess;
};
