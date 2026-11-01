#include "NexusBridge.h"
#include "Components/SceneComponent.h"
#include "Components/StaticMeshComponent.h"
#include "Engine/StaticMesh.h"
#include "UObject/ConstructorHelpers.h"

ANexusBridge::ANexusBridge()
{
    PrimaryActorTick.bCanEverTick=false;
    Base=CreateDefaultSubobject<USceneComponent>(TEXT("BridgeRoot"));
    RootComponent=Base;
}
UStaticMesh* ANexusBridge::GetSegmentMesh() const
{
    if(!NaniteBridgeSegment.IsNull()) if(auto* Mesh=NaniteBridgeSegment.LoadSynchronous()) return Mesh;
    return LoadObject<UStaticMesh>(nullptr,TEXT("/Engine/BasicShapes/Cube.Cube"));
}
void ANexusBridge::BeginPlay()
{
    Super::BeginPlay();
    UStaticMesh* Mesh=GetSegmentMesh();
    for(int32 I=0;I<12;++I)
    {
        UStaticMeshComponent* Segment=NewObject<UStaticMeshComponent>(this,*FString::Printf(TEXT("PhysicallyFracturableSpan_%02d"),I));
        Segment->SetupAttachment(Base);
        Segment->SetMobility(EComponentMobility::Movable);
        Segment->SetStaticMesh(Mesh);
        Segment->SetRelativeLocation(FVector(-3758.3f+I*683.3f,0,0));
        if(NaniteBridgeSegment.IsNull()) Segment->SetRelativeScale3D(FVector(6.83f,10.5f,0.9f));
        Segment->SetCollisionProfileName(TEXT("PhysicsActor"));
        Segment->SetSimulatePhysics(false);
        AddInstanceComponent(Segment);
        Segment->RegisterComponent();
        Segments.Add(Segment);
    }
}
void ANexusBridge::Collapse()
{
    if(bCollapsed) return;
    bCollapsed=true;
    for(int32 I=0;I<Segments.Num();++I)
    {
        UStaticMeshComponent* Piece=Segments[I];
        if(!Piece) continue;
        Piece->SetSimulatePhysics(true);
        Piece->WakeAllRigidBodies();
        const float Direction=(I%2?1.f:-1.f);
        Piece->AddImpulse(FVector(Direction*17000.f,Direction*12000.f,-90000.f),NAME_None,true);
        Piece->AddAngularImpulseInRadians(FVector(3400.f*Direction,1700.f,600.f),NAME_None,true);
    }
}
void ANexusBridge::Reconstruct()
{
    bCollapsed=false;
    for(int32 I=0;I<Segments.Num();++I)
    {
        auto* Piece=Segments[I];
        if(!Piece) continue;
        Piece->SetSimulatePhysics(false);
        Piece->SetWorldTransform(FTransform(GetActorRotation(),GetActorLocation()+FVector(-3758.3f+I*683.3f,0,0), NaniteBridgeSegment.IsNull()?FVector(6.83f,10.5f,0.9f):FVector::OneVector));
        Piece->SetPhysicsLinearVelocity(FVector::ZeroVector);
        Piece->SetPhysicsAngularVelocityInDegrees(FVector::ZeroVector);
    }
}
