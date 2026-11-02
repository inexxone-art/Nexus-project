#include "NexusExplorer.h"
#include "Camera/CameraComponent.h"
#include "Components/CapsuleComponent.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "NexusGameMode.h"
#include "NexusWorldDirector.h"
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
    Input->BindAction(TEXT("InspectEvidence"),IE_Pressed,this,&ANexusExplorer::InspectEvidence);
    Input->BindAction(TEXT("ProtectCivilians"),IE_Pressed,this,&ANexusExplorer::ProtectCivilians);
    Input->BindAction(TEXT("SecureEvidence"),IE_Pressed,this,&ANexusExplorer::SecureEvidence);
    Input->BindAction(TEXT("AI_Follow"),IE_Pressed,this,&ANexusExplorer::TeamFollow);
    Input->BindAction(TEXT("AI_Scout"),IE_Pressed,this,&ANexusExplorer::TeamScout);
    Input->BindAction(TEXT("AI_Medic"),IE_Pressed,this,&ANexusExplorer::TeamMedic);
}
void ANexusExplorer::MoveForward(float V) { if (Controller && V!=0) AddMovementInput(GetActorForwardVector(),V); }
void ANexusExplorer::MoveRight(float V) { if (Controller && V!=0) AddMovementInput(GetActorRightVector(),V); }
void ANexusExplorer::LookYaw(float V) { AddControllerYawInput(V); }
void ANexusExplorer::LookPitch(float V) { AddControllerPitchInput(V); }
void ANexusExplorer::Interact() { if(!HasAuthority()) { ServerCommand(0); return; } if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>()) GM->Interact(this); }
void ANexusExplorer::MedicRole() { if(!HasAuthority()) { ServerCommand(1); return; } if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>()) GM->ChooseRole(0); }
void ANexusExplorer::PilotRole() { if(!HasAuthority()) { ServerCommand(2); return; } if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>()) GM->ChooseRole(1); }
void ANexusExplorer::GroundRole() { if(!HasAuthority()) { ServerCommand(3); return; } if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>()) GM->ChooseRole(2); }
void ANexusExplorer::Slot1() { EquipmentSlot=0; }
void ANexusExplorer::Slot2() { EquipmentSlot=1; }
void ANexusExplorer::Slot3() { EquipmentSlot=2; }
void ANexusExplorer::Slot4() { EquipmentSlot=3; }
void ANexusExplorer::SaveProgress() { if(!HasAuthority()) { ServerCommand(4); return; } if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>()) GM->SaveProgress(); }
void ANexusExplorer::LoadProgress() { if(!HasAuthority()) { ServerCommand(5); return; } if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>()) GM->LoadProgress(); }
void ANexusExplorer::MissionApproach() { if(!HasAuthority()) { ServerCommand(6); return; } if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>()) if(GM->Director)GM->Director->TeleportToApproach(this); }

void ANexusExplorer::InspectEvidence()
{
    if(!HasAuthority()){ServerCommand(7);return;}
    if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>())
        if(GM->Director)GM->Director->InvestigateEvidence(GetActorLocation());
}
void ANexusExplorer::ProtectCivilians()
{
    if(!HasAuthority()){ServerCommand(8);return;}
    if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>())
        if(GM->Director)GM->Director->ChooseCampaignOutcome(true);
}
void ANexusExplorer::SecureEvidence()
{
    if(!HasAuthority()){ServerCommand(9);return;}
    if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>())
        if(GM->Director)GM->Director->ChooseCampaignOutcome(false);
}

void ANexusExplorer::ServerCommand_Implementation(uint8 Code)
{
    // Unreal only accepts this Server RPC from the owning player's pawn.
    switch(Code)
    {
        case 0: Interact();break;
        case 1: MedicRole();break;
        case 2: PilotRole();break;
        case 3: GroundRole();break;
        case 4: SaveProgress();break;
        case 5: LoadProgress();break;
        case 6: MissionApproach();break;
        case 7: InspectEvidence();break;
        case 8: ProtectCivilians();break;
        case 9: SecureEvidence();break;
        case 10: TeamFollow();break;
        case 11: TeamScout();break;
        case 12: TeamMedic();break;
        default:break;
    }
}

void ANexusExplorer::TeamFollow()
{
    if(!HasAuthority()){ServerCommand(10);return;}
    if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>())
        if(GM->Director)GM->Director->CommandRescueHelpers(0);
}
void ANexusExplorer::TeamScout()
{
    if(!HasAuthority()){ServerCommand(11);return;}
    if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>())
        if(GM->Director)GM->Director->CommandRescueHelpers(2);
}
void ANexusExplorer::TeamMedic()
{
    if(!HasAuthority()){ServerCommand(12);return;}
    if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>())
        if(GM->Director)GM->Director->CommandRescueHelpers(3);
}
