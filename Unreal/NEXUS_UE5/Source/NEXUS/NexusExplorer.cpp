#include "NexusExplorer.h"
#include "Camera/CameraComponent.h"
#include "GameFramework/SpringArmComponent.h"
#include "Components/CapsuleComponent.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "NexusGameMode.h"
#include "NexusWorldDirector.h"
#include "NexusStarterHome.h"
#include "NexusWeaponComponent.h"
#include "Components/StaticMeshComponent.h"
#include "NexusAlpineRiver.h"
#include "EngineUtils.h"
#include "Net/UnrealNetwork.h"
#include "Components/InputComponent.h"

ANexusExplorer::ANexusExplorer()
{
    PrimaryActorTick.bCanEverTick = true;
    bReplicates=true;
    SetReplicateMovement(true);
    Weapons=CreateDefaultSubobject<UNexusWeaponComponent>(TEXT("NEXUS_WEAPON_ARSENAL"));
    ViewCamera = CreateDefaultSubobject<UCameraComponent>(TEXT("FirstPersonCamera"));
    ViewCamera->SetupAttachment(GetCapsuleComponent());
    ViewCamera->SetRelativeLocation(FVector(0,0,66));
    ViewCamera->bUsePawnControlRotation = true;
    ThirdPersonArm=CreateDefaultSubobject<USpringArmComponent>(TEXT("ThirdPersonCameraBoom"));
    ThirdPersonArm->SetupAttachment(GetCapsuleComponent());
    ThirdPersonArm->SetRelativeLocation(FVector(0.f,0.f,78.f));
    ThirdPersonArm->TargetArmLength=390.f;
    ThirdPersonArm->SocketOffset=FVector(0.f,65.f,25.f);
    ThirdPersonArm->bUsePawnControlRotation=true;
    ThirdPersonArm->bDoCollisionTest=true;
    ThirdPersonCamera=CreateDefaultSubobject<UCameraComponent>(TEXT("ThirdPersonCamera"));
    ThirdPersonCamera->SetupAttachment(ThirdPersonArm,USpringArmComponent::SocketName);
    ThirdPersonCamera->SetActive(false);
    FirstPersonWeaponVisual=CreateDefaultSubobject<UStaticMeshComponent>(TEXT("FirstPersonWeaponModel"));
    FirstPersonWeaponVisual->SetupAttachment(ViewCamera);
    FirstPersonWeaponVisual->SetRelativeLocation(FVector(85.f,22.f,-38.f));
    FirstPersonWeaponVisual->SetRelativeRotation(FRotator(0.f,-4.f,0.f));
    FirstPersonWeaponVisual->SetCollisionEnabled(ECollisionEnabled::NoCollision);
    FirstPersonWeaponVisual->SetCastShadow(false);
    FirstPersonWeaponVisual->SetVisibility(false);
    ThirdPersonWeaponVisual=CreateDefaultSubobject<UStaticMeshComponent>(TEXT("ThirdPersonWeaponModel"));
    ThirdPersonWeaponVisual->SetupAttachment(GetCapsuleComponent());
    ThirdPersonWeaponVisual->SetRelativeLocation(FVector(45.f,33.f,94.f));
    ThirdPersonWeaponVisual->SetCollisionEnabled(ECollisionEnabled::NoCollision);
    ThirdPersonWeaponVisual->SetVisibility(false);
    // Underwater camera color grading is applied only to the owning player.
    // Local post-process is disabled until the eyes actually enter water.
    ViewCamera->PostProcessSettings.bOverride_SceneColorTint=true;
    ViewCamera->PostProcessSettings.SceneColorTint=FLinearColor(.28f,.62f,.76f,1.f);
    ViewCamera->PostProcessSettings.bOverride_VignetteIntensity=true;
    ViewCamera->PostProcessSettings.VignetteIntensity=.35f;
    ViewCamera->PostProcessBlendWeight=0.f;
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
    Input->BindAction(TEXT("Jump"),IE_Pressed,this,&ANexusExplorer::HandleJumpPressed);
    Input->BindAction(TEXT("Jump"),IE_Released,this,&ANexusExplorer::HandleJumpReleased);
    Input->BindAction(TEXT("SwimDescend"),IE_Pressed,this,&ANexusExplorer::StartDive);
    Input->BindAction(TEXT("SwimDescend"),IE_Released,this,&ANexusExplorer::StopDive);
    Input->BindAction(TEXT("Interact"),IE_Pressed,this,&ANexusExplorer::Interact);
    Input->BindAction(TEXT("WeaponFire"),IE_Pressed,this,&ANexusExplorer::FireWeapon);
    Input->BindAction(TEXT("WeaponReload"),IE_Pressed,this,&ANexusExplorer::ReloadWeapon);
    Input->BindAction(TEXT("WeaponCycle"),IE_Pressed,this,&ANexusExplorer::NextWeapon);
    Input->BindAction(TEXT("TogglePinboard"),IE_Pressed,this,&ANexusExplorer::TogglePinboard);
    Input->BindAction(TEXT("TogglePhone"),IE_Pressed,this,&ANexusExplorer::TogglePhone);
    Input->BindAction(TEXT("SellGold"),IE_Pressed,this,&ANexusExplorer::SellGoldFromPhone);
    Input->BindAction(TEXT("BuyRental"),IE_Pressed,this,&ANexusExplorer::BuyRentalFromPhone);
    Input->BindAction(TEXT("ResearchSciFi"),IE_Pressed,this,&ANexusExplorer::ResearchSciFiFromPhone);
    Input->BindAction(TEXT("ToggleCamera"),IE_Pressed,this,&ANexusExplorer::ToggleCamera);
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
void ANexusExplorer::FireWeapon()
{
    if(Weapons && !bPhoneOpen && !bPinboardOpen)
    {
        Weapons->Fire();
        WeaponRecoilAlpha=1.f; // local visual-only recoil
    }
}
void ANexusExplorer::ReloadWeapon()
{
    if(Weapons)
    {
        Weapons->Reload();
        WeaponReloadAlpha=1.f; // local hand/weapon dip, pending humanoid retarget
    }
}
void ANexusExplorer::NextWeapon(){if(Weapons)Weapons->SelectNextWeapon();}
void ANexusExplorer::RefreshWeaponVisual()
{
    if(!Weapons || !IsLocallyControlled())return;
    const int32 I=Weapons->EquippedIndex;
    if(I!=CachedWeaponVisualIndex)
    {
        CachedWeaponVisualIndex=I;
        const TCHAR* MeshNames[6]={
            TEXT("SM_Nexus_Sidearm"),TEXT("SM_Nexus_Carbine"),
            TEXT("SM_Nexus_Precision"),TEXT("SM_Nexus_CompactRifle"),
            TEXT("SM_Nexus_PulseCaster"),TEXT("SM_Nexus_ArcEmitter")};
        UStaticMesh* Model=nullptr;
        if(I>=0 && I<6)
        {
            const FString Path=FString::Printf(TEXT("/Game/AAA/Geometry/Props/%s.%s"),
                MeshNames[I],MeshNames[I]);
            Model=LoadObject<UStaticMesh>(nullptr,*Path);
        }
        FirstPersonWeaponVisual->SetStaticMesh(Model);
        ThirdPersonWeaponVisual->SetStaticMesh(Model);
    }
    const bool bVisible=FirstPersonWeaponVisual->GetStaticMesh()!=nullptr;
    FirstPersonWeaponVisual->SetVisibility(bVisible && !bThirdPersonView);
    ThirdPersonWeaponVisual->SetVisibility(bVisible && bThirdPersonView);
}
void ANexusExplorer::ToggleCamera()
{
    // Camera choice is local to this pawn: do not replicate a viewing preference.
    bThirdPersonView=!bThirdPersonView;
    ViewCamera->SetActive(!bThirdPersonView);
    ThirdPersonCamera->SetActive(bThirdPersonView);
}
void ANexusExplorer::TogglePinboard()
{
    if(!IsLocallyControlled())return;
    for(TActorIterator<ANexusStarterHome> It(GetWorld());It;++It)
        if(It->IsNearPinboard(GetActorLocation()))
        {
            bPinboardOpen=!bPinboardOpen;
            return;
        }
    bPinboardOpen=false;
}
void ANexusExplorer::TogglePhone()
{
    if(!IsLocallyControlled())return;
    bPhoneOpen=!bPhoneOpen;
}
void ANexusExplorer::SellGoldFromPhone()
{
    if(!IsLocallyControlled() || !bPhoneOpen)return;
    if(!HasAuthority()){ServerCommand(13);return;}
    if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>())
        if(GM->Director)GM->Director->SellGoldOre();
}
void ANexusExplorer::BuyRentalFromPhone()
{
    if(!IsLocallyControlled() || !bPhoneOpen)return;
    if(!HasAuthority()){ServerCommand(14);return;}
    if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>())
        if(GM->Director)GM->Director->PurchaseRentalProperty();
}
void ANexusExplorer::ResearchSciFiFromPhone()
{
    if(!IsLocallyControlled() || !bPhoneOpen)return;
    if(!HasAuthority()){ServerCommand(15);return;}
    if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>())
        if(GM->Director)GM->Director->TryResearchSciFi(this);
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
        // The UI check is local. Server validates stock/funds and records all changes.
        case 13: if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>())
                     if(GM->Director)GM->Director->SellGoldOre();break;
        case 14: if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>())
                     if(GM->Director)GM->Director->PurchaseRentalProperty();break;
        case 15: if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>())
                     if(GM->Director)GM->Director->TryResearchSciFi(this);break;
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

