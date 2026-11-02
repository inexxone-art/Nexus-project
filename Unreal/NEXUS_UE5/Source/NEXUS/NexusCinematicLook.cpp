#include "NexusCinematicLook.h"
#include "NexusAlpineWeather.h"
#include "Components/SceneComponent.h"
#include "Components/SkyAtmosphereComponent.h"
#include "Components/PostProcessComponent.h"
#include "EngineUtils.h"

ANexusCinematicLook::ANexusCinematicLook()
{
    PrimaryActorTick.bCanEverTick=true;
    PrimaryActorTick.TickInterval=.5f;
    bReplicates=false; // pure visuals: every client creates its own look
    LookRoot=CreateDefaultSubobject<USceneComponent>(TEXT("CinematicLookRoot"));
    RootComponent=LookRoot;
    Sky=CreateDefaultSubobject<USkyAtmosphereComponent>(TEXT("PhysicalAlpineAtmosphere"));
    Sky->SetupAttachment(LookRoot);
    PostProcess=CreateDefaultSubobject<UPostProcessComponent>(TEXT("AdlerklammCinemaGrade"));
    PostProcess->SetupAttachment(LookRoot);
    PostProcess->bUnbound=true;
    PostProcess->Priority=15.f;
    PostProcess->BlendWeight=1.f;
    FPostProcessSettings& Grade=PostProcess->Settings;
    Grade.bOverride_ColorSaturation=true;
    Grade.ColorSaturation=FVector4(.91f,.91f,.88f,1.f);
    Grade.bOverride_ColorContrast=true;
    Grade.ColorContrast=FVector4(1.09f,1.09f,1.09f,1.f);
    Grade.bOverride_BloomIntensity=true;
    Grade.BloomIntensity=.25f;
    Grade.bOverride_VignetteIntensity=true;
    Grade.VignetteIntensity=.18f;
    Grade.bOverride_AutoExposureBias=true;
    Grade.AutoExposureBias=-.2f;
}
void ANexusCinematicLook::Tick(float DeltaSeconds)
{
    Super::Tick(DeltaSeconds);
    if(!GetWorld())return;
    for(TActorIterator<ANexusAlpineWeather> It(GetWorld());It;++It)
    {
        const bool Storm=It->Climate==ENexusClimate::Storm;
        const float Strength=FMath::Clamp(It->Severity/100.f,0.f,1.f);
        PostProcess->Settings.ColorSaturation=FVector4(
            1.f-(Storm?.20f:.07f)*Strength,
            1.f-(Storm?.22f:.08f)*Strength,
            1.f-(Storm?.24f:.10f)*Strength,1.f);
        PostProcess->Settings.ColorContrast=FVector4(
            1.08f+.07f*Strength,1.08f+.07f*Strength,1.08f+.07f*Strength,1.f);
        PostProcess->Settings.VignetteIntensity=.17f+.09f*Strength;
        break;
    }
}
