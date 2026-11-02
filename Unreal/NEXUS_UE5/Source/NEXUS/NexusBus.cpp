#include "NexusBus.h"
#include "Components/StaticMeshComponent.h"
#include "Engine/StaticMesh.h"
#include "UObject/ConstructorHelpers.h"
#include "Net/UnrealNetwork.h"

ANexusBus::ANexusBus()
{
    PrimaryActorTick.bCanEverTick=false;
    bReplicates=true;
    SetReplicateMovement(true);
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
    if(!HasAuthority() || bReleased) return;
    bReleased=true;
    PhysicsBody->SetSimulatePhysics(true);
    PhysicsBody->WakeAllRigidBodies();
    // A few m/s of traffic momentum, then real gravity accelerates the fall.
    // Avoid the old 1300m/s velocity-change and thousands of radians/sec.
    PhysicsBody->SetPhysicsLinearVelocity(FVector(560.f,-140.f,-110.f));
    PhysicsBody->SetPhysicsAngularVelocityInDegrees(FVector(65.f,15.f,110.f));
    ForceNetUpdate();
}
void ANexusBus::AdvanceConvoy(const FVector& LeadPosition,float Dt)
{
    if(!HasAuthority() || bReleased || Dt<=0.f)return;
    // Keep the bus 39 m behind a west-to-east driver; never lead it over
    // the broken edge. The bus remains a physical actor when released.
    if(LeadPosition.X< -7600.f || LeadPosition.X>4800.f ||
       FMath::Abs(LeadPosition.Y)>1700.f)return;
    const FVector Current=GetActorLocation();
    const float DestinationX=FMath::Clamp(LeadPosition.X-3900.f,-11600.f,850.f);
    // Never reverse the bus because a second co-op vehicle joins behind it.
    const float NextX=FMath::Max(Current.X,FMath::Min(DestinationX,Current.X+2100.f*Dt));
    // The bridge deck rises slightly above the approach asphalt. Actor
    // placement is kept above its collision until Chaos takes control.
    const float TargetZ=NextX> -4000.f ? 2200.f : 2240.f;
    SetActorLocation(FVector(NextX,-260.f,FMath::FInterpTo(Current.Z,TargetZ,Dt,3.f)),true);
}
void ANexusBus::PositionForBridgeImpact()
{
    if(!HasAuthority() || bReleased)return;
    // Restored saves have no convoy history. Put the bus on the bridge
    // before resuming the fall, rather than dropping it on the approach.
    SetActorLocation(FVector(250.f,-260.f,2190.f),false,nullptr,ETeleportType::TeleportPhysics);
}
void ANexusBus::ResetBus()
{
    if(!HasAuthority())return;
    bReleased=false;
    PhysicsBody->SetSimulatePhysics(false);
    SetActorTransform(InitialTransform);
    PhysicsBody->SetPhysicsLinearVelocity(FVector::ZeroVector);
    PhysicsBody->SetPhysicsAngularVelocityInDegrees(FVector::ZeroVector);
    ForceNetUpdate();
}
void ANexusBus::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const
{
    Super::GetLifetimeReplicatedProps(Out);
    DOREPLIFETIME(ANexusBus,bReleased);
}
