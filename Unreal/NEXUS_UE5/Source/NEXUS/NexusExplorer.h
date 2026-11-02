#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "NexusTypes.h"
#include "NexusExplorer.generated.h"
class UCameraComponent;
class UNexusWeaponComponent;
class UStaticMeshComponent;
class USpringArmComponent;
class ANexusAlpineRiver;

UCLASS()
class NEXUS_API ANexusExplorer : public ACharacter
{
    GENERATED_BODY()
public:
    ANexusExplorer();
    virtual void BeginPlay() override;
    virtual void Tick(float DeltaSeconds) override;
    virtual void SetupPlayerInputComponent(UInputComponent* Input) override;
    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const override;

    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UCameraComponent> ViewCamera;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UNexusWeaponComponent> Weapons;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UStaticMeshComponent> FirstPersonWeaponVisual;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UStaticMeshComponent> ThirdPersonWeaponVisual;
    UFUNCTION(BlueprintCallable) void FireWeapon();
    UFUNCTION(BlueprintCallable) void ReloadWeapon();
    UFUNCTION(BlueprintCallable) void NextWeapon();
    void RefreshWeaponVisual();
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<USpringArmComponent> ThirdPersonArm;
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UCameraComponent> ThirdPersonCamera;
    UPROPERTY(BlueprintReadOnly,Category="NEXUS|Camera") bool bThirdPersonView=false;
    // Every co-op player chooses their own duty after the disaster.
    UPROPERTY(BlueprintReadOnly,Replicated) ENexusRescueRole SelectedRescueRole=ENexusRescueRole::None;
    void SetRescueRole(ENexusRescueRole NewRole);
    UFUNCTION(BlueprintCallable,Category="NEXUS|Camera") void ToggleCamera();

    // True 3D buoyant movement uses CharacterMovement MOVE_Flying, with a
    // custom server-authoritative water detector and drag/current controller.
    // It avoids assuming an editor-authored APhysicsVolume already exists.
    UPROPERTY(BlueprintReadOnly,ReplicatedUsing=OnRep_SwimState) bool bIsSwimming=false;
    UPROPERTY(BlueprintReadOnly,Replicated) float OxygenSeconds=45.f;
    UPROPERTY(BlueprintReadOnly,Replicated) float Health=100.f;
    UPROPERTY(BlueprintReadOnly) bool bHeadUnderwater=false;
    UPROPERTY(BlueprintReadOnly) float WaterSpeedMetersPerSecond=0.f;
    UPROPERTY(EditAnywhere,BlueprintReadWrite) float SwimSpeedCmPerSecond=320.f;
    UPROPERTY(EditAnywhere,BlueprintReadWrite) float DiveDurationSeconds=45.f;
    UPROPERTY(Transient) TObjectPtr<ANexusAlpineRiver> CachedRiver;

    UFUNCTION() void OnRep_SwimState();
    UFUNCTION(Server,Unreliable) void ServerSwimVertical(float Axis);
    void HandleJumpPressed();
    void HandleJumpReleased();
    void StartDive();
    void StopDive();

    void MoveForward(float InputValue);
    void MoveRight(float InputValue);
    void LookYaw(float InputValue);
    void LookPitch(float InputValue);
    void Interact();
    void MedicRole();
    void PilotRole();
    void GroundRole();
    void Slot1();
    void Slot2();
    void Slot3();
    void Slot4();
    void SaveProgress();
    void LoadProgress();
    void MissionApproach();
    void InspectEvidence();
    void ProtectCivilians();
    void SecureEvidence();
    UFUNCTION(Server,Reliable) void ServerCommand(uint8 Code);
    void TeamFollow();
    void TeamScout();
    void TeamMedic();
    UPROPERTY(BlueprintReadOnly) int32 EquipmentSlot=0;
    UPROPERTY(BlueprintReadOnly) bool bPinboardOpen=false;
    UPROPERTY(BlueprintReadOnly) bool bPhoneOpen=false;
    void TogglePinboard();
    void TogglePhone();
    void SellGoldFromPhone();
    void BuyRentalFromPhone();
    void ResearchSciFiFromPhone();

private:
    float WeaponRecoilAlpha=0.f;
    float WeaponReloadAlpha=0.f;
    int32 CachedWeaponVisualIndex=-1;
    float SwimVerticalInput=0.f;
    bool bHoldAscend=false;
    bool bHoldDescend=false;
    void UpdateSwimAxis();
    void DetectWaterAndSwim(float DeltaSeconds);
};
