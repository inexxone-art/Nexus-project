#include "NexusIndustrySite.h"
#include "Components/StaticMeshComponent.h"
#include "Components/TextRenderComponent.h"
#include "Net/UnrealNetwork.h"
#include "UObject/ConstructorHelpers.h"

ANexusIndustrySite::ANexusIndustrySite()
{
    PrimaryActorTick.bCanEverTick=false;
    bReplicates=true;
    Building=CreateDefaultSubobject<UStaticMeshComponent>(TEXT("IndustryReplaceWithNaniteMesh"));
    RootComponent=Building;
    Building->SetCollisionProfileName(TEXT("BlockAll"));
    static ConstructorHelpers::FObjectFinder<UStaticMesh> Placeholder(TEXT("/Engine/BasicShapes/Cube.Cube"));
    if(Placeholder.Succeeded())Building->SetStaticMesh(Placeholder.Object);
    Building->SetRelativeScale3D(FVector(6.f,5.f,6.f));
    Label=CreateDefaultSubobject<UTextRenderComponent>(TEXT("IndustryLabel"));
    Label->SetupAttachment(Building);
    Label->SetRelativeLocation(FVector(0,0,430));
    Label->SetWorldSize(49.f);
    OnRep_Facility();
}
void ANexusIndustrySite::SetConstructed(bool Value)
{
    if(!HasAuthority())return;
    bConstructed=Value;
    OnRep_Facility();
    ForceNetUpdate();
}
void ANexusIndustrySite::OnRep_Facility()
{
    if(!Building || !Label)return;
    if(bConstructed && !FacilityMesh.IsNull())
        if(auto* Mesh=FacilityMesh.LoadSynchronous())Building->SetStaticMesh(Mesh);
    // A hidden building never has collision, even when its construction preview exists.
    Building->SetVisibility(bConstructed);
    Building->SetCollisionEnabled(bConstructed?ECollisionEnabled::QueryAndPhysics:ECollisionEnabled::NoCollision);
    Label->SetText(FText::FromString(bConstructed?
       TEXT("PRODUZIEREN [E]"):TEXT("BAUPLATZ: BAUEN [E]")));
}
void ANexusIndustrySite::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const
{
    Super::GetLifetimeReplicatedProps(Out);
    DOREPLIFETIME(ANexusIndustrySite,Facility);
    DOREPLIFETIME(ANexusIndustrySite,bConstructed);
}
