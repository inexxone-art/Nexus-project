#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Pawn.h"
#include "NexusVehicle.generated.h"

UENUM(BlueprintType)
enum class ENexusVehicleType : uint8
{
    RescueTruck, RescueHelicopter, Sportscar, Sedan, SUV, PoliceCar,
    Ambulance, FireTruck, DeliveryTruck, PoliceVan, UtilityHelicopter,
    HeavyUtilityHelicopter, HistoricArmoredTank, FictionalArmoredExplorer
};
class UBoxComponent;
class USceneComponent;
class UStaticMeshComponent;
class USpringArmComponent;
class UCameraComponent;
class APlayerController;

UCLASS()
class NEXUS_API ANexusVehicle : public APawn
{
    GENERATED_BODY()
public:
    ANexusVehicle();
    virtual void Tick(float DeltaSeconds) override;
    virtual void SetupPlayerInputComponent(UInputComponent* Input) override;
    UPROPERTY(VisibleAnywhere) TObjectPtr<UBoxComponent> Collider;
    UPROPERTY(VisibleAnywhere) TObjectPtr<UStaticMeshComponent> Visual;
    // Actual mesh component animation, not a prerecorded cinematic.
    // Replaces rigid V5 body when V6 MotionBody mesh is installed.
    UPROPERTY(VisibleAnywhere) TObjectPtr<USceneComponent> MainRotorPivot;
    UPROPERTY(VisibleAnywhere) TObjectPtr<UStaticMeshComponent> MainRotorVisual;
    UPROPERTY(VisibleAnywhere) TArray<TObjectPtr<UStaticMeshComponent>> RoadWheels;
    UPROPERTY(BlueprintReadOnly) bool bV6MovingParts=false;
    UPROPERTY(VisibleAnywhere) TObjectPtr<USpringArmComponent> CameraArm;
    UPROPERTY(VisibleAnywhere) TObjectPtr<UCameraComponent> ChaseCamera;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UCameraComponent> CockpitCamera;
    UPROPERTY(BlueprintReadOnly) bool bCockpitView=false;
    UFUNCTION(BlueprintCallable) void ToggleCamera();
    UPROPERTY(VisibleAnywhere) TObjectPtr<class UPointLightComponent> BeaconRed;
    UPROPERTY(VisibleAnywhere) TObjectPtr<class UPointLightComponent> BeaconBlue;
    UPROPERTY(VisibleAnywhere) TObjectPtr<class USpotLightComponent> HelicopterSearchLight;
    UPROPERTY(EditAnywhere, BlueprintReadOnly, ReplicatedUsing=OnRep_VehicleType) ENexusVehicleType VehicleType=ENexusVehicleType::RescueTruck;
    UFUNCTION(BlueprintCallable,Category="NEXUS|Fleet") void ConfigureVehicle(ENexusVehicleType NewType);
    UFUNCTION() void OnRep_VehicleType();
    UPROPERTY(EditAnywhere, BlueprintReadWrite) bool bHelicopter = false;
    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const override;
    UPROPERTY(BlueprintReadOnly) float LinearSpeed = 0.f;
    UPROPERTY(BlueprintReadOnly) TObjectPtr<APlayerController> Driver;
    void Drive(float InputValue);
    void Turn(float InputValue);
    void FlyUp(float InputValue);
    void FlyDown(float InputValue);
    void RescueOrExit();
    void ChooseMedic();
    void ChoosePilot();
    void ChooseGround();
    void InspectEvidence();
    void ProtectCivilians();
    void SecureEvidence();
    void ExitToFoot();
    void SetDriver(APlayerController* Controller);
    UFUNCTION(Server,Reliable) void ServerCommand(uint8 Code);
    UFUNCTION(Server,Unreliable) void ServerSetMotion(float InThrottle,float InSteering,float InVertical);
private:
    float Throttle=0.f;
    float Steering=0.f;
    float Vertical=0.f;
    float FallingSpeed=0.f;
    FVector PreviousVisualLocation=FVector::ZeroVector;
    bool bVisualLocationInitialized=false;
};
