#include "NexusVehicle.h"
#include "NexusGameMode.h"
#include "NexusWorldDirector.h"
#include "NexusAlpineWeather.h"
#include "Components/BoxComponent.h"
#include "Components/StaticMeshComponent.h"
#include "Camera/CameraComponent.h"
#include "GameFramework/SpringArmComponent.h"
#include "GameFramework/PlayerController.h"
#include "Components/InputComponent.h"
#include "Engine/World.h"
#include "CollisionQueryParams.h"
#include "UObject/ConstructorHelpers.h"

ANexusVehicle::ANexusVehicle()
{
    PrimaryActorTick.bCanEverTick = true;
    bReplicates=true;
    SetReplicateMovement(true);
    Collider=CreateDefaultSubobject<UBoxComponent>(TEXT("VehicleCollision"));
    Collider->SetBoxExtent(FVector(275,140,110));
    Collider->SetCollisionProfileName(TEXT("Pawn"));
    RootComponent=Collider;
    Visual=CreateDefaultSubobject<UStaticMeshComponent>(TEXT("VehicleVisualReplaceWithHeroMesh"));
    Visual->SetupAttachment(Collider);
    Visual->SetCollisionEnabled(ECollisionEnabled::NoCollision);
    static ConstructorHelpers::FObjectFinder<UStaticMesh> DefaultBox(TEXT("/Engine/BasicShapes/Cube.Cube"));
    if(auto* Model=LoadObject<UStaticMesh>(nullptr,
        TEXT("/Game/AAA/Geometry/Hero/SM_NEXUS_FireRescue_Truck.SM_NEXUS_FireRescue_Truck")))
        Visual->SetStaticMesh(Model);
    else if(DefaultBox.Succeeded())
    { Visual->SetStaticMesh(DefaultBox.Object); Visual->SetRelativeScale3D(FVector(5.2f,2.5f,1.9f)); }
    CameraArm=CreateDefaultSubobject<USpringArmComponent>(TEXT("CameraArm"));
    CameraArm->SetupAttachment(RootComponent);
    CameraArm->TargetArmLength=760.f;
    CameraArm->SetRelativeLocation(FVector(0,0,280));
    CameraArm->bUsePawnControlRotation=false;
    ChaseCamera=CreateDefaultSubobject<UCameraComponent>(TEXT("FollowCamera"));
    ChaseCamera->SetupAttachment(CameraArm,USpringArmComponent::SocketName);
    AutoPossessPlayer=EAutoReceiveInput::Disabled;
}
void ANexusVehicle::SetDriver(APlayerController* Controller) { Driver=Controller; }
void ANexusVehicle::SetupPlayerInputComponent(UInputComponent* Input)
{
    Super::SetupPlayerInputComponent(Input);
    Input->BindAxis(TEXT("DriveForward"),this,&ANexusVehicle::Drive);
    Input->BindAxis(TEXT("DriveSteer"),this,&ANexusVehicle::Turn);
    Input->BindAxis(TEXT("FlyUp"),this,&ANexusVehicle::FlyUp);
    Input->BindAxis(TEXT("FlyDown"),this,&ANexusVehicle::FlyDown);
    Input->BindAction(TEXT("Interact"),IE_Pressed,this,&ANexusVehicle::RescueOrExit);
    Input->BindAction(TEXT("ExitVehicle"),IE_Pressed,this,&ANexusVehicle::ExitToFoot);
    Input->BindAction(TEXT("RoleMedic"),IE_Pressed,this,&ANexusVehicle::ChooseMedic);
    Input->BindAction(TEXT("RolePilot"),IE_Pressed,this,&ANexusVehicle::ChoosePilot);
    Input->BindAction(TEXT("RoleGround"),IE_Pressed,this,&ANexusVehicle::ChooseGround);
    Input->BindAction(TEXT("InspectEvidence"),IE_Pressed,this,&ANexusVehicle::InspectEvidence);
    Input->BindAction(TEXT("ProtectCivilians"),IE_Pressed,this,&ANexusVehicle::ProtectCivilians);
    Input->BindAction(TEXT("SecureEvidence"),IE_Pressed,this,&ANexusVehicle::SecureEvidence);
}
void ANexusVehicle::Drive(float V)
{
    V=FMath::Clamp(V,-1.f,1.f);
    if(FMath::Abs(V-Throttle)>0.08f)
    {
        Throttle=V;
        if(!HasAuthority()) ServerSetMotion(Throttle,Steering,Vertical);
    }
}
void ANexusVehicle::Turn(float V)
{
    V=FMath::Clamp(V,-1.f,1.f);
    if(FMath::Abs(V-Steering)>0.08f)
    {
        Steering=V;
        if(!HasAuthority()) ServerSetMotion(Throttle,Steering,Vertical);
    }
}
void ANexusVehicle::FlyUp(float V)
{
    V=FMath::Clamp(V,-1.f,1.f);
    if(FMath::Abs(V-Vertical)>0.08f)
    {
        Vertical=V;
        if(!HasAuthority()) ServerSetMotion(Throttle,Steering,Vertical);
    }
}
void ANexusVehicle::FlyDown(float V)
{
    FlyUp(-V);
}
void ANexusVehicle::Tick(float Dt)
{
    Super::Tick(Dt);
    if(!HasAuthority() || !Driver || Dt<=0) return;
    float Traction=1.f;
    if(!bHelicopter)
        if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>())
            if(GM->Director && GM->Director->Weather)
                Traction=GM->Director->Weather->RoadTractionMultiplier();
    const float TargetSpeed=Throttle*(bHelicopter?2400.f:1650.f)*Traction;
    LinearSpeed=FMath::FInterpTo(LinearSpeed,TargetSpeed,Dt,bHelicopter?1.3f:1.8f);
    AddActorWorldRotation(FRotator(0,Steering*(bHelicopter?38.f:60.f)*Dt*Traction,0));
    const FVector Delta=GetActorForwardVector()*LinearSpeed*Dt+
        (bHelicopter?FVector(0,0,Vertical*1350.f*Dt):FVector::ZeroVector);
    AddActorWorldOffset(Delta,true);
    if(!bHelicopter)
    {
        // Lightweight arcade suspension/gravity until Chaos wheeled vehicle is integrated.
        // Only snap to reachable road/bridge surface; below a broken bridge the car falls.
        FHitResult Ground;
        FCollisionQueryParams Params;
        Params.AddIgnoredActor(this);
        const FVector P=GetActorLocation();
        const bool bHit=GetWorld()->LineTraceSingleByChannel(Ground,P+FVector(0,0,160),
            P-FVector(0,0,3500),ECC_Visibility,Params);
        const float GroundZ=bHit?Ground.ImpactPoint.Z+Collider->GetScaledBoxExtent().Z:0.f;
        if(bHit && GroundZ-P.Z > -400.f && GroundZ-P.Z < 240.f)
        {
            FallingSpeed=0.f;
            SetActorLocation(FVector(P.X,P.Y,FMath::FInterpTo(P.Z,GroundZ,Dt,11.f)),true);
        }
        else
        {
            FallingSpeed=FMath::Max(FallingSpeed-980.f*Dt,-6500.f);
            AddActorWorldOffset(FVector(0,0,FallingSpeed*Dt),true);
        }
    }
    if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>())
        if(GM->Director) GM->Director->VehicleAdvanced(this);
}
void ANexusVehicle::RescueOrExit()
{ if(!HasAuthority()){ServerCommand(0);return;}
    if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>())
        if(!GM->InteractVehicle(this)) GM->ExitVehicle(this);
}
void ANexusVehicle::ExitToFoot() { if(!HasAuthority()){ServerCommand(1);return;} if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>()) GM->ExitVehicle(this); }

