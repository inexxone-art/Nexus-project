#include "NexusExplorer.h"
#include "Camera/CameraComponent.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "NexusGameMode.h"
#include "Components/InputComponent.h"

ANexusExplorer::ANexusExplorer()
{
    PrimaryActorTick.bCanEverTick = false;
    ViewCamera = CreateDefaultSubobject<UCameraComponent>(TEXT("FirstPersonCamera"));
    ViewCamera->SetupAttachment(GetCapsuleComponent());
    ViewCamera->SetRelativeLocation(FVector(0,0,66));
    ViewCamera->bUsePawnControlRotation = true;
    GetCharacterMovement()->MaxWalkSpeed = 630.f;
    GetCharacterMovement()->JumpZVelocity = 570.f;
    bUseControllerRotationYaw = true;
}
void ANexusExplorer::SetupPlayerInputComponent(UInputComponent* Input)
{
    Super::SetupPlayerInputComponent(Input);
    Input->BindAxis(TEXT("MoveForward"),this,&ANexusExplorer::MoveForward);
    Input->BindAxis(TEXT("MoveRight"),this,&ANexusExplorer::MoveRight);
    Input->BindAxis(TEXT("Turn"),this,&ANexusExplorer::LookYaw);
    Input->BindAxis(TEXT("LookUp"),this,&ANexusExplorer::LookPitch);
    Input->BindAction(TEXT("Jump"),IE_Pressed,this,&ACharacter::Jump);
    Input->BindAction(TEXT("Interact"),IE_Pressed,this,&ANexusExplorer::Interact);
    Input->BindAction(TEXT("RoleMedic"),IE_Pressed,this,&ANexusExplorer::MedicRole);
    Input->BindAction(TEXT("RolePilot"),IE_Pressed,this,&ANexusExplorer::PilotRole);
    Input->BindAction(TEXT("RoleGround"),IE_Pressed,this,&ANexusExplorer::GroundRole);
    Input->BindAction(TEXT("Tool1"),IE_Pressed,this,&ANexusExplorer::Slot1);
    Input->BindAction(TEXT("Tool2"),IE_Pressed,this,&ANexusExplorer::Slot2);
    Input->BindAction(TEXT("Tool3"),IE_Pressed,this,&ANexusExplorer::Slot3);
    Input->BindAction(TEXT("Tool4"),IE_Pressed,this,&ANexusExplorer::Slot4);
    Input->BindAction(TEXT("SaveProgress"),IE_Pressed,this,&ANexusExplorer::SaveProgress);
    Input->BindAction(TEXT("LoadProgress"),IE_Pressed,this,&ANexusExplorer::LoadProgress);
    Input->BindAction(TEXT("MissionApproach"),IE_Pressed,this,&ANexusExplorer::MissionApproach);
}
void ANexusExplorer::MoveForward(float V) { if (Controller && V!=0) AddMovementInput(GetActorForwardVector(),V); }
void ANexusExplorer::MoveRight(float V) { if (Controller && V!=0) AddMovementInput(GetActorRightVector(),V); }
void ANexusExplorer::LookYaw(float V) { AddControllerYawInput(V); }
void ANexusExplorer::LookPitch(float V) { AddControllerPitchInput(V); }
void ANexusExplorer::Interact() { if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>()) GM->Interact(this); }
void ANexusExplorer::MedicRole() { if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>()) GM->ChooseRole(0); }
void ANexusExplorer::PilotRole() { if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>()) GM->ChooseRole(1); }
void ANexusExplorer::GroundRole() { if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>()) GM->ChooseRole(2); }
void ANexusExplorer::Slot1() { EquipmentSlot=0; }
void ANexusExplorer::Slot2() { EquipmentSlot=1; }
void ANexusExplorer::Slot3() { EquipmentSlot=2; }
void ANexusExplorer::Slot4() { EquipmentSlot=3; }
void ANexusExplorer::SaveProgress() { if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>()) GM->SaveProgress(); }
void ANexusExplorer::LoadProgress() { if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>()) GM->LoadProgress(); }
void ANexusExplorer::MissionApproach() { if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>()) GM->GoToApproach(); }
