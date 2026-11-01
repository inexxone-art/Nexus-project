#pragma once
#include "CoreMinimal.h"
#include "GameFramework/HUD.h"
#include "NexusHUD.generated.h"

UCLASS()
class NEXUS_API ANexusHUD : public AHUD
{
    GENERATED_BODY()
public:
    virtual void DrawHUD() override;
private:
    void Panel(float X,float Y,float W,float H);
    void Text(const FString& Value,float X,float Y,float Scale=1.0f,FLinearColor Tint=FLinearColor::White);
};
