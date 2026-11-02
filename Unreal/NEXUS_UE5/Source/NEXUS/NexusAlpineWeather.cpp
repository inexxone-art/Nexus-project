#include "NexusAlpineWeather.h"
#include "Components/SceneComponent.h"
#include "Components/DirectionalLightComponent.h"
#include "Components/ExponentialHeightFogComponent.h"
#include "Components/SkyLightComponent.h"
#include "NiagaraComponent.h"
#include "NiagaraSystem.h"
#include "Net/UnrealNetwork.h"
#include "Engine/World.h"

ANexusAlpineWeather::ANexusAlpineWeather()
{
    PrimaryActorTick.bCanEverTick=true;
    bReplicates=true;
    bAlwaysRelevant=true;
    SetReplicateMovement(false);

    WeatherRoot=CreateDefaultSubobject<USceneComponent>(TEXT("WeatherRoot"));
    RootComponent=WeatherRoot;
    Sun=CreateDefaultSubobject<UDirectionalLightComponent>(TEXT("DayNightSun"));
    Sun->SetupAttachment(WeatherRoot);
    Sun->SetIntensity(80000.f);
    Sun->SetLightColor(FLinearColor(1.0f,0.93f,0.83f),true);
    Sun->CastShadows=true;
    Sun->bAtmosphereSunLight=true;

    Fog=CreateDefaultSubobject<UExponentialHeightFogComponent>(TEXT("StormVolumetricFog"));
    Fog->SetupAttachment(WeatherRoot);
    Fog->SetFogDensity(0.008f);
    Fog->bEnableVolumetricFog=true;

    SkyAmbient=CreateDefaultSubobject<USkyLightComponent>(TEXT("AlpineAmbient"));
    SkyAmbient->SetupAttachment(WeatherRoot);
    SkyAmbient->SetIntensity(0.75f);

    RainParticles=CreateDefaultSubobject<UNiagaraComponent>(TEXT("OptionalRainOrSnowVFX"));
    RainParticles->SetupAttachment(WeatherRoot);
    RainParticles->SetAutoActivate(false);
}
void ANexusAlpineWeather::BeginPlay()
{
    Super::BeginPlay();
    // Niagara authoring is external. No 'fake' visual claim when particle asset is absent.
    if(auto* Rain=LoadObject<UNiagaraSystem>(nullptr,
       TEXT("/Game/AAA/VFX/NS_NexusAlpinePrecipitation.NS_NexusAlpinePrecipitation")))
        RainParticles->SetAsset(Rain);
    ApplySkyAndFog();
}
void ANexusAlpineWeather::Tick(float DeltaSeconds)
{
    Super::Tick(DeltaSeconds);
    if(!GetWorld() || DeltaSeconds<=0.f)return;
    if(HasAuthority())
    {
        // 24 in-game hours elapse in DayLengthRealSeconds of actual play.
        const float MinuteLength=FMath::Max(180.f,DayLengthRealSeconds)/1440.f;
        SecondsIntoMinute+=DeltaSeconds;
        if(SecondsIntoMinute>=MinuteLength)
        {
            const int32 Increment=FMath::FloorToInt(SecondsIntoMinute/MinuteLength);
            SecondsIntoMinute-=Increment*MinuteLength;
            MinuteOfDay=(MinuteOfDay+Increment)%1440;
        }
    }
    ApplySkyAndFog();
}
void ANexusAlpineWeather::SetClimate(ENexusClimate Mode,int32 Intensity)
{
    if(!HasAuthority())return;
    Climate=Mode;
    Severity=FMath::Clamp(Intensity,0,100);
    OnRep_Climate();
    ForceNetUpdate();
}
void ANexusAlpineWeather::SetClockMinutes(int32 Minutes)
{
    if(!HasAuthority())return;
    MinuteOfDay=((Minutes%1440)+1440)%1440;
    OnRep_Climate();
    ForceNetUpdate();
}
float ANexusAlpineWeather::RoadTractionMultiplier() const
{
    const float Wet=FMath::Clamp(Severity/100.f,0.f,1.f);
    switch(Climate)
    {
        case ENexusClimate::Rain: return FMath::Lerp(1.f,.78f,Wet);
        case ENexusClimate::Storm:return FMath::Lerp(1.f,.61f,Wet);
        case ENexusClimate::Snow: return FMath::Lerp(1.f,.49f,Wet);
        case ENexusClimate::Dust: return FMath::Lerp(1.f,.83f,Wet);
        default:return 1.f;
    }
}
float ANexusAlpineWeather::VisibilityMultiplier() const
{
    const float Wet=FMath::Clamp(Severity/100.f,0.f,1.f);
    return (Climate==ENexusClimate::Storm || Climate==ENexusClimate::Snow)
        ?FMath::Lerp(1.f,.23f,Wet)
        :(Climate==ENexusClimate::Dust?FMath::Lerp(1.f,.32f,Wet):FMath::Lerp(1.f,.83f,Wet));
}
FString ANexusAlpineWeather::WeatherReport() const
{
    const TCHAR* Label=TEXT("SONNIG");
    switch(Climate)
    {
        case ENexusClimate::Rain:Label=TEXT("REGEN");break;
        case ENexusClimate::Storm:Label=TEXT("UNWETTER");break;
        case ENexusClimate::Snow:Label=TEXT("SCHNEE");break;
        case ENexusClimate::Dust:Label=TEXT("STAUBSTURM");break;
        default:break;
    }
    return FString::Printf(TEXT("%02d:%02d  %s %d%%  GRIP %d%%"),
      (MinuteOfDay/60)%24,MinuteOfDay%60,Label,Severity,
      FMath::RoundToInt(100.f*RoadTractionMultiplier()));
}
void ANexusAlpineWeather::OnRep_Climate() {ApplySkyAndFog();}
void ANexusAlpineWeather::ApplySkyAndFog()
{
    if(!Sun || !Fog || !RainParticles)return;
    const float Hours=MinuteOfDay/60.f;
    // Noon: overhead; sunset/sunrise: horizon; night: below horizon.
    const float Altitude=FMath::Sin((Hours-6.f)*(2.f*PI/24.f));
    const float SunFraction=FMath::Clamp((Altitude+.09f)/.23f,0.f,1.f);
    const float StormAmount=(Climate==ENexusClimate::Storm)?Severity/100.f:0.f;
    Sun->SetWorldRotation(FRotator(-Altitude*88.f,28.f,0.f));
    Sun->SetIntensity(85000.f*SunFraction*FMath::Lerp(1.f,.36f,StormAmount));
    SkyAmbient->SetIntensity(FMath::Lerp(.08f,.7f,SunFraction));
    const float FogFactor=(1.f-VisibilityMultiplier());
    Fog->SetFogDensity(FMath::Lerp(.006f,.065f,FogFactor));
    Fog->SetFogHeightFalloff(FMath::Lerp(.14f,.08f,FogFactor));
    const bool bPrecipitation=(Climate==ENexusClimate::Rain || Climate==ENexusClimate::Storm || Climate==ENexusClimate::Snow);
    if(RainParticles->GetAsset() && bPrecipitation && Severity>=20)
    {
        if(!RainParticles->IsActive())RainParticles->Activate();
    }
    else if(RainParticles->IsActive())RainParticles->Deactivate();
}
void ANexusAlpineWeather::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const
{
    Super::GetLifetimeReplicatedProps(Out);
    DOREPLIFETIME(ANexusAlpineWeather,Climate);
    DOREPLIFETIME(ANexusAlpineWeather,Severity);
    DOREPLIFETIME(ANexusAlpineWeather,MinuteOfDay);
}
