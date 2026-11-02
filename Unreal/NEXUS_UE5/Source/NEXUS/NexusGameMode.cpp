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
void ANexusGameMode::EnterVehicle(ANexusVehicle* Vehicle,ANexusExplorer* Passenger)
{
    if(!Vehicle || !Passenger || Vehicle->Driver)return;
    APlayerController* PC=Cast<APlayerController>(Passenger->GetController());
    if(!PC || PC->GetPawn()!=Passenger)return;
    SeatedFootPawns.Add(PC,Passenger);
    Passenger->SetActorHiddenInGame(true);
    Passenger->SetActorEnableCollision(false);
    Passenger->GetCharacterMovement()->DisableMovement();
    Vehicle->SetOwner(PC);
    PC->Possess(Vehicle);
    Vehicle->SetDriver(PC);
    if(Director)Director->RadioMessage=TEXT("FAHRT: W/S Gas | A/D lenken | F aussteigen | E Bergung.");
}
void ANexusGameMode::ExitVehicle(ANexusVehicle* Vehicle)
{
    if(!Vehicle)return;
    APlayerController* PC=Vehicle->Driver;
    if(!PC || PC->GetPawn()!=Vehicle)return;
    ANexusExplorer* Foot=SeatedFootPawns.FindRef(PC);
    if(!Foot)return;
    Vehicle->SetDriver(nullptr);
    Vehicle->SetOwner(nullptr);
    Foot->SetActorLocation(Vehicle->GetActorLocation()+Vehicle->GetActorRightVector()*330.f+FVector(0,0,80));
    Foot->SetActorEnableCollision(true);
    Foot->SetActorHiddenInGame(false);
    Foot->GetCharacterMovement()->SetMovementMode(MOVE_Walking);
    PC->Possess(Foot);
    SeatedFootPawns.Remove(PC);
}
void ANexusGameMode::Interact(ANexusExplorer* Player)
{
    if(!Director || !Player)return;
    if(Director->RescueTruck && FVector::Dist(Player->GetActorLocation(),Director->RescueTruck->GetActorLocation())<550.f)
    { EnterVehicle(Director->RescueTruck,Player);return; }
    if(Director->RescueHelicopter && FVector::Dist(Player->GetActorLocation(),Director->RescueHelicopter->GetActorLocation())<700.f)
    { EnterVehicle(Director->RescueHelicopter,Player);return; }
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

void ANexusGameMode::PostLogin(APlayerController* NewPlayer)
{
    Super::PostLogin(NewPlayer);
    if(!NewPlayer || !HasAuthority())return;
    ANexusExplorer* NewExplorer=Cast<ANexusExplorer>(NewPlayer->GetPawn());
    if(!NewExplorer)
    {
        NewExplorer=GetWorld()->SpawnActor<ANexusExplorer>(ANexusExplorer::StaticClass(),
            FVector(-7300.f+float(GetNumPlayers())*150.f,300.f,2200.f),FRotator::ZeroRotator);
        if(NewExplorer) NewPlayer->Possess(NewExplorer);
    }
    if(NewExplorer)NewExplorer->SetActorLocation(FVector(-7300.f+float(GetNumPlayers())*150.f,310.f,2200.f));
    if(!Explorer)Explorer=NewExplorer;
}