void ANexusExplorer::BeginPlay()
{
    Super::BeginPlay();
    OxygenSeconds=DiveDurationSeconds;
}
void ANexusExplorer::OnRep_SwimState()
{
    auto* Move=GetCharacterMovement();
    if(!Move)return;
    if(bIsSwimming)
    {
        // Full-axis swimming without an APhysicsVolume: character can ascend,
        // descend, surface and leave the river with real underwater collision.
        Move->SetMovementMode(MOVE_Flying);
        Move->MaxFlySpeed=SwimSpeedCmPerSecond;
        Move->BrakingDecelerationFlying=450.f;
        Move->bOrientRotationToMovement=false;
    }
    else
    {
        if(Move->MovementMode==MOVE_Flying)Move->SetMovementMode(MOVE_Falling);
    }
}
void ANexusExplorer::DetectWaterAndSwim(float Dt)
{
    if(!GetWorld() || Dt<=0.f)return;
    if(!IsValid(CachedRiver))
    {
        for(TActorIterator<ANexusAlpineRiver> It(GetWorld());It;++It)
        {
            CachedRiver=*It;
            break;
        }
    }
    if(!CachedRiver)return;
    float Surface=0.f,Bed=0.f,Lateral=0.f;
    FVector Flow=FVector::ZeroVector;
    const FVector P=GetActorLocation();
    const bool bInChannel=CachedRiver->SampleWater(P,Surface,Bed,Flow,Lateral);
    WaterSpeedMetersPerSecond=bInChannel?Flow.Size()/100.f:0.f;
    const float Height=GetCapsuleComponent()->GetScaledCapsuleHalfHeight();
    const bool bDeep=bInChannel && Surface-Bed>150.f;
    const bool bCanEnter=bDeep && P.Z<Surface+Height*.85f && P.Z>Bed-Height;
    // Only the owning server decides water entry/exits, so 4 players see the
    // same swim state. Locally controlled clients receive it via replication.
    if(HasAuthority() && bCanEnter!=bIsSwimming)
    {
        bIsSwimming=bCanEnter;
        OnRep_SwimState();
        ForceNetUpdate();
    }
    if(!bIsSwimming)
    {
        bHeadUnderwater=false;
        if(HasAuthority())OxygenSeconds=FMath::Min(DiveDurationSeconds,OxygenSeconds+Dt*12.f);
        return;
    }
    bHeadUnderwater=bInChannel && P.Z+70.f<Surface-10.f;
    if(HasAuthority())
    {
        if(bHeadUnderwater) OxygenSeconds=FMath::Max(0.f,OxygenSeconds-Dt);
        else OxygenSeconds=FMath::Min(DiveDurationSeconds,OxygenSeconds+Dt*12.f);
        if(OxygenSeconds<=0.f)
        {
            Health=FMath::Max(0.f,Health-14.f*Dt);
            if(Health<=0.f)
            {
                // Rescue checkpoint on land rather than permanent softlock.
                bIsSwimming=false;
                OnRep_SwimState();
                SetActorLocation(FVector(-7600.f,310.f,2220.f),false);
                OxygenSeconds=DiveDurationSeconds;
                Health=100.f;
                ForceNetUpdate();
                return;
            }
        }
        // Flow is strongest near the outside eroding bank, while swimming
        // against it remains possible in the calmer inner sandbar.
        AddActorWorldOffset(Flow*.28f*Dt,true);
        const FVector Now=GetActorLocation();
        const float Roof=Surface+Height*.4f;
        const float Floor=Bed+Height*.7f;
        if(Now.Z>Roof)SetActorLocation(FVector(Now.X,Now.Y,Roof),true);
        if(Now.Z<Floor)SetActorLocation(FVector(Now.X,Now.Y,Floor),true);
    }
    // Clients predict their vertical swimming inputs; server separately
    // receives the same short-lived axis value via owning-pawn RPC.
    if(HasAuthority() || IsLocallyControlled())
    {
        const float RiseBias=(!bHeadUnderwater && SwimVerticalInput==0.f)?0.f:
            (SwimVerticalInput==0.f?.10f:0.f);
        AddMovementInput(FVector::UpVector,FMath::Clamp(SwimVerticalInput+RiseBias,-1.f,1.f));
    }
}
void ANexusExplorer::Tick(float DeltaSeconds)
{
    Super::Tick(DeltaSeconds);
    DetectWaterAndSwim(DeltaSeconds);
    RefreshWeaponVisual();
    // Minimal continuous transform-based animation until authored hand rigs /
    // Unreal Animation Blueprint clips can replace the temporary visual.
    WeaponRecoilAlpha=FMath::FInterpTo(WeaponRecoilAlpha,0.f,DeltaSeconds,12.f);
    WeaponReloadAlpha=FMath::FInterpTo(WeaponReloadAlpha,0.f,DeltaSeconds,3.2f);
    if(FirstPersonWeaponVisual)
        FirstPersonWeaponVisual->SetRelativeLocation(FVector(
            85.f-14.f*WeaponRecoilAlpha,22.f,
            -38.f+7.f*WeaponRecoilAlpha-22.f*WeaponReloadAlpha));
    if(IsLocallyControlled() && bPinboardOpen)
    {
        bool bNear=false;
        for(TActorIterator<ANexusStarterHome> It(GetWorld());It;++It)
            if(It->IsNearPinboard(GetActorLocation())){bNear=true;break;}
        if(!bNear)bPinboardOpen=false;
    }
    if(IsLocallyControlled() && ViewCamera)
        ViewCamera->PostProcessBlendWeight=bHeadUnderwater?0.85f:0.f;
}
void ANexusExplorer::UpdateSwimAxis()
{
    SwimVerticalInput=(bHoldAscend?1.f:0.f)-(bHoldDescend?1.f:0.f);
    if(!HasAuthority())ServerSwimVertical(SwimVerticalInput);
}
void ANexusExplorer::HandleJumpPressed()
{
    if(bIsSwimming){bHoldAscend=true;UpdateSwimAxis();}
    else Jump();
}
void ANexusExplorer::HandleJumpReleased()
{
    StopJumping();
    bHoldAscend=false;
    UpdateSwimAxis();
}
void ANexusExplorer::StartDive(){bHoldDescend=true;UpdateSwimAxis();}
void ANexusExplorer::StopDive(){bHoldDescend=false;UpdateSwimAxis();}
void ANexusExplorer::ServerSwimVertical_Implementation(float Axis)
{
    SwimVerticalInput=FMath::Clamp(Axis,-1.f,1.f);
}
void ANexusExplorer::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const
{
    Super::GetLifetimeReplicatedProps(Out);
    DOREPLIFETIME(ANexusExplorer,bIsSwimming);
    DOREPLIFETIME_CONDITION(ANexusExplorer,OxygenSeconds,COND_OwnerOnly);
    DOREPLIFETIME_CONDITION(ANexusExplorer,Health,COND_OwnerOnly);
}
