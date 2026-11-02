#include "NexusUnderwaterEvidence.h"
#include "Components/StaticMeshComponent.h"
#include "Components/TextRenderComponent.h"
#include "Components/PointLightComponent.h"
#include "Net/UnrealNetwork.h"
#include "Engine/World.h"
#include "UObject/ConstructorHelpers.h"

ANexusUnderwaterEvidence::ANexusUnderwaterEvidence()
{
    PrimaryActorTick.bCanEverTick=true;
    bReplicates=true;
    SetReplicateMovement(true);
    bAlwaysRelevant=true;
    RecorderMesh=CreateDefaultSubobject<UStaticMeshComponent>(TEXT("SunkenBusBlackbox"));
    RootComponent=RecorderMesh;
    RecorderMesh->SetCollisionEnabled(ECollisionEnabled::NoCollision);
    static ConstructorHelpers::FObjectFinder<UStaticMesh> Placeholder(TEXT("/Engine/BasicShapes/Cube.Cube"));
    if(Placeholder.Succeeded())RecorderMesh->SetStaticMesh(Placeholder.Object);
    RecorderMesh->SetRelativeScale3D(FVector(.58f,.35f,.25f));
    BeaconLight=CreateDefaultSubobject<UPointLightComponent>(TEXT("UnderwaterFlashingSignal"));
    BeaconLight->SetupAttachment(RootComponent);
    BeaconLight->SetLightColor(FLinearColor(.2f,.82f,1.f),true);
    BeaconLight->SetIntensity(650.f);
    BeaconLight->SetAttenuationRadius(650.f);
    BeaconLabel=CreateDefaultSubobject<UTextRenderComponent>(TEXT("BlackboxRescueMarker"));
    BeaconLabel->SetupAttachment(RootComponent);
    BeaconLabel->SetRelativeLocation(FVector(0,0,80.f));
    BeaconLabel->SetWorldSize(35.f);
    BeaconLabel->SetText(FText::FromString(TEXT("D A T E N R E K O R D E R  [E]")));
    OnRep_SalvageState();
}
void ANexusUnderwaterEvidence::SetAvailable(bool Available)
{
    if(!HasAuthority() || bRecovered)return;
    bAvailable=Available;
    OnRep_SalvageState();
    ForceNetUpdate();
}
void ANexusUnderwaterEvidence::Recover()
{
    if(!HasAuthority() || bRecovered)return;
    bAvailable=false;
    bRecovered=true;
    OnRep_SalvageState();
    ForceNetUpdate();
}
void ANexusUnderwaterEvidence::OnRep_SalvageState()
{
    const bool bShow=bAvailable && !bRecovered;
    SetActorHiddenInGame(!bShow);
    RecorderMesh->SetVisibility(bShow);
    BeaconLight->SetVisibility(bShow);
    BeaconLabel->SetVisibility(bShow);
}
void ANexusUnderwaterEvidence::Tick(float DeltaSeconds)
{
    Super::Tick(DeltaSeconds);
    if(!bAvailable || bRecovered || !GetWorld())return;
    const float Wave=FMath::Sin(GetWorld()->GetTimeSeconds()*4.1f);
    BeaconLight->SetIntensity(750.f+Wave*390.f);
}
void ANexusUnderwaterEvidence::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const
{
    Super::GetLifetimeReplicatedProps(Out);
    DOREPLIFETIME(ANexusUnderwaterEvidence,bAvailable);
    DOREPLIFETIME(ANexusUnderwaterEvidence,bRecovered);
}
