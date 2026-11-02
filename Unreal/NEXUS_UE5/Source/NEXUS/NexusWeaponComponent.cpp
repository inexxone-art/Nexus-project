#include "NexusWeaponComponent.h"
#include "NexusExplorer.h"
#include "NexusPracticeTarget.h"
#include "NiagaraFunctionLibrary.h"
#include "NiagaraSystem.h"
#include "GameFramework/Controller.h"
#include "GameFramework/PlayerController.h"
#include "Engine/World.h"
#include "CollisionQueryParams.h"
#include "Net/UnrealNetwork.h"

namespace NexusCombat
{
    struct FSettings {const TCHAR* Name;int32 Capacity;int32 Spare;float Interval;float Distance;float Score;bool Future;};
    // Deliberately arcade scores. These do NOT represent real-world weapon characteristics.
    const FSettings Settings[]={
        {TEXT("Pistole"),15,75,.25f,4000.f,16.f,false},
        {TEXT("Karabiner"),28,140,.14f,6500.f,12.f,false},
        {TEXT("Praezisionsgewehr"),7,35,.90f,10000.f,38.f,false},
        {TEXT("Leichte Waffe"),24,96,.21f,4500.f,15.f,false},
        {TEXT("Alien-Puls"),20,80,.18f,7200.f,22.f,true},
        {TEXT("Plasmabogen"),8,40,.75f,6500.f,33.f,true}
    };
    constexpr int32 WeaponCount=6;
}
UNexusWeaponComponent::UNexusWeaponComponent()
{
    PrimaryComponentTick.bCanEverTick=false;
    SetIsReplicatedByDefault(true);
}
void UNexusWeaponComponent::BeginPlay()
{
    Super::BeginPlay();
    if(GetOwner() && GetOwner()->HasAuthority() && Arsenal.IsEmpty())CreateStarterWeapons();
}
void UNexusWeaponComponent::CreateStarterWeapons()
{
    Arsenal.Empty();
    for(int32 I=0;I<NexusCombat::WeaponCount;++I)
    {
        FNexusWeaponState One;
        One.WeaponId=FName(NexusCombat::Settings[I].Name);
        One.MagazineCapacity=NexusCombat::Settings[I].Capacity;
        One.InMagazine=One.MagazineCapacity;
        One.ReserveAmmo=NexusCombat::Settings[I].Spare;
        One.bUnlocked=!NexusCombat::Settings[I].Future;
        Arsenal.Add(One);
    }
    EquippedIndex=0;
}
bool UNexusWeaponComponent::CanActOnServer() const
{
    const ANexusExplorer* Explorer=Cast<ANexusExplorer>(GetOwner());
    return Explorer && Explorer->HasAuthority() && Explorer->GetController()!=nullptr;
}
void UNexusWeaponComponent::SelectNextWeapon()
{
    if(!GetOwner() || !GetOwner()->HasAuthority()){ServerNextWeapon();return;}
    if(!CanActOnServer() || Arsenal.IsEmpty())return;
    for(int32 Shift=1;Shift<=Arsenal.Num();++Shift)
    {
        const int32 Next=(EquippedIndex+Shift)%Arsenal.Num();
        if(Arsenal[Next].bUnlocked)
        {
            EquippedIndex=Next;
            GetOwner()->ForceNetUpdate();
            break;
        }
    }
}
void UNexusWeaponComponent::ServerNextWeapon_Implementation(){SelectNextWeapon();}
void UNexusWeaponComponent::Reload()
{
    if(!GetOwner() || !GetOwner()->HasAuthority()){ServerReload();return;}
    if(!CanActOnServer() || !Arsenal.IsValidIndex(EquippedIndex))return;
    FNexusWeaponState& State=Arsenal[EquippedIndex];
    if(!State.bUnlocked || State.InMagazine>=State.MagazineCapacity || State.ReserveAmmo<=0)return;
    const int32 Amount=FMath::Min(State.MagazineCapacity-State.InMagazine,State.ReserveAmmo);
    State.InMagazine+=Amount;
    State.ReserveAmmo-=Amount;
    GetOwner()->ForceNetUpdate();
}
void UNexusWeaponComponent::ServerReload_Implementation(){Reload();}
void UNexusWeaponComponent::Fire()
{
    if(!GetOwner() || !GetOwner()->HasAuthority()){ServerFire();return;}
    if(!CanActOnServer() || !Arsenal.IsValidIndex(EquippedIndex) || !GetWorld())return;
    ANexusExplorer* Explorer=Cast<ANexusExplorer>(GetOwner());
    if(!Explorer || Explorer->bIsSwimming)return;
    FNexusWeaponState& State=Arsenal[EquippedIndex];
    if(!State.bUnlocked || (EquippedIndex>=4 && !bSciFiUnlocked) || State.InMagazine<=0)return;
    const float Now=GetWorld()->GetTimeSeconds();
    const auto& S=NexusCombat::Settings[FMath::Clamp(EquippedIndex,0,NexusCombat::WeaponCount-1)];
    if(Now<NextAllowedShot)return;
    NextAllowedShot=Now+S.Interval;
    --State.InMagazine;
    GetOwner()->ForceNetUpdate();

    // Authoritative game trace: range, rate and ammo validated on the server.
    // Current early prototype only affects a fictional practice range target.
    // Co-op teammates and neutral citizens cannot be harmed by this system.
    const FVector Origin=Explorer->GetPawnViewLocation();
    const FVector Direction=Explorer->GetControlRotation().Vector();
    FCollisionQueryParams Params(SCENE_QUERY_STAT(NexusPracticeTargetTrace),true,Explorer);
    FHitResult Hit;
    if(GetWorld()->LineTraceSingleByChannel(Hit,Origin,Origin+Direction*S.Distance,
        ECC_Visibility,Params))
    {
        if(auto* Target=Cast<ANexusPracticeTarget>(Hit.GetActor()))
            Target->ReceivePracticeHit(S.Score);
    }
    MulticastFireFeedback(Origin+Direction*55.f);
}
void UNexusWeaponComponent::ServerFire_Implementation(){Fire();}
void UNexusWeaponComponent::MulticastFireFeedback_Implementation(FVector Origin)
{
    // Optional Niagara pulse; absent VFX assets are not silently faked.
    const bool bFuture=EquippedIndex>=4;
    const TCHAR* Path=bFuture?
        TEXT("/Game/AAA/VFX/NS_NexusAlienWeaponPulse.NS_NexusAlienWeaponPulse"):
        TEXT("/Game/AAA/VFX/NS_NexusMuzzleFlash.NS_NexusMuzzleFlash");
    if(GetWorld())
        if(auto* FX=LoadObject<UNiagaraSystem>(nullptr,Path))
            UNiagaraFunctionLibrary::SpawnSystemAtLocation(GetWorld(),FX,Origin);
}
void UNexusWeaponComponent::UnlockSciFiFromResearch()
{
    if(!GetOwner() || !GetOwner()->HasAuthority())return;
    bSciFiUnlocked=true;
    for(int32 I=4;I<Arsenal.Num();++I)Arsenal[I].bUnlocked=true;
    GetOwner()->ForceNetUpdate();
}
FString UNexusWeaponComponent::GetCurrentName() const
{
    return Arsenal.IsValidIndex(EquippedIndex)?Arsenal[EquippedIndex].WeaponId.ToString():TEXT("Unbewaffnet");
}
int32 UNexusWeaponComponent::GetMagazineAmmo() const
{
    return Arsenal.IsValidIndex(EquippedIndex)?Arsenal[EquippedIndex].InMagazine:0;
}
int32 UNexusWeaponComponent::GetReserveAmmo() const
{
    return Arsenal.IsValidIndex(EquippedIndex)?Arsenal[EquippedIndex].ReserveAmmo:0;
}
void UNexusWeaponComponent::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const
{
    Super::GetLifetimeReplicatedProps(Out);
    DOREPLIFETIME_CONDITION(UNexusWeaponComponent,Arsenal,COND_OwnerOnly);
    DOREPLIFETIME_CONDITION(UNexusWeaponComponent,EquippedIndex,COND_OwnerOnly);
    DOREPLIFETIME_CONDITION(UNexusWeaponComponent,bSciFiUnlocked,COND_OwnerOnly);
}
