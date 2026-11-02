#include "NexusAlpineRiver.h"
#include "Components/SceneComponent.h"
#include "ProceduralMeshComponent.h"
#include "Materials/MaterialInterface.h"
#include "Net/UnrealNetwork.h"

ANexusAlpineRiver::ANexusAlpineRiver()
{
    PrimaryActorTick.bCanEverTick=false;
    bReplicates=true;
    bAlwaysRelevant=true;
    RiverRoot=CreateDefaultSubobject<USceneComponent>(TEXT("HydrologyRoot"));
    RootComponent=RiverRoot;
    RiverSurface=CreateDefaultSubobject<UProceduralMeshComponent>(TEXT("FlowingWater"));
    Riverbed=CreateDefaultSubobject<UProceduralMeshComponent>(TEXT("SolidCrossSectionRiverbed"));
    LeftShore=CreateDefaultSubobject<UProceduralMeshComponent>(TEXT("LeftErosionOrDepositionBank"));
    RightShore=CreateDefaultSubobject<UProceduralMeshComponent>(TEXT("RightErosionOrDepositionBank"));
    for(UProceduralMeshComponent* Mesh:{RiverSurface.Get(),Riverbed.Get(),LeftShore.Get(),RightShore.Get()})
    {
        Mesh->SetupAttachment(RiverRoot);
        Mesh->SetMobility(EComponentMobility::Movable);
        Mesh->SetCollisionEnabled(ECollisionEnabled::NoCollision);
    }
    RiverSurface->SetCastShadow(false);
    // Only the sedimentary ground and two shores collide. The transparent
    // surface must NEVER act like a glass floor that blocks swimmers.
    for(UProceduralMeshComponent* Ground:{Riverbed.Get(),LeftShore.Get(),RightShore.Get()})
    {
        Ground->bUseComplexAsSimpleCollision=true;
        Ground->SetCollisionProfileName(TEXT("BlockAll"));
        Ground->SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
    }
}
void ANexusAlpineRiver::BeginPlay()
{
    Super::BeginPlay();
    GenerateRiver();
}
FVector ANexusAlpineRiver::RiverCenterAt(float Alpha) const
{
    const float T=FMath::Clamp(Alpha,0.f,1.f);
    return FVector(FMath::Lerp(-9200.f,9200.f,T),
       610.f*FMath::Sin(T*PI*2.5f)+310.f*FMath::Sin(T*PI*6.5f),
       BaseWaterHeight+RainFloodLevel+30.f*FMath::Sin(T*PI*7.5f));
}
FVector ANexusAlpineRiver::WaterNormalAt(float Alpha) const
{
    const FVector Prev=RiverCenterAt(FMath::Max(0.f,Alpha-.002f));
    const FVector Next=RiverCenterAt(FMath::Min(1.f,Alpha+.002f));
    const FVector Tangent=FVector(Next.X-Prev.X,Next.Y-Prev.Y,0.f).GetSafeNormal();
    // Flow points west -> east; cross(Tangent,Up) points toward right shoreline.
    return FVector::CrossProduct(Tangent,FVector::UpVector).GetSafeNormal();
}
float ANexusAlpineRiver::ErodingOuterSide(float Alpha) const
{
    const float A=PI*2.5f;
    const float B=PI*6.5f;
    // Outer bank is opposite bend-center, inferred from signed curvature.
    const float Curvature=-610.f*A*A*FMath::Sin(Alpha*A)
                         -310.f*B*B*FMath::Sin(Alpha*B);
    // Positive curvature bends left (+Y): outer bank is -Y, the +lateral side.
    return Curvature>=0.f?1.f:-1.f;
}
float ANexusAlpineRiver::BedDepthAt(float Alpha,float Lateral) const
{
    const float Normal=FMath::Clamp(Lateral/FMath::Max(HalfWidth,100.f),-1.f,1.f);
    const float Outer=FMath::Clamp(.5f+.5f*Normal*ErodingOuterSide(Alpha),0.f,1.f);
    const float S=Outer*Outer*(3.f-2.f*Outer);
    // 0.9m on the point-bar side to 5.2m near the cut bank. At high flood,
    // water gets deeper but the geological riverbed stays where it is.
    return FMath::Lerp(90.f,520.f,S);
}
FVector ANexusAlpineRiver::RiverPoint(float Alpha,float Lateral,float Z) const
{
    const FVector Center=RiverCenterAt(Alpha);
    const FVector Normal=WaterNormalAt(Alpha);
    return FVector(Center.X+Normal.X*Lateral,Center.Y+Normal.Y*Lateral,Z);
}
bool ANexusAlpineRiver::SampleWater(const FVector& Position,float& SurfaceZ,
    float& BedZ,FVector& CurrentVelocity,float& LateralOffset) const
{
    SurfaceZ=0.f;BedZ=0.f;CurrentVelocity=FVector::ZeroVector;LateralOffset=0.f;
    if(Position.X < -9200.f || Position.X > 9200.f)return false;
    const float Alpha=FMath::Clamp((Position.X+9200.f)/18400.f,0.f,1.f);
    const FVector Center=RiverCenterAt(Alpha);
    const FVector Normal=WaterNormalAt(Alpha);
    LateralOffset=FVector::DotProduct(Position-Center,Normal);
    if(FMath::Abs(LateralOffset)>FMath::Max(100.f,HalfWidth))return false;
    const float Depth=BedDepthAt(Alpha,LateralOffset);
    SurfaceZ=Center.Z+5.f;
    BedZ=Center.Z-RainFloodLevel-Depth;
    const float Outer=FMath::Clamp(.5f+.5f*(LateralOffset/HalfWidth)*ErodingOuterSide(Alpha),0.f,1.f);
    const FVector Before=RiverCenterAt(FMath::Max(Alpha-.002f,0.f));
    const FVector After=RiverCenterAt(FMath::Min(Alpha+.002f,1.f));
    const FVector Flow=FVector(After.X-Before.X,After.Y-Before.Y,0.f).GetSafeNormal();
    // Convex inner sandbar has the slower current, concave cut-bank the fastest.
    CurrentVelocity=Flow*(FlowMetersPerSecond*100.f)*FMath::Lerp(.55f,1.5f,Outer);
    return true;
}
FVector ANexusAlpineRiver::WaterFlowAt(const FVector& WorldLocation) const
{
    float Surface,Bed,Lateral;
    FVector Current;
    return SampleWater(WorldLocation,Surface,Bed,Current,Lateral)?Current:FVector::ZeroVector;
}
void ANexusAlpineRiver::CreateGrid(UProceduralMeshComponent* Target,int32 Mode)
{
    if(!Target)return;
    // Mode 0: noncolliding water surface; 1: solid cross-section floor;
    // 2: left bank; 3: right bank. Material vertex colors distinguish
    // erosion (slate) from deposition (beige sand).
    const int32 Longitudinal=FMath::Clamp(SegmentCount,16,300);
    const int32 LateralSteps=(Mode==1?16:4);
    const int32 RowSize=LateralSteps+1;
    const float W=FMath::Max(100.f,HalfWidth);
    TArray<FVector> Vertices,Normals;
    TArray<FVector2D> UVs;
    TArray<int32> Triangles;
    TArray<FColor> Colors;
    TArray<FProcMeshTangent> Tangents;
    Vertices.Reserve((Longitudinal+1)*RowSize);
    Triangles.Reserve(Longitudinal*LateralSteps*6);
    for(int32 X=0;X<=Longitudinal;++X)
    {
        const float Alpha=float(X)/float(Longitudinal);
        const FVector Center=RiverCenterAt(Alpha);
        const float OuterSign=ErodingOuterSide(Alpha);
        const float TerrainWater=Center.Z-RainFloodLevel;
        for(int32 Y=0;Y<=LateralSteps;++Y)
        {
            const float F=float(Y)/float(LateralSteps);
            float Offset=FMath::Lerp(-W,W,F);
            if(Mode==2)Offset=FMath::Lerp(-W-900.f,-W,F);
            if(Mode==3)Offset=FMath::Lerp(W,W+900.f,F);
            float Z=Center.Z+5.f;
            if(Mode==1) Z=TerrainWater-BedDepthAt(Alpha,Offset);
            if(Mode==2 || Mode==3)
            {
                const float Near=Mode==2?-W:W;
                const float Away=Mode==2?-W-900.f:W+900.f;
                const float BankF=FMath::Clamp((Offset-Near)/(Away-Near),0.f,1.f);
                const bool bOuter=(Near*OuterSign>0.f);
                const float BankLift=(bOuter?FMath::Pow(BankF,.24f):FMath::Pow(BankF,1.85f))*420.f;
                Z=TerrainWater-BedDepthAt(Alpha,Near)+BankLift;
            }
            Vertices.Add(RiverPoint(Alpha,Offset,Z));
            Normals.Add(FVector::UpVector);
            UVs.Add(FVector2D(Alpha*28.f,F*5.f));
            const bool bDeposit=(Offset*OuterSign)<0.f;
            Colors.Add(Mode==0?FColor(14,71,91,255):
                    (bDeposit?FColor(199,157,96,255):FColor(79,87,91,255)));
            Tangents.Add(FProcMeshTangent(1.f,0.f,0.f));
        }
        if(X==Longitudinal)continue;
        for(int32 Y=0;Y<LateralSteps;++Y)
        {
            const int32 A=X*RowSize+Y;
            const int32 B=A+RowSize;
            Triangles.Append({A,A+1,B,A+1,B+1,B});
        }
    }
    Target->ClearAllMeshSections();
    const bool bCollide=(Mode!=0);
    Target->CreateMeshSection(0,Vertices,Triangles,Normals,UVs,Colors,Tangents,bCollide);
    const TCHAR* Material=(Mode==0?TEXT("/Game/AAA/Materials/M_NexusRiverWater.M_NexusRiverWater")
        :TEXT("/Game/AAA/Materials/M_NexusRiverbank.M_NexusRiverbank"));
    if(auto* Asset=LoadObject<UMaterialInterface>(nullptr,Material))Target->SetMaterial(0,Asset);
    else if(Mode!=0)
        if(auto* Rock=LoadObject<UMaterialInterface>(nullptr,
            TEXT("/Game/AAA/Materials/M_AlpineRock.M_AlpineRock")))Target->SetMaterial(0,Rock);
}
void ANexusAlpineRiver::GenerateRiver()
{
    CreateGrid(RiverSurface,0);
    CreateGrid(Riverbed,1);
    CreateGrid(LeftShore,2);
    CreateGrid(RightShore,3);
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
