#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "NexusCompanion.generated.h"
class UTextRenderComponent;

UENUM(BlueprintType)
enum class ENexusSupportOrder : uint8
{
    Follow, Hold, Scout, Medic, Repair
};

UCLASS(Blueprintable)
class NEXUS_API ANexusCompanion : public ACharacter
{
    GENERATED_BODY()
public:
    ANexusCompanion();
    virtual void BeginPlay() override;
    virtual void Tick(float DeltaSeconds) override;
    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const override;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,Replicated) ENexusSupportOrder Order=ENexusSupportOrder::Follow;
    UPROPERTY(EditAnywhere,BlueprintReadWrite,Replicated) FName Callsign=TEXT("NEXUS_HELPER");
    UPROPERTY(VisibleAnywhere,BlueprintReadOnly) TObjectPtr<UTextRenderComponent> RoleMarker;
    UFUNCTION(BlueprintCallable) void AssignOrder(ENexusSupportOrder NewOrder);
private:
    float NextThinkTime=0.f;
};
