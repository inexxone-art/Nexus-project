#include "NexusGameMode.h"
#include "NexusWorldDirector.h"
#include "NexusExplorer.h"
#include "NexusVehicle.h"
#include "NexusHUD.h"
#include "Engine/World.h"
#include "GameFramework/PlayerController.h"
#include "GameFramework/CharacterMovementComponent.h"

ANexusGameMode::ANexusGameMode()
{
    DefaultPawnClass=ANexusExplorer::StaticClass();
    HUDClass=ANexusHUD::StaticClass();
}
void ANexusGameMode::StartPlay()
{
    Super::StartPlay();
    if(!Director)Director=GetWorld()->SpawnActor<ANexusWorldDirector>();
    if(APlayerController* PC=GetWorld()->GetFirstPlayerController())
    {
        Explorer=Cast<ANexusExplorer>(PC->GetPawn());
        if(!Explorer)
        {
            Explorer=GetWorld()->SpawnActor<ANexusExplorer>(FVector(-7300,310,2200),FRotator::ZeroRotator);
            if(Explorer)PC->Possess(Explorer);
        }
        if(Explorer)Director->TeleportToApproach(Explorer);
    }
}
void ANexusGameMode::EnterVehicle(ANexusVehicle* Vehicle)
{
    if(!Vehicle || !Explorer)return;
    APlayerController* PC=GetWorld()->GetFirstPlayerController();
    if(!PC || PC->GetPawn()!=Explorer)return;
    Explorer->SetActorHiddenInGame(true);
    Explorer->SetActorEnableCollision(false);
    Explorer->GetCharacterMovement()->DisableMovement();
    PC->Possess(Vehicle);
    Vehicle->SetDriver(PC);
    if(Director)Director->RadioMessage=TEXT("FAHRT: W/S Gas | A/D lenken | F aussteigen | E Bergung.");
}
void ANexusGameMode::ExitVehicle(ANexusVehicle* Vehicle)
{
    if(!Vehicle || !Explorer)return;
    auto* PC=GetWorld()->GetFirstPlayerController();
    if(!PC || PC->GetPawn()!=Vehicle)return;
    Vehicle->SetDriver(nullptr);
    Explorer->SetActorLocation(Vehicle->GetActorLocation()+Vehicle->GetActorRightVector()*330.f+FVector(0,0,80));
    Explorer->SetActorEnableCollision(true);
    Explorer->SetActorHiddenInGame(false);
    Explorer->GetCharacterMovement()->SetMovementMode(MOVE_Walking);
    PC->Possess(Explorer);
}
void ANexusGameMode::Interact(ANexusExplorer* Player)
{
    if(!Director || !Player)return;
    if(Director->RescueTruck && FVector::Dist(Player->GetActorLocation(),Director->RescueTruck->GetActorLocation())<550.f)
    { EnterVehicle(Director->RescueTruck);return; }
    if(Director->RescueHelicopter && FVector::Dist(Player->GetActorLocation(),Director->RescueHelicopter->GetActorLocation())<700.f)
    { EnterVehicle(Director->RescueHelicopter);return; }
    Director->TryInteract(Player);
}
bool ANexusGameMode::InteractVehicle(ANexusVehicle* Vehicle)
{
    return Director && Director->TryVehicleRescue(Vehicle);
}
void ANexusGameMode::ChooseRole(int32 Choice)
{
    if(!Director)return;
    Director->ChooseRescueRole(Choice==0?ENexusRescueRole::Medic:
      Choice==1?ENexusRescueRole::Pilot:ENexusRescueRole::GroundSearch);
}
void ANexusGameMode::SaveProgress(){if(Director)Director->SaveProgress();}
void ANexusGameMode::LoadProgress(){if(Director)Director->LoadProgress();}
void ANexusGameMode::GoToApproach(){if(Director && Explorer)Director->TeleportToApproach(Explorer);}
