#include "NexusStarterHome.h"
#include "Components/SceneComponent.h"
#include "Components/StaticMeshComponent.h"
#include "Components/TextRenderComponent.h"
#include "Engine/StaticMesh.h"

ANexusStarterHome::ANexusStarterHome()
{
    PrimaryActorTick.bCanEverTick=false;
    bReplicates=true;
    SetReplicateMovement(false);
    HouseRoot=CreateDefaultSubobject<USceneComponent>(TEXT("NEXUS_HomeRoot"));
    RootComponent=HouseRoot;
    OfficeLabel=CreateDefaultSubobject<UTextRenderComponent>(TEXT("PinboardMarker"));
    OfficeLabel->SetupAttachment(HouseRoot);
    OfficeLabel->SetRelativeLocation(FVector(-260.f,260.f,335.f));
    OfficeLabel->SetRelativeRotation(FRotator(0.f,180.f,0.f));
    OfficeLabel->SetWorldSize(28.f);
    OfficeLabel->SetText(FText::FromString(TEXT("PINNWAND [B / E]")));
}
void ANexusStarterHome::Part(FName Name,FVector LocalPosition,FVector DimensionsCm,bool bSolid)
{
    auto* Cube=NewObject<UStaticMeshComponent>(this,Name);
    Cube->SetupAttachment(HouseRoot);
    Cube->SetStaticMesh(LoadObject<UStaticMesh>(nullptr,TEXT("/Engine/BasicShapes/Cube.Cube")));
    Cube->SetMobility(EComponentMobility::Static);
    Cube->SetRelativeLocation(LocalPosition);
    Cube->SetRelativeScale3D(DimensionsCm/100.f);
    Cube->SetCollisionEnabled(bSolid?ECollisionEnabled::QueryAndPhysics:ECollisionEnabled::NoCollision);
    AddInstanceComponent(Cube);
    Cube->RegisterComponent();
    BuildingPieces.Add(Cube);
}
void ANexusStarterHome::BeginPlay()
{
    Super::BeginPlay();
    // The editor can replace this entire blockout with an artist-authored,
    // fully enterable home imported at the documented project asset path.
    if(auto* Hero=LoadObject<UStaticMesh>(nullptr,
         TEXT("/Game/AAA/Geometry/StoryAreas/SM_NEXUS_StarterHome.SM_NEXUS_StarterHome")))
    {
        auto* Building=NewObject<UStaticMeshComponent>(this,TEXT("ImportedStarterHome"));
        Building->SetupAttachment(HouseRoot);
        Building->SetStaticMesh(Hero);
        Building->SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
        AddInstanceComponent(Building);
        Building->RegisterComponent();
        BuildingPieces.Add(Building);
        return;
    }
    // Dimensions in cm; south entrance has a real 240-cm wide doorway.
    Part(TEXT("WalkableFloor"),FVector(0,0,10),FVector(1400,1200,30));
    Part(TEXT("Roof"),FVector(0,0,480),FVector(1500,1280,35));
    Part(TEXT("NorthWall"),FVector(0,600,250),FVector(1400,30,450));
    Part(TEXT("WestWall"),FVector(-700,0,250),FVector(30,1200,450));
    Part(TEXT("EastWall"),FVector(700,0,250),FVector(30,1200,450));
    Part(TEXT("FrontLeft"),FVector(-465,-600,250),FVector(470,30,450));
    Part(TEXT("FrontRight"),FVector(465,-600,250),FVector(470,30,450));
    Part(TEXT("DoorHeader"),FVector(0,-600,406),FVector(460,30,135));
    Part(TEXT("OfficeDesk"),FVector(-260,20,105),FVector(280,110,100));
    Part(TEXT("Pinboard"),FVector(-260,270,305),FVector(285,24,160));
    // Small separate attached garage with a wide open vehicle entrance.
    Part(TEXT("GarageFloor"),FVector(1020,0,10),FVector(610,880,30));
    Part(TEXT("GarageBack"),FVector(1020,440,235),FVector(610,30,420));
    Part(TEXT("GarageEast"),FVector(1320,0,235),FVector(30,880,420));
    Part(TEXT("GarageRoof"),FVector(1020,0,465),FVector(650,930,30));
}
FVector ANexusStarterHome::PinboardLocation() const
{
    return GetActorTransform().TransformPosition(FVector(-260.f,140.f,170.f));
}
bool ANexusStarterHome::IsNearPinboard(FVector PlayerWorldPos) const
{
    return FVector::Dist(PlayerWorldPos,PinboardLocation())<=440.f;
}
FVector ANexusStarterHome::StarterSpawnLocation() const
{
    return GetActorTransform().TransformPosition(FVector(0.f,-270.f,115.f));
}
