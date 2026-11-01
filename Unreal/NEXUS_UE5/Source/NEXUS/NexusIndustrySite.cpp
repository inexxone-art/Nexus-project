#include "NexusIndustrySite.h"
#include "Components/StaticMeshComponent.h"
#include "Components/TextRenderComponent.h"
#include "UObject/ConstructorHelpers.h"

ANexusIndustrySite::ANexusIndustrySite()
{
    PrimaryActorTick.bCanEverTick=false;
    Building=CreateDefaultSubobject<UStaticMeshComponent>(TEXT("IndustryReplaceWithNaniteMesh"));
    RootComponent=Building;
    Building->SetCollisionProfileName(TEXT("BlockAll"));
    static ConstructorHelpers::FObjectFinder<UStaticMesh> Placeholder(TEXT("/Engine/BasicShapes/Cube.Cube"));
    if(Placeholder.Succeeded()) Building->SetStaticMesh(Placeholder.Object);
    Building->SetRelativeScale3D(FVector(6.f,5.f,6.f));
    Label=CreateDefaultSubobject<UTextRenderComponent>(TEXT("IndustryLabel"));
    Label->SetupAttachment(Building);
    Label->SetRelativeLocation(FVector(0,0,430));
    Label->SetWorldSize(49.f);
    SetConstructed(false);
}
void ANexusIndustrySite::SetConstructed(bool Value)
{
    bConstructed=Value;
    if(Value && !FacilityMesh.IsNull()) Building->SetStaticMesh(FacilityMesh.LoadSynchronous());
    Building->SetVisibility(Value);
    Label->SetText(FText::FromString(Value?TEXT("PRODUZIEREN [E]"):TEXT("BAUPLATZ: BAUEN [E]")));
}
