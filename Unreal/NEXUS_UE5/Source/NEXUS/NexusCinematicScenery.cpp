#include "NexusCinematicScenery.h"
#include "Components/SceneComponent.h"
#include "Components/HierarchicalInstancedStaticMeshComponent.h"
#include "Engine/StaticMesh.h"
#include "Engine/World.h"
#include "Math/RandomStream.h"

ANexusCinematicScenery::ANexusCinematicScenery()
{
    PrimaryActorTick.bCanEverTick=false;
    bReplicates=true;
    SetReplicateMovement(false);
    SceneryRoot=CreateDefaultSubobject<USceneComponent>(TEXT("AdlerklammBiomeRoot"));
    RootComponent=SceneryRoot;
    PineForestA=CreateDefaultSubobject<UHierarchicalInstancedStaticMeshComponent>(TEXT("AlpineSpruceA"));
    PineForestB=CreateDefaultSubobject<UHierarchicalInstancedStaticMeshComponent>(TEXT("AlpineSpruceB"));
    TalusBoulders=CreateDefaultSubobject<UHierarchicalInstancedStaticMeshComponent>(TEXT("ErodedTalus"));
    AlpineShrubs=CreateDefaultSubobject<UHierarchicalInstancedStaticMeshComponent>(TEXT("AlpineShrub"));
    for(auto* HISM:{PineForestA.Get(),PineForestB.Get(),TalusBoulders.Get(),AlpineShrubs.Get()})
    {
        HISM->SetupAttachment(SceneryRoot);
        HISM->SetCollisionEnabled(ECollisionEnabled::NoCollision);
        HISM->SetMobility(EComponentMobility::Static);
        HISM->SetCullDistances(1800,80000);
        HISM->bCastDynamicShadow=true;
    }
}
bool ANexusCinematicScenery::LoadFoliageMesh(UHierarchicalInstancedStaticMeshComponent* Target,const TCHAR* Path)
{
    if(!Target)return false;
    if(auto* Mesh=LoadObject<UStaticMesh>(nullptr,Path))
    {
        Target->SetStaticMesh(Mesh);
        return true;
    }
    UE_LOG(LogTemp,Warning,TEXT("NEXUS foliage mesh missing: %s"),Path);
    return false;
}
bool ANexusCinematicScenery::IsOnProtectedRoad(float X,float Y) const
{
    // Keep the 82-m driving span and east/west vehicle accesses free.
    return FMath::Abs(Y)<1650.f && FMath::Abs(X)<14000.f;
}
void ANexusCinematicScenery::BeginPlay()
{
    Super::BeginPlay();
    PopulateLandscape();
}
void ANexusCinematicScenery::PopulateLandscape()
{
    if(PineForestA->GetInstanceCount()>0 || TalusBoulders->GetInstanceCount()>0)return;
    const bool A=LoadFoliageMesh(PineForestA,
       TEXT("/Game/AAA/Geometry/Foliage/SM_NEXUS_Spruce_01.SM_NEXUS_Spruce_01"));
    const bool B=LoadFoliageMesh(PineForestB,
       TEXT("/Game/AAA/Geometry/Foliage/SM_NEXUS_Spruce_02.SM_NEXUS_Spruce_02"));
    const bool Rocks=LoadFoliageMesh(TalusBoulders,
       TEXT("/Game/AAA/Geometry/Foliage/SM_NEXUS_Boulder_01.SM_NEXUS_Boulder_01"));
    const bool Shrubs=LoadFoliageMesh(AlpineShrubs,
       TEXT("/Game/AAA/Geometry/Foliage/SM_NEXUS_AlpineShrub_01.SM_NEXUS_AlpineShrub_01"));
    FRandomStream Random(LandscapeSeed);
    const int32 Trees=FMath::Clamp(TreeCount,0,3000);
    for(int32 I=0;I<Trees;++I)
    {
        const float X=Random.FRandRange(-14500.f,14500.f);
        const float Y=Random.FRandRange(-7900.f,7900.f);
        if(IsOnProtectedRoad(X,Y))continue;
        const float Height=Random.FRandRange(0.82f,1.65f);
        // Heights are approximate at the C++ fallback plateau.
        // Production PCG should place instances by Landscape trace.
        const float Z=(FMath::Abs(X)>4200.f ? 2000.f : 1500.f);
        const FTransform T(FRotator(0,Random.FRandRange(0.f,360.f),0),
          FVector(X,Y,Z),FVector(Height));
        if(I%3 && A)PineForestA->AddInstance(T);
        else if(B)PineForestB->AddInstance(T);
    }
    for(int32 I=0;I<FMath::Clamp(BoulderCount,0,2000);++I)
    {
        const float X=Random.FRandRange(-13000.f,13000.f);
        const float Y=Random.FRandRange(-9400.f,9400.f);
        if(IsOnProtectedRoad(X,Y))continue;
        const float Radius=Random.FRandRange(0.75f,2.8f);
        const FTransform T(FRotator(Random.FRandRange(-12.f,12.f),
          Random.FRandRange(0.f,360.f),0),FVector(X,Y,1700.f),FVector(Radius));
        if(Rocks)TalusBoulders->AddInstance(T);
        if(Shrubs && I%3==0)
            AlpineShrubs->AddInstance(FTransform(FRotator(0,Random.FRandRange(0.f,360.f),0),
                FVector(X+Random.FRandRange(100.f,330.f),Y,1970.f),FVector(1.0f)));
    }
}
