#include "NexusVehicle.h"
#include "NexusGameMode.h"
#include "NexusWorldDirector.h"
#include "NexusAlpineWeather.h"
#include "Components/BoxComponent.h"
#include "Components/StaticMeshComponent.h"
#include "Camera/CameraComponent.h"
#include "Components/PointLightComponent.h"
#include "Components/SpotLightComponent.h"
#include "GameFramework/SpringArmComponent.h"
#include "GameFramework/PlayerController.h"
#include "Components/InputComponent.h"
#include "Engine/World.h"
#include "CollisionQueryParams.h"
#include "UObject/ConstructorHelpers.h"
#include "Net/UnrealNetwork.h"

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
    CockpitCamera=CreateDefaultSubobject<UCameraComponent>(TEXT("DriverCockpitCamera"));
    CockpitCamera->SetupAttachment(Collider);
    CockpitCamera->SetRelativeLocation(FVector(45.f,-55.f,128.f));
    CockpitCamera->bUsePawnControlRotation=true;
    CockpitCamera->SetActive(false);
    BeaconRed=CreateDefaultSubobject<UPointLightComponent>(TEXT("EmergencyBeaconRed"));
    BeaconRed->SetupAttachment(Collider);
    BeaconRed->SetRelativeLocation(FVector(80.f,-115.f,180.f));
    BeaconRed->SetLightColor(FLinearColor(1.f,0.025f,0.02f));
    BeaconRed->SetAttenuationRadius(1450.f);
    BeaconRed->SetIntensity(0.f);
    BeaconRed->SetCastShadows(false);
    BeaconBlue=CreateDefaultSubobject<UPointLightComponent>(TEXT("EmergencyBeaconBlue"));
    BeaconBlue->SetupAttachment(Collider);
    BeaconBlue->SetRelativeLocation(FVector(80.f,115.f,180.f));
    BeaconBlue->SetLightColor(FLinearColor(.02f,.16f,1.f));
    BeaconBlue->SetAttenuationRadius(1450.f);
    BeaconBlue->SetIntensity(0.f);
    BeaconBlue->SetCastShadows(false);
    HelicopterSearchLight=CreateDefaultSubobject<USpotLightComponent>(TEXT("HelicopterRescueSearchlight"));
    HelicopterSearchLight->SetupAttachment(Collider);
    HelicopterSearchLight->SetRelativeLocation(FVector(180.f,0.f,45.f));
    HelicopterSearchLight->SetRelativeRotation(FRotator(-62.f,0.f,0.f));
    HelicopterSearchLight->SetLightColor(FLinearColor(.84f,.93f,1.f));
    HelicopterSearchLight->SetAttenuationRadius(16000.f);
    HelicopterSearchLight->SetInnerConeAngle(10.f);
    HelicopterSearchLight->SetOuterConeAngle(28.f);
    HelicopterSearchLight->SetIntensity(35000.f);
    HelicopterSearchLight->SetVisibility(false);
    AutoPossessPlayer=EAutoReceiveInput::Disabled;
}
void ANexusVehicle::ConfigureVehicle(ENexusVehicleType NewType)
{
    if(!HasAuthority())return;
    VehicleType=NewType;
    OnRep_VehicleType();
    ForceNetUpdate();
}
void ANexusVehicle::OnRep_VehicleType()
{
    // Pack source: NEXUS_V5_FLEET_ASSETS.zip. Import paths are stable.
    const TCHAR* FileName=nullptr;
    switch(VehicleType)
    {
    case ENexusVehicleType::RescueTruck:FileName=TEXT("SM_NEXUS_FireRescue_Truck");break;
    case ENexusVehicleType::RescueHelicopter:FileName=TEXT("SM_NEXUS_RescueHelicopter");break;
    case ENexusVehicleType::Sportscar:FileName=TEXT("SM_Nexus_Sportscar");break;
    case ENexusVehicleType::Sedan:FileName=TEXT("SM_Nexus_Sedan");break;
    case ENexusVehicleType::SUV:FileName=TEXT("SM_Nexus_SUV");break;
    case ENexusVehicleType::PoliceCar:FileName=TEXT("SM_Nexus_PoliceCar");break;
    case ENexusVehicleType::Ambulance:FileName=TEXT("SM_Nexus_Ambulance");break;
    case ENexusVehicleType::FireTruck:FileName=TEXT("SM_Nexus_FireTruck");break;
    case ENexusVehicleType::DeliveryTruck:FileName=TEXT("SM_Nexus_DeliveryTruck");break;
    case ENexusVehicleType::PoliceVan:FileName=TEXT("SM_Nexus_PoliceVan");break;
    case ENexusVehicleType::UtilityHelicopter:FileName=TEXT("SM_Nexus_UtilityHelicopter");break;
    case ENexusVehicleType::HeavyUtilityHelicopter:FileName=TEXT("SM_Nexus_HeavyUtilityHelicopter");break;
    case ENexusVehicleType::HistoricArmoredTank:FileName=TEXT("SM_Nexus_HistoricArmoredTank");break;
    case ENexusVehicleType::FictionalArmoredExplorer:FileName=TEXT("SM_Nexus_FictionalArmoredExplorer");break;
    }
    bHelicopter=VehicleType==ENexusVehicleType::RescueHelicopter ||
        VehicleType==ENexusVehicleType::UtilityHelicopter ||
        VehicleType==ENexusVehicleType::HeavyUtilityHelicopter;
    const bool bHero=VehicleType==ENexusVehicleType::RescueTruck ||
        VehicleType==ENexusVehicleType::RescueHelicopter;
    if(FileName)
    {
        const FString AssetPath=FString::Printf(bHero?
            TEXT("/Game/AAA/Geometry/Hero/%s.%s"):
            TEXT("/Game/AAA/Geometry/Fleet/%s.%s"),FileName,FileName);
        if(UStaticMesh* Mesh=LoadObject<UStaticMesh>(nullptr,*AssetPath))
        {
            Visual->SetStaticMesh(Mesh);
            Visual->SetRelativeScale3D(FVector::OneVector);
        }
        else
        {
            // Actual fallback is explicitly an alpha blockout, never labelled photoreal.
            Visual->SetStaticMesh(LoadObject<UStaticMesh>(nullptr,TEXT("/Engine/BasicShapes/Cube.Cube")));
            Visual->SetRelativeScale3D(bHelicopter?FVector(8.f,3.f,2.6f):
                (VehicleType==ENexusVehicleType::HistoricArmoredTank?FVector(6.6f,3.1f,2.0f):FVector(4.7f,2.2f,1.7f)));
        }
    }
    const bool bEmergency=VehicleType==ENexusVehicleType::RescueTruck ||
        VehicleType==ENexusVehicleType::RescueHelicopter ||
        VehicleType==ENexusVehicleType::FireTruck ||
        VehicleType==ENexusVehicleType::Ambulance ||
        VehicleType==ENexusVehicleType::PoliceCar ||
        VehicleType==ENexusVehicleType::PoliceVan;
    BeaconRed->SetVisibility(bEmergency);
    BeaconBlue->SetVisibility(bEmergency);
    CameraArm->TargetArmLength=bHelicopter?1100.f:
        (VehicleType==ENexusVehicleType::HistoricArmoredTank?950.f:730.f);
    Collider->SetBoxExtent(bHelicopter?FVector(370.f,150.f,160.f):
        (VehicleType==ENexusVehicleType::HistoricArmoredTank?FVector(350.f,168.f,160.f):
          FVector(275.f,140.f,110.f)),true);
}
void ANexusVehicle::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const
{
    Super::GetLifetimeReplicatedProps(Out);
    DOREPLIFETIME(ANexusVehicle,VehicleType);
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
    Input->BindAction(TEXT("ToggleCamera"),IE_Pressed,this,&ANexusVehicle::ToggleCamera);
    Input->BindAction(TEXT("RoleMedic"),IE_Pressed,this,&ANexusVehicle::ChooseMedic);
    Input->BindAction(TEXT("RolePilot"),IE_Pressed,this,&ANexusVehicle::ChoosePilot);
    Input->BindAction(TEXT("RoleGround"),IE_Pressed,this,&ANexusVehicle::ChooseGround);
    Input->BindAction(TEXT("InspectEvidence"),IE_Pressed,this,&ANexusVehicle::InspectEvidence);
    Input->BindAction(TEXT("ProtectCivilians"),IE_Pressed,this,&ANexusVehicle::ProtectCivilians);
    Input->BindAction(TEXT("SecureEvidence"),IE_Pressed,this,&ANexusVehicle::SecureEvidence);
}
void ANexusVehicle::ToggleCamera()
{
    bCockpitView=!bCockpitView;
    ChaseCamera->SetActive(!bCockpitView);
    CockpitCamera->SetActive(bCockpitView);
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
    // Alternating red/blue reflections are visual-only and run on every client.
    if(HelicopterSearchLight)
        HelicopterSearchLight->SetVisibility(bHelicopter);
    if(GetWorld() && BeaconRed && BeaconBlue && BeaconRed->IsVisible())
    {
        const float Cycle=FMath::Fmod(GetWorld()->GetTimeSeconds()*3.2f,1.f);
        BeaconRed->SetIntensity(Cycle<.38f?4400.f:0.f);
        BeaconBlue->SetIntensity(Cycle>.50f && Cycle<.88f?5500.f:0.f);
    }
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
