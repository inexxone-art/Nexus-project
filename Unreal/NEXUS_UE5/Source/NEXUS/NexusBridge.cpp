#include "NexusBridge.h"
#include "Components/SceneComponent.h"
#include "Components/StaticMeshComponent.h"
#include "Engine/StaticMesh.h"
#include "UObject/ConstructorHelpers.h"
#include "TimerManager.h"

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
    Piece->AddImpulse(FVector(Sign*17000.f,Sign*11000.f,-85000.f),NAME_None,true);
    Piece->AddAngularImpulseInRadians(FVector(3100.f*Sign,1650.f,660.f),NAME_None,true);
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
