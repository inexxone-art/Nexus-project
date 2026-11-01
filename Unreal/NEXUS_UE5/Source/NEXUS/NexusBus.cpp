#include "NexusBus.h"
#include "Components/StaticMeshComponent.h"
#include "Engine/StaticMesh.h"
#include "UObject/ConstructorHelpers.h"

ANexusBus::ANexusBus()
{
    PrimaryActorTick.bCanEverTick=false;
    PhysicsBody=CreateDefaultSubobject<UStaticMeshComponent>(TEXT("CHAOS_BUS_MESH"));
    RootComponent=PhysicsBody;
    PhysicsBody->SetMobility(EComponentMobility::Movable);
    PhysicsBody->SetCollisionProfileName(TEXT("PhysicsActor"));
    PhysicsBody->SetSimulatePhysics(false);
}
void ANexusBus::BeginPlay()
{
    Super::BeginPlay();
    InitialTransform=GetActorTransform();
    if(!HighPolyBus.IsNull()) PhysicsBody->SetStaticMesh(HighPolyBus.LoadSynchronous());
    if(!PhysicsBody->GetStaticMesh())
    {
        static ConstructorHelpers::FObjectFinder<UStaticMesh> Placeholder(TEXT("/Engine/BasicShapes/Cube.Cube"));
        if(Placeholder.Succeeded())
        {
            PhysicsBody->SetStaticMesh(Placeholder.Object);
            PhysicsBody->SetWorldScale3D(FVector(11.f,2.75f,3.f));
        }
    }
}
void ANexusBus::DropBehindPlayer()
{
    if(bReleased) return;
    bReleased=true;
    PhysicsBody->SetSimulatePhysics(true);
    PhysicsBody->WakeAllRigidBodies();
    PhysicsBody->AddImpulse(FVector(130000.f,-50000.f,-130000.f),NAME_None,true);
    PhysicsBody->AddAngularImpulseInRadians(FVector(15000.f,6000.f,29000.f),NAME_None,true);
}
void ANexusBus::ResetBus()
{
    bReleased=false;
    PhysicsBody->SetSimulatePhysics(false);
    SetActorTransform(InitialTransform);
    PhysicsBody->SetPhysicsLinearVelocity(FVector::ZeroVector);
    PhysicsBody->SetPhysicsAngularVelocityInDegrees(FVector::ZeroVector);
}
