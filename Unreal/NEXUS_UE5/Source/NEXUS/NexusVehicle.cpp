#include "NexusVehicle.h"
#include "NexusGameMode.h"
#include "NexusWorldDirector.h"
#include "Components/BoxComponent.h"
#include "Components/StaticMeshComponent.h"
#include "Camera/CameraComponent.h"
#include "GameFramework/SpringArmComponent.h"
#include "GameFramework/PlayerController.h"
#include "Components/InputComponent.h"
#include "UObject/ConstructorHelpers.h"

ANexusVehicle::ANexusVehicle()
{
    PrimaryActorTick.bCanEverTick = true;
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
}
void ANexusVehicle::Drive(float V) { Throttle=FMath::Clamp(V,-1.f,1.f); }
void ANexusVehicle::Turn(float V) { Steering=FMath::Clamp(V,-1.f,1.f); }
void ANexusVehicle::FlyUp(float V) { Vertical=FMath::Clamp(V,-1.f,1.f); }
void ANexusVehicle::FlyDown(float V) { Vertical=FMath::Clamp(Vertical-V,-1.f,1.f); }
void ANexusVehicle::Tick(float Dt)
{
    Super::Tick(Dt);
    if(!Driver || Dt<=0) return;
    const float TargetSpeed=Throttle*(bHelicopter?2400.f:1650.f);
    LinearSpeed=FMath::FInterpTo(LinearSpeed,TargetSpeed,Dt,bHelicopter?1.3f:1.8f);
    AddActorWorldRotation(FRotator(0,Steering*(bHelicopter?38.f:60.f)*Dt,0));
    const FVector Delta=GetActorForwardVector()*LinearSpeed*Dt+
        (bHelicopter?FVector(0,0,Vertical*1350.f*Dt):FVector::ZeroVector);
    AddActorWorldOffset(Delta,true);
    if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>())
        if(GM->Director) GM->Director->VehicleAdvanced(this);
}
void ANexusVehicle::RescueOrExit()
{
    if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>())
        if(!GM->InteractVehicle(this)) GM->ExitVehicle(this);
}
void ANexusVehicle::ExitToFoot() { if(auto* GM=GetWorld()->GetAuthGameMode<ANexusGameMode>()) GM->ExitVehicle(this); }
