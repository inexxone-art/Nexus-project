#include "NexusCompanion.h"
#include "NexusExplorer.h"
#include "AIController.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "Components/StaticMeshComponent.h"
#include "Components/TextRenderComponent.h"
#include "EngineUtils.h"
#include "Net/UnrealNetwork.h"
#include "Engine/World.h"
#include "UObject/ConstructorHelpers.h"

ANexusCompanion::ANexusCompanion()
{
    PrimaryActorTick.bCanEverTick=true;
    bReplicates=true;
    SetReplicateMovement(true);
    AutoPossessAI=EAutoPossessAI::PlacedInWorldOrSpawned;
    AIControllerClass=AAIController::StaticClass();
    GetCharacterMovement()->MaxWalkSpeed=470.f;
    RoleMarker=CreateDefaultSubobject<UTextRenderComponent>(TEXT("AllyHUDMarker"));
    RoleMarker->SetupAttachment(RootComponent);
    RoleMarker->SetRelativeLocation(FVector(0,0,185.f));
    RoleMarker->SetWorldSize(42.f);
    RoleMarker->SetText(FText::FromString(TEXT("KI-RETTUNGSTEAM")));
}
void ANexusCompanion::BeginPlay()
{
    Super::BeginPlay();
    if(HasAuthority() && !GetController())SpawnDefaultController();
}
void ANexusCompanion::AssignOrder(ENexusSupportOrder NewOrder)
{
    if(!HasAuthority())return;
    Order=NewOrder;
    const TCHAR* TextValue=TEXT("FOLGEN");
    switch(Order)
    {
        case ENexusSupportOrder::Hold:TextValue=TEXT("POSITION HALTEN");break;
        case ENexusSupportOrder::Scout:TextValue=TEXT("AUFKLAEREN");break;
        case ENexusSupportOrder::Medic:TextValue=TEXT("SANITAETER");break;
        case ENexusSupportOrder::Repair:TextValue=TEXT("TECHNIKER");break;
        default:break;
    }
    RoleMarker->SetText(FText::FromString(FString::Printf(TEXT("%s | %s"),*Callsign.ToString(),TextValue)));
}
void ANexusCompanion::Tick(float Dt)
{
    Super::Tick(Dt);
    if(!HasAuthority() || !GetWorld())return;
    const float Now=GetWorld()->GetTimeSeconds();
    if(Now<NextThinkTime)return;
    NextThinkTime=Now+.65f;
    auto* Controller=Cast<AAIController>(GetController());
    if(!Controller)return;
    if(Order==ENexusSupportOrder::Hold)
    {
        Controller->StopMovement();
        return;
    }
    ANexusExplorer* Nearest=nullptr;
    float Best=FLT_MAX;
    for(TActorIterator<ANexusExplorer> It(GetWorld());It;++It)
    {
        auto* Player=*It;
        if(!Player || Player->IsHidden())continue;
        const float D=FVector::DistSquared2D(Player->GetActorLocation(),GetActorLocation());
        if(D<Best){Nearest=Player;Best=D;}
    }
    if(!Nearest){Controller->StopMovement();return;}
    if(Order==ENexusSupportOrder::Scout)
    {
        // Guard a vantage point toward the canyon, not a random NPC waypoint.
        const FVector Target(4700.f,1200.f,2100.f);
        Controller->MoveToLocation(Target,240.f);
    }
    else
    {
        const float Radius=Order==ENexusSupportOrder::Medic?220.f:350.f;
        if(Best>Radius*Radius)Controller->MoveToActor(Nearest,Radius);
        else Controller->StopMovement();
    }
}
void ANexusCompanion::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const
{
    Super::GetLifetimeReplicatedProps(Out);
    DOREPLIFETIME(ANexusCompanion,Order);
    DOREPLIFETIME(ANexusCompanion,Callsign);
}
