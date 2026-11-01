#include "NexusRescueTarget.h"
#include "Components/CapsuleComponent.h"
#include "Components/StaticMeshComponent.h"
#include "Components/TextRenderComponent.h"
#include "UObject/ConstructorHelpers.h"

ANexusRescueTarget::ANexusRescueTarget()
{
    Collider=CreateDefaultSubobject<UCapsuleComponent>(TEXT("PersonCollision"));
    Collider->InitCapsuleSize(45,95);
    RootComponent=Collider;
    Body=CreateDefaultSubobject<UStaticMeshComponent>(TEXT("ReplaceWithMetaHuman"));
    Body->SetupAttachment(Collider);
    Body->SetCollisionEnabled(ECollisionEnabled::NoCollision);
    static ConstructorHelpers::FObjectFinder<UStaticMesh> Cap(TEXT("/Engine/BasicShapes/Capsule.Capsule"));
    if(Cap.Succeeded()) Body->SetStaticMesh(Cap.Object);
    DistressMarker=CreateDefaultSubobject<UTextRenderComponent>(TEXT("DistressMarker"));
    DistressMarker->SetupAttachment(Collider);
    DistressMarker->SetRelativeLocation(FVector(0,0,180));
    DistressMarker->SetText(FText::FromString(TEXT("HILFE / RETTUNG E")));
    DistressMarker->SetWorldSize(43.f);
}
void ANexusRescueTarget::MarkRescued()
{
    if(bRescued)return;
    bRescued=true;
    SetActorHiddenInGame(true);
    SetActorEnableCollision(false);
}
