#include "NexusBridge.h"
#include "Components/SceneComponent.h"
#include "Components/StaticMeshComponent.h"
#include "Engine/StaticMesh.h"
#include "UObject/ConstructorHelpers.h"
#include "TimerManager.h"

ANexusBridge::ANexusBridge()
{
    PrimaryActorTick.bCanEverTick=false;
    bReplicates=true;
    SetReplicateMovement(true);
    Base=CreateDefaultSubobject<USceneComponent>(TEXT("BridgeRoot"));
    RootComponent=Base;
}
UStaticMesh* ANexusBridge::GetSegmentMesh() const
{
    if(!NaniteBridgeSegment.IsNull()) if(auto* Mesh=NaniteBridgeSegment.LoadSynchronous()) return Mesh;
    if(auto* Art=LoadObject<UStaticMesh>(nullptr,
        TEXT("/Game/AAA/Geometry/Hero/SM_NEXUS_BridgeSpan_6p83m.SM_NEXUS_BridgeSpan_6p83m"))) return Art;
    return LoadObject<UStaticMesh>(nullptr,TEXT("/Engine/BasicShapes/Cube.Cube"));
}
void ANexusBridge::BeginPlay()
{
    Super::BeginPlay();
    UStaticMesh* Mesh=GetSegmentMesh();
    const bool bFallbackBox=Mesh && Mesh->GetPathName().StartsWith(TEXT("/Engine/BasicShapes"));
    for(int32 I=0;I<12;++I)
    {
        UStaticMeshComponent* Segment=NewObject<UStaticMeshComponent>(this,*FString::Printf(TEXT("PhysicallyFracturableSpan_%02d"),I));
        Segment->SetupAttachment(Base);
        Segment->SetMobility(EComponentMobility::Movable);
        Segment->SetStaticMesh(Mesh);
        Segment->SetRelativeLocation(FVector(-3758.3f+I*683.3f,0,0));
        if(bFallbackBox) Segment->SetRelativeScale3D(FVector(6.83f,10.5f,0.9f));
        OriginalLocalTransforms.Add(Segment->GetRelativeTransform());
        Segment->SetCollisionProfileName(TEXT("PhysicsActor"));
        Segment->SetSimulatePhysics(false);
        AddInstanceComponent(Segment);
        Segment->RegisterComponent();
        Segments.Add(Segment);
    }
}
void ANexusBridge::ReleaseSpan(int32 Index)
{
    if(!bCollapsed || !Segments.IsValidIndex(Index)) return;
    auto* Piece=Segments[Index];
    if(!Piece)return;
    Piece->SetSimulatePhysics(true);
    Piece->WakeAllRigidBodies();
    const float Sign=(Index%2)?1.f:-1.f;
    // Chaos bVelChange uses cm/s. Small separation velocity + real gravity,
    // not hundreds of metres per second from the earlier alpha simulation.
    Piece->AddImpulse(FVector(Sign*120.f,Sign*65.f,-95.f),NAME_None,true);
    Piece->SetPhysicsAngularVelocityInDegrees(FVector(20.f*Sign,12.f,37.f*Sign));
}
void ANexusBridge::Collapse()
{
    if(bCollapsed)return;
    bCollapsed=true;
    ReleaseSpan(0);
    if(!GetWorld())return;
    for(int32 I=1;I<Segments.Num();++I)
    {
        FTimerHandle Handle;
        FTimerDelegate Task=FTimerDelegate::CreateUObject(this,&ANexusBridge::ReleaseSpan,I);
        GetWorld()->GetTimerManager().SetTimer(Handle,Task,0.11f*I,false);
    }
}
void ANexusBridge::Reconstruct()
{
    bCollapsed=false;
    if(GetWorld())GetWorld()->GetTimerManager().ClearAllTimersForObject(this);
    for(int32 I=0;I<Segments.Num();++I)
    {
        auto* Piece=Segments[I];
        if(!Piece)continue;
        Piece->SetSimulatePhysics(false);
        Piece->AttachToComponent(Base,FAttachmentTransformRules::KeepWorldTransform);
        if(OriginalLocalTransforms.IsValidIndex(I))
            Piece->SetRelativeTransform(OriginalLocalTransforms[I]);
    }
}
