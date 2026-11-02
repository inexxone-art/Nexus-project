#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Pawn.h"
#include "NexusVehicle.generated.h"
class UBoxComponent;
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
    UPROPERTY(VisibleAnywhere) TObjectPtr<USpringArmComponent> CameraArm;
    UPROPERTY(VisibleAnywhere) TObjectPtr<UCameraComponent> ChaseCamera;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UCameraComponent> CockpitCamera;
    UPROPERTY(BlueprintReadOnly) bool bCockpitView=false;
    UFUNCTION(BlueprintCallable) void ToggleCamera();
    UPROPERTY(VisibleAnywhere) TObjectPtr<class UPointLightComponent> BeaconRed;
    UPROPERTY(VisibleAnywhere) TObjectPtr<class UPointLightComponent> BeaconBlue;
    UPROPERTY(VisibleAnywhere) TObjectPtr<class USpotLightComponent> HelicopterSearchLight;
    UPROPERTY(EditAnywhere, BlueprintReadWrite) bool bHelicopter = false;
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
};