void ANexusVehicle::ChooseMedic() { if(!HasAuthority()){ServerCommand(2);return;} if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>()) GM->ChooseRole(0); }
void ANexusVehicle::ChoosePilot() { if(!HasAuthority()){ServerCommand(3);return;} if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>()) GM->ChooseRole(1); }
void ANexusVehicle::ChooseGround() { if(!HasAuthority()){ServerCommand(4);return;} if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>()) GM->ChooseRole(2); }

void ANexusVehicle::InspectEvidence()
{ if(!HasAuthority()){ServerCommand(5);return;}
    if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>())
        if(GM->Director)GM->Director->InvestigateEvidence(GetActorLocation());
}
void ANexusVehicle::ProtectCivilians()
{ if(!HasAuthority()){ServerCommand(6);return;}
    if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>())
        if(GM->Director)GM->Director->ChooseCampaignOutcome(true);
}
void ANexusVehicle::SecureEvidence()
{ if(!HasAuthority()){ServerCommand(7);return;}
    if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>())
        if(GM->Director)GM->Director->ChooseCampaignOutcome(false);
}

void ANexusVehicle::ServerCommand_Implementation(uint8 Code)
{
    if(!Driver || Driver!=GetController())return;
    switch(Code)
    {
        case 0: RescueOrExit();break;
        case 1: ExitToFoot();break;
        case 2: ChooseMedic();break;
        case 3: ChoosePilot();break;
        case 4: ChooseGround();break;
        case 5: InspectEvidence();break;
        case 6: ProtectCivilians();break;
        case 7: SecureEvidence();break;
        default:break;
    }
}
void ANexusVehicle::ServerSetMotion_Implementation(float InThrottle,float InSteering,float InVertical)
{
    if(!Driver || Driver!=GetController())return;
    Throttle=FMath::Clamp(InThrottle,-1.f,1.f);
    Steering=FMath::Clamp(InSteering,-1.f,1.f);
    Vertical=FMath::Clamp(InVertical,-1.f,1.f);
}
