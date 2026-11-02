#include "NexusRescueTarget.h"
#include "Components/CapsuleComponent.h"
#include "Components/StaticMeshComponent.h"
#include "Components/TextRenderComponent.h"
#include "Net/UnrealNetwork.h"
#include "UObject/ConstructorHelpers.h"

ANexusRescueTarget::ANexusRescueTarget()
{
    bReplicates=true;
    SetReplicateMovement(true);
    Collider=CreateDefaultSubobject<UCapsuleComponent>(TEXT("PersonCollision"));
    Collider->InitCapsuleSize(45,95);
    RootComponent=Collider;
    Body=CreateDefaultSubobject<UStaticMeshComponent>(TEXT("ReplaceWithMetaHuman"));
    Body->SetupAttachment(Collider);
    Body->SetCollisionEnabled(ECollisionEnabled::NoCollision);
    static ConstructorHelpers::FObjectFinder<UStaticMesh> Cap(TEXT("/Engine/BasicShapes/Capsule.Capsule"));
    if(Cap.Succeeded())Body->SetStaticMesh(Cap.Object);
    DistressMarker=CreateDefaultSubobject<UTextRenderComponent>(TEXT("DistressMarker"));
    DistressMarker->SetupAttachment(Collider);
    DistressMarker->SetRelativeLocation(FVector(0,0,180));
    DistressMarker->SetText(FText::FromString(TEXT("HILFE / RETTUNG E")));
    DistressMarker->SetWorldSize(43.f);
    OnRep_RescueState();
}
void ANexusRescueTarget::SetAvailable(bool Available)
{
    if(!HasAuthority())return;
    bAvailable=Available;
    OnRep_RescueState();
    ForceNetUpdate();
}
void ANexusRescueTarget::LocateSurvivor()
{
    if(!HasAuthority() || !bAvailable || bRescued)return;
    bLocated=true;
    OnRep_RescueState();
    ForceNetUpdate();
}
void ANexusRescueTarget::StabilizeSurvivor()
{
    if(!HasAuthority() || !bAvailable || !bLocated || bRescued)return;
    bStabilized=true;
    OnRep_RescueState();
    ForceNetUpdate();
}
void ANexusRescueTarget::MarkRescued()
{
    if(!HasAuthority() || bRescued || !bLocated || !bStabilized)return;
    bRescued=true;
    bAvailable=false;
    OnRep_RescueState();
    ForceNetUpdate();
}
void ANexusRescueTarget::OnRep_RescueState()
{
    const bool bVisible=bAvailable && !bRescued;
    SetActorHiddenInGame(!bVisible);
    SetActorEnableCollision(bVisible);
    if(DistressMarker)
    {
        const TCHAR* Message=!bLocated?TEXT("HILFE! [E] SUCHEN"):
            (!bStabilized?TEXT("VERLETZT [E] VERSORGEN"):TEXT("BEREIT [E] BERGEN"));
        DistressMarker->SetText(FText::FromString(Message));
    }
}
void ANexusRescueTarget::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const
{
    Super::GetLifetimeReplicatedProps(Out);
    DOREPLIFETIME(ANexusRescueTarget,SurvivorId);
    DOREPLIFETIME(ANexusRescueTarget,bRescued);
    DOREPLIFETIME(ANexusRescueTarget,bAvailable);
    DOREPLIFETIME(ANexusRescueTarget,bLocated);
    DOREPLIFETIME(ANexusRescueTarget,bStabilized);
}
