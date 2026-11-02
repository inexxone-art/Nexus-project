#include "NexusCityDistrict.h"
#include "Components/SceneComponent.h"
#include "Components/StaticMeshComponent.h"
#include "Engine/StaticMesh.h"

ANexusCityDistrict::ANexusCityDistrict()
{
    PrimaryActorTick.bCanEverTick=false;
    bReplicates=true;
    SetReplicateMovement(false);
    DistrictRoot=CreateDefaultSubobject<USceneComponent>(TEXT("CivicTownRoot"));
    RootComponent=DistrictRoot;
}
UStaticMeshComponent* ANexusCityDistrict::MakePart(FString Name,FVector Center,FVector Extents)
{
    UStaticMeshComponent* Part=NewObject<UStaticMeshComponent>(this,FName(*Name));
    Part->SetupAttachment(DistrictRoot);
    Part->SetStaticMesh(LoadObject<UStaticMesh>(nullptr,TEXT("/Engine/BasicShapes/Cube.Cube")));
    Part->SetRelativeLocation(Center);
    Part->SetRelativeScale3D(Extents/100.f);
    Part->SetCollisionProfileName(TEXT("BlockAll"));
    AddInstanceComponent(Part);
    Part->RegisterComponent();
    Architecture.Add(Part);
    return Part;
}
void ANexusCityDistrict::CreateFallbackBuilding(FString Name,FVector Position,int32 Width,int32 Depth,int32 Height)
{
    // Non-photoreal fallback has a walkable open doorway at the SOUTH wall.
    const float W=float(Width),D=float(Depth),H=float(Height);
    const float Door=250.f;
    MakePart(Name+TEXT("_Floor"),Position+FVector(0,0,10),FVector(W+60,D+60,20));
    MakePart(Name+TEXT("_Roof"),Position+FVector(0,0,H+10),FVector(W+80,D+80,35));
    MakePart(Name+TEXT("_Back"),Position+FVector(0,D*.5f,H*.5f),FVector(W,24,H));
    MakePart(Name+TEXT("_SideL"),Position+FVector(-W*.5f,0,H*.5f),FVector(24,D,H));
    MakePart(Name+TEXT("_SideR"),Position+FVector(W*.5f,0,H*.5f),FVector(24,D,H));
    MakePart(Name+TEXT("_FrontL"),Position+FVector(-(W+Door)*.25f,-D*.5f,H*.5f),
        FVector((W-Door)*.5f,24,H));
    MakePart(Name+TEXT("_FrontR"),Position+FVector((W+Door)*.25f,-D*.5f,H*.5f),
        FVector((W-Door)*.5f,24,H));
    MakePart(Name+TEXT("_DoorTop"),Position+FVector(0,-D*.5f,(H+310.f)*.5f),
        FVector(Door,24,FMath::Max(50.f,H-310.f)));
    // Weather ledge, foundations and retail storefront frames.
    MakePart(Name+TEXT("_Canopy"),Position+FVector(0,-D*.5f-110.f,315.f),
        FVector(W*.52f,240.f,14.f));
    MakePart(Name+TEXT("_Foundation"),Position+FVector(0,0,-15),FVector(W+110,D+110,35));
    for(int32 I=0;I<5;++I)
    {
        const float X=-W*.38f+I*W*.19f;
        MakePart(Name+FString::Printf(TEXT("_WindowSill%02d"),I),
            Position+FVector(X,D*.5f+25,H*.55f),FVector(W*.11f,18,18));
        MakePart(Name+FString::Printf(TEXT("_Lintel%02d"),I),
            Position+FVector(X,D*.5f+25,H*.78f),FVector(W*.11f,18,18));
    }
}
void ANexusCityDistrict::BeginPlay()
{
    Super::BeginPlay();
    // Fallback structures are temporary; each imported GLB is a modular
    // exterior/interior shell that should pass real collision + navigation QA.
    const TCHAR* Names[8]={
        TEXT("Supermarket"),TEXT("PoliceStation"),TEXT("FireStation"),
        TEXT("AirportTerminal"),TEXT("MedievalHall"),TEXT("AlpineVilla"),
        TEXT("GoldMineEntrance"),TEXT("SpaceResearchLab")};
    const FVector Positions[8]={
        FVector(-2950.f,0.f,0.f),FVector(-1000.f,0.f,0.f),
        FVector(1050.f,0.f,0.f),FVector(3100.f,0.f,0.f),
        FVector(-2950.f,2500.f,0.f),FVector(-1000.f,2500.f,0.f),
        FVector(1050.f,2500.f,0.f),FVector(3100.f,2500.f,0.f)};
    const int32 Widths[8]={2200,1700,2500,3600,1800,1700,1400,2600};
    const int32 Depths[8]={1700,1400,1800,2100,1300,1300,1200,2100};
    const int32 Heights[8]={550,860,800,900,1000,800,600,800};
    for(int32 I=0;I<8;++I)
    {
        const FString AssetName=FString::Printf(TEXT("SM_Nexus_%s"),Names[I]);
        const FString ObjectPath=FString::Printf(TEXT("/Game/AAA/Geometry/StoryAreas/%s.%s"),
            *AssetName,*AssetName);
        if(UStaticMesh* Mesh=LoadObject<UStaticMesh>(nullptr,*ObjectPath))
        {
            auto* Building=NewObject<UStaticMeshComponent>(this,
                FName(*FString::Printf(TEXT("DistrictMesh_%02d"),I)));
            Building->SetupAttachment(DistrictRoot);
            Building->SetMobility(EComponentMobility::Static);
            Building->SetStaticMesh(Mesh);
            Building->SetRelativeLocation(Positions[I]);
            Building->SetCollisionProfileName(TEXT("BlockAll"));
            AddInstanceComponent(Building);
            Building->RegisterComponent();
            Architecture.Add(Building);
        }
        else
            CreateFallbackBuilding(FString(Names[I]),Positions[I],Widths[I],Depths[I],Heights[I]);
    }
}
