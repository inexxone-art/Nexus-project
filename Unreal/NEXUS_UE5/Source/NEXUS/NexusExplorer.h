#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "NexusExplorer.generated.h"
class UCameraComponent;

UCLASS()
class NEXUS_API ANexusExplorer : public ACharacter
{
    GENERATED_BODY()
public:
    ANexusExplorer();
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly) TObjectPtr<UCameraComponent> ViewCamera;
    virtual void SetupPlayerInputComponent(UInputComponent* Input) override;
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
    UPROPERTY(BlueprintReadOnly) int32 EquipmentSlot = 0;
};
