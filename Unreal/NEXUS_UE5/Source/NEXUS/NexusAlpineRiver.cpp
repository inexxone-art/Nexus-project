#include "NexusAlpineRiver.h"
#include "Components/SceneComponent.h"
#include "ProceduralMeshComponent.h"
#include "Materials/MaterialInterface.h"
#include "Engine/World.h"
#include "Net/UnrealNetwork.h"

ANexusAlpineRiver::ANexusAlpineRiver()
{
    PrimaryActorTick.bCanEverTick=true;
    bReplicates=true;
    RiverRoot=CreateDefaultSubobject<USceneComponent>(TEXT("RiverRoot"));
    RootComponent=RiverRoot;
    RiverSurface=CreateDefaultSubobject<UProceduralMeshComponent>(TEXT("MeanderingRiverWater"));
    LeftShore=CreateDefaultSubobject<UProceduralMeshComponent>(TEXT("RockyLeftRiverbank"));
    RightShore=CreateDefaultSubobject<UProceduralMeshComponent>(TEXT("RockyRightRiverbank"));
    for(auto* Mesh:{RiverSurface.Get(),LeftShore.Get(),RightShore.Get()})
    {
        Mesh->SetupAttachment(RiverRoot);
        Mesh->SetMobility(EComponentMobility::Static);
        Mesh->SetCollisionEnabled(ECollisionEnabled::NoCollision);
        Mesh->SetCastShadow(false);
    }
}
void ANexusAlpineRiver::BeginPlay()
{
    Super::BeginPlay();
    GenerateRiver();
}
FVector ANexusAlpineRiver::RiverCenterAt(float Alpha) const
{
    const float X=FMath::Lerp(-9200.f,9200.f,Alpha);
    const float Y=610.f*FMath::Sin(Alpha*PI*2.5f)+310.f*FMath::Sin(Alpha*PI*6.5f);
    const float Z=BaseWaterHeight+RainFloodLevel
                +30.f*FMath::Sin(Alpha*PI*7.5f);
    return FVector(X,Y,Z);
}
void ANexusAlpineRiver::GenerateStrip(
    UProceduralMeshComponent* Target,float Inner,float Outer,float HeightOffset,bool bWater)
{
    if(!Target)return;
    const int32 N=FMath::Clamp(SegmentCount,16,300);
    TArray<FVector> Vertices,Normals;
    TArray<FVector2D> UVs;
    TArray<int32> Triangles;
    TArray<FColor> Colors;
    TArray<FProcMeshTangent> Tangents;
    Vertices.Reserve((N+1)*2);
    Triangles.Reserve(N*6);
    for(int32 I=0;I<=N;I++)
    {
        const float Alpha=float(I)/float(N);
        const FVector Center=RiverCenterAt(Alpha);
        const FVector Before=RiverCenterAt(FMath::Clamp(Alpha-.002f,0.f,1.f));
        const FVector After=RiverCenterAt(FMath::Clamp(Alpha+.002f,0.f,1.f));
        const FVector Tangent=(After-Before).GetSafeNormal();
        const FVector Cross=FVector::CrossProduct(Tangent,FVector::UpVector).GetSafeNormal();
        const FVector From=Center+Cross*Inner+FVector(0,0,HeightOffset);
        const FVector To=Center+Cross*Outer+FVector(0,0,HeightOffset);
        Vertices.Add(From);
        Vertices.Add(To);
        const float U=Alpha*18.4f;
        UVs.Add(FVector2D(U,0.f));UVs.Add(FVector2D(U,4.f));
        Normals.Add(FVector::UpVector);Normals.Add(FVector::UpVector);
        Colors.Add(FColor(25,64,72,255));Colors.Add(FColor(33,82,85,255));
        Tangents.Add(FProcMeshTangent(Tangent.X,Tangent.Y,Tangent.Z));
        Tangents.Add(FProcMeshTangent(Tangent.X,Tangent.Y,Tangent.Z));
        if(I<N)
        {
            const int32 Start=I*2;
            // double-sided face indices for predictable rendering along valley.
            Triangles.Add(Start);Triangles.Add(Start+1);Triangles.Add(Start+2);
            Triangles.Add(Start+1);Triangles.Add(Start+3);Triangles.Add(Start+2);
        }
    }
    Target->ClearAllMeshSections();
    Target->CreateMeshSection(0,Vertices,Triangles,Normals,UVs,Colors,Tangents,false);
    if(bWater)
    {
        // Replace this with a production transparent PBR + whitewater material.
        UMaterialInterface* Water=LoadObject<UMaterialInterface>(nullptr,
            TEXT("/Game/AAA/Materials/M_NexusRiverWater.M_NexusRiverWater"));
        if(!Water)Water=LoadObject<UMaterialInterface>(nullptr,
            TEXT("/Game/AAA/Materials/M_RiverMud.M_RiverMud"));
        if(Water)Target->SetMaterial(0,Water);
    }
    else
    {
        UMaterialInterface* Bank=LoadObject<UMaterialInterface>(nullptr,
            TEXT("/Game/AAA/Materials/M_AlpineRock.M_AlpineRock"));
        if(Bank)Target->SetMaterial(0,Bank);
    }
}
void ANexusAlpineRiver::GenerateRiver()
{
    // Water ribbon around 23 m wide plus near-bank geological transitions.
    const float Width=FMath::Clamp(HalfWidth,400.f,2200.f);
    GenerateStrip(RiverSurface,-Width,Width,5.f,true);
    GenerateStrip(LeftShore,-Width-900.f,-Width,-28.f,false);
    GenerateStrip(RightShore,Width,Width+900.f,-28.f,false);
}
void ANexusAlpineRiver::SetFloodSeverity(int32 Severity)
{
    if(!HasAuthority())return;
    RainFloodLevel=FMath::Lerp(0.f,220.f,FMath::Clamp(Severity,0,100)/100.f);
    GenerateRiver();
    ForceNetUpdate();
}
void ANexusAlpineRiver::OnRep_Flood(){GenerateRiver();}
void ANexusAlpineRiver::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const
{
    Super::GetLifetimeReplicatedProps(Out);
    DOREPLIFETIME(ANexusAlpineRiver,RainFloodLevel);
}
FVector ANexusAlpineRiver::WaterFlowAt(const FVector& WorldLocation) const
{
    const float Alpha=FMath::Clamp((WorldLocation.X+9200.f)/18400.f,0.f,1.f);
    return (RiverCenterAt(FMath::Min(1.f,Alpha+.002f))-
            RiverCenterAt(FMath::Max(0.f,Alpha-.002f))).GetSafeNormal()*
            (FlowMetersPerSecond*100.f);
}
void ANexusAlpineRiver::Tick(float DeltaSeconds)
{
    Super::Tick(DeltaSeconds);
    // Geometry remains stable for performance. Surface movement is supplied
    // by M_NexusRiverWater, once authored in the UE material graph.
    SurfaceTime+=DeltaSeconds;
}
