#pragma once
#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "NexusWeaponComponent.generated.h"

USTRUCT(BlueprintType)
struct FNexusWeaponState
{
    GENERATED_BODY()
    UPROPERTY(BlueprintReadOnly) FName WeaponId=NAME_None;
    UPROPERTY(BlueprintReadOnly) int32 InMagazine=0;
    UPROPERTY(BlueprintReadOnly) int32 ReserveAmmo=0;
    UPROPERTY(BlueprintReadOnly) int32 MagazineCapacity=0;
    UPROPERTY(BlueprintReadOnly) bool bUnlocked=false;
};

// Game-only fictional weapon states. No ballistic simulation and no PvP.
// Server confirms cooldown, ammo, unlock and hit on practice targets.
UCLASS(ClassGroup=(NEXUS),meta=(BlueprintSpawnableComponent))
class NEXUS_API UNexusWeaponComponent : public UActorComponent
{
    GENERATED_BODY()
public:
    UNexusWeaponComponent();
    virtual void BeginPlay() override;
    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const override;
    UPROPERTY(BlueprintReadOnly,Replicated) TArray<FNexusWeaponState> Arsenal;
    UPROPERTY(BlueprintReadOnly,Replicated) int32 EquippedIndex=0;
    UPROPERTY(BlueprintReadOnly,Replicated) bool bSciFiUnlocked=false;
    UFUNCTION(BlueprintCallable) void SelectNextWeapon();
    UFUNCTION(BlueprintCallable) void Reload();
    UFUNCTION(BlueprintCallable) void Fire();
    UFUNCTION(BlueprintPure) FString GetCurrentName() const;
    UFUNCTION(BlueprintPure) int32 GetMagazineAmmo() const;
    UFUNCTION(BlueprintPure) int32 GetReserveAmmo() const;
    UFUNCTION(BlueprintPure) bool IsSciFiUnlocked() const {return bSciFiUnlocked;}
    UFUNCTION(BlueprintCallable) void UnlockSciFiFromResearch();
    UFUNCTION(Server,Reliable) void ServerNextWeapon();
    UFUNCTION(Server,Reliable) void ServerReload();
    UFUNCTION(Server,Reliable) void ServerFire();
    UFUNCTION(NetMulticast,Unreliable) void MulticastFireFeedback(FVector Origin);
private:
    float NextAllowedShot=0.f;
    void CreateStarterWeapons();
    bool CanActOnServer() const;
};
