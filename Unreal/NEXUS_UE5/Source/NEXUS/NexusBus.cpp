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
        PhysicsBody->SetStaticMesh(LoadObject<UStaticMesh>(nullptr,
            TEXT("/Game/AAA/Geometry/Hero/SM_NEXUS_RescueBus_12m.SM_NEXUS_RescueBus_12m")));
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
    // A few m/s of traffic momentum, then real gravity accelerates the fall.
    // Avoid the old 1300m/s velocity-change and thousands of radians/sec.
    PhysicsBody->SetPhysicsLinearVelocity(FVector(560.f,-140.f,-110.f));
    PhysicsBody->SetPhysicsAngularVelocityInDegrees(FVector(65.f,15.f,110.f));
}
void ANexusBus::ResetBus()
{
    bReleased=false;
    PhysicsBody->SetSimulatePhysics(false);
    SetActorTransform(InitialTransform);
    PhysicsBody->SetPhysicsLinearVelocity(FVector::ZeroVector);
    PhysicsBody->SetPhysicsAngularVelocityInDegrees(FVector::ZeroVector);
}
