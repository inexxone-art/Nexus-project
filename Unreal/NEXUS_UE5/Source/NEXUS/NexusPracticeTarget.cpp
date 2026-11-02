#include "NexusPracticeTarget.h"
#include "NexusWorldDirector.h"
#include "Components/StaticMeshComponent.h"
#include "Components/TextRenderComponent.h"
#include "Engine/StaticMesh.h"
#include "EngineUtils.h"
#include "Net/UnrealNetwork.h"

ANexusPracticeTarget::ANexusPracticeTarget()
{
    PrimaryActorTick.bCanEverTick=false;
    bReplicates=true;
    TargetVisual=CreateDefaultSubobject<UStaticMeshComponent>(TEXT("PracticeRangeDummy"));
    RootComponent=TargetVisual;
    TargetVisual->SetCollisionProfileName(TEXT("BlockAll"));
    ScoreDisplay=CreateDefaultSubobject<UTextRenderComponent>(TEXT("TrainingScore"));
    ScoreDisplay->SetupAttachment(RootComponent);
    ScoreDisplay->SetRelativeLocation(FVector(0,0,140.f));
    ScoreDisplay->SetWorldSize(32.f);
}
void ANexusPracticeTarget::BeginPlay()
{
    Super::BeginPlay();
    if(auto* TargetMesh=LoadObject<UStaticMesh>(nullptr,
        TEXT("/Game/AAA/Geometry/Props/SM_Nexus_PracticeTarget.SM_Nexus_PracticeTarget")))
        TargetVisual->SetStaticMesh(TargetMesh);
    else
    {
        TargetVisual->SetStaticMesh(LoadObject<UStaticMesh>(nullptr,
            TEXT("/Engine/BasicShapes/Cylinder.Cylinder")));
        TargetVisual->SetRelativeScale3D(FVector(1.5f,1.5f,1.9f));
    }
    OnRep_Score();
}
void ANexusPracticeTarget::ReceivePracticeHit(float ScorePoints)
{
    if(!HasAuthority() || ScorePoints<=0.f)return;
    Hits=FMath::Min(Hits+1,999);
    if(!bTrainingCompleted && Hits>=5)
    {
        bTrainingCompleted=true;
        for(TActorIterator<ANexusWorldDirector> It(GetWorld());It;++It)
        {
            It->UnlockTopic(TEXT("military_training_completed"));
            break;
        }
    }
    OnRep_Score();
    ForceNetUpdate();
}
void ANexusPracticeTarget::OnRep_Score()
{
    if(ScoreDisplay)
        ScoreDisplay->SetText(FText::FromString(bTrainingCompleted?
            TEXT("AUSBILDUNG BESTANDEN") :
            FString::Printf(TEXT("SCHIESSTAND  %d / 5"),FMath::Min(Hits,5))));
}
void ANexusPracticeTarget::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const
{
    Super::GetLifetimeReplicatedProps(Out);
    DOREPLIFETIME(ANexusPracticeTarget,Hits);
    DOREPLIFETIME(ANexusPracticeTarget,bTrainingCompleted);
}
