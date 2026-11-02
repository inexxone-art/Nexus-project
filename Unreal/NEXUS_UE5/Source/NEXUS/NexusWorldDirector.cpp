#include "NexusWorldDirector.h"
#include "NexusBridge.h"
#include "NexusBus.h"
#include "NexusVehicle.h"
#include "NexusExplorer.h"
#include "NexusRescueTarget.h"
#include "NexusIndustrySite.h"
#include "NexusSaveGame.h"
#include "NexusCampaignComponent.h"
#include "NexusSimulationComponent.h"
#include "Kismet/GameplayStatics.h"
#include "Engine/World.h"
#include "Engine/StaticMesh.h"
#include "Components/StaticMeshComponent.h"
#include "Components/SceneComponent.h"
#include "Components/SkyLightComponent.h"
#include "Materials/MaterialInterface.h"
#include "Engine/DirectionalLight.h"
#include "Engine/SkyLight.h"
#include "Engine/ExponentialHeightFog.h"
#include "Components/ExponentialHeightFogComponent.h"
#include "Components/LightComponent.h"
#include "UObject/UObjectGlobals.h"

ANexusWorldDirector::ANexusWorldDirector()
{
    PrimaryActorTick.bCanEverTick=false;
    bReplicates=true;
    WorldMemory=CreateDefaultSubobject<UNexusSimulationComponent>(TEXT("NEXUS_WORLD_MEMORY"));
    Story=CreateDefaultSubobject<UNexusCampaignComponent>(TEXT("NEXUS_STORY_DIRECTOR"));
    RootComponent=CreateDefaultSubobject<USceneComponent>(TEXT("MissionWorldRoot"));
    Stock.Add(TEXT("Wood"),12);
    Stock.Add(TEXT("Iron"),10);
}
void ANexusWorldDirector::BeginPlay()
{
    Super::BeginPlay();
    if(!HasAuthority())return;
    WorldMemory->InitializeWorld();
    Story->LoadCampaignData();
    CreateStageWorld();
    CreateLighting();
    Bridge=GetWorld()->SpawnActor<ANexusBridge>(ANexusBridge::StaticClass(),FVector(0,0,1950),FRotator::ZeroRotator);
    Bus=GetWorld()->SpawnActor<ANexusBus>(ANexusBus::StaticClass(),FVector(0,0,2440),FRotator::ZeroRotator);
    RescueTruck=GetWorld()->SpawnActor<ANexusVehicle>(ANexusVehicle::StaticClass(),FVector(-6900,0,2160),FRotator::ZeroRotator);
    RescueHelicopter=GetWorld()->SpawnActor<ANexusVehicle>(ANexusVehicle::StaticClass(),FVector(6300,1050,2300),FRotator::ZeroRotator);
    if(RescueHelicopter)
    {
        RescueHelicopter->bHelicopter=true;
        if(auto* Model=LoadObject<UStaticMesh>(nullptr,
            TEXT("/Game/AAA/Geometry/Hero/SM_NEXUS_RescueHelicopter.SM_NEXUS_RescueHelicopter")))
        {
            RescueHelicopter->Visual->SetStaticMesh(Model);
            RescueHelicopter->Visual->SetRelativeScale3D(FVector::OneVector);
        }
        else
            RescueHelicopter->Visual->SetRelativeScale3D(FVector(8.f,3.f,2.f));
    }
    CreateRescueTargets();
    CreateFactories();
    Inform(TEXT("ADLERKLAMM: Steige mit E ein und fahre ueber die Bruecke."));
}
void ANexusWorldDirector::CreateSceneryBox(FVector Pos,FVector Scale,FRotator Rotation,const TCHAR* Name)
{
    auto* Mesh=NewObject<UStaticMeshComponent>(this,FName(Name));
    Mesh->SetupAttachment(RootComponent);
    Mesh->SetMobility(EComponentMobility::Static);
    Mesh->SetStaticMesh(LoadObject<UStaticMesh>(nullptr,TEXT("/Engine/BasicShapes/Cube.Cube")));
    Mesh->SetWorldTransform(FTransform(Rotation,Pos,Scale));
    Mesh->SetCollisionProfileName(TEXT("BlockAll"));
    FString AssetPath;
    const FString Label(Name);
    if(Label.Contains(TEXT("Cliff"))) AssetPath=TEXT("/Game/AAA/Materials/M_AlpineRock.M_AlpineRock");
    else if(Label.Contains(TEXT("Road"))) AssetPath=TEXT("/Game/AAA/Materials/M_WetAsphalt.M_WetAsphalt");
    else if(Label.Contains(TEXT("River"))) AssetPath=TEXT("/Game/AAA/Materials/M_RiverMud.M_RiverMud");
    else if(Label.Contains(TEXT("Plateau"))) AssetPath=TEXT("/Game/AAA/Materials/M_ForestSoil.M_ForestSoil");
    if(!AssetPath.IsEmpty())
        if(auto* Material=LoadObject<UMaterialInterface>(nullptr,*AssetPath))
            Mesh->SetMaterial(0,Material);
    AddInstanceComponent(Mesh);
    Mesh->RegisterComponent();
}
void ANexusWorldDirector::CreateStageWorld()
{
    // Minimal safe geometry for an immediately playable test scene.
    // Replace with a streamed, art-authored World Partition Landscape in production.
    CreateSceneryBox(FVector(-8400,0,1945),FVector(43.f,26.f,1.f),FRotator::ZeroRotator,TEXT("WestApproachRoad"));
    CreateSceneryBox(FVector(8400,0,1945),FVector(43.f,26.f,1.f),FRotator::ZeroRotator,TEXT("EastApproachRoad"));
    CreateSceneryBox(FVector(-8400,0,1270),FVector(44.f,65.f,11.f),FRotator::ZeroRotator,TEXT("WestCliffPlateau"));
    CreateSceneryBox(FVector(8400,0,1270),FVector(44.f,65.f,11.f),FRotator::ZeroRotator,TEXT("EastCliffPlateau"));
    CreateSceneryBox(FVector(0,-4700,700),FVector(168.f,35.f,18.f),FRotator(FMath::DegreesToRadians(0),0,0),TEXT("NorthCliffFace"));
    CreateSceneryBox(FVector(0,4700,700),FVector(168.f,35.f,18.f),FRotator::ZeroRotator,TEXT("SouthCliffFace"));
    CreateSceneryBox(FVector(0,0,-600),FVector(170.f,50.f,7.f),FRotator::ZeroRotator,TEXT("RiverBase"));
    // Actual approach roads now meet the 82m bridge at X = +/-4100cm.
    // These geometry pillars are nonproduction visual/physics placeholders.
    for(int32 I=-3;I<=3;I+=2)
    {
        const float X=I*1000.f;
        const FString North=FString::Printf(TEXT("ViaductNorth_%d"),I);
        const FString South=FString::Printf(TEXT("ViaductSouth_%d"),I);
        CreateSceneryBox(FVector(X,-430.f,950.f),FVector(1.3f,2.5f,19.f),FRotator::ZeroRotator,*North);
        CreateSceneryBox(FVector(X,430.f,950.f),FVector(1.3f,2.5f,19.f),FRotator::ZeroRotator,*South);
    }
    // UE5 world Partition/PCG/Nanite import anchor: place high-poly meshes in the
    // editor; fallback blocks are development-only, not the quality target.
}
void ANexusWorldDirector::CreateLighting()
{
    ADirectionalLight* Sun=GetWorld()->SpawnActor<ADirectionalLight>();
    if(Sun) { Sun->SetActorRotation(FRotator(-42.f,28.f,0)); Sun->GetLightComponent()->SetIntensity(5.0f); }
    ASkyLight* Sky=GetWorld()->SpawnActor<ASkyLight>();
    if(Sky) { Sky->GetLightComponent()->SetIntensity(0.7f); }
    AExponentialHeightFog* Fog=GetWorld()->SpawnActor<AExponentialHeightFog>();
    if(Fog && Fog->GetComponent())
    {
        Fog->GetComponent()->SetFogDensity(0.012f);
        Fog->GetComponent()->bEnableVolumetricFog=true;
    }
}
void ANexusWorldDirector::CreateRescueTargets()
{
    const FVector Sites[3]={
        FVector(5180,-670,2060),FVector(5900,750,2060),FVector(6820,-650,2060)
    };
    for(int32 Id=0;Id<3;Id++)
    {
        ANexusRescueTarget* Person=GetWorld()->SpawnActor<ANexusRescueTarget>(ANexusRescueTarget::StaticClass(),Sites[Id],FRotator::ZeroRotator);
        if(!Person) continue;
        Person->SurvivorId=Id;
        Person->SetActorHiddenInGame(true);
        Person->SetActorEnableCollision(false);
        Survivors.Add(Person);
    }
}
void ANexusWorldDirector::CreateFactories()
{
    const ENexusIndustry Types[]={
        ENexusIndustry::LoggingCamp,ENexusIndustry::Quarry,ENexusIndustry::Smelter,
        ENexusIndustry::OilPlatform,ENexusIndustry::Refinery,ENexusIndustry::CementPlant,
        ENexusIndustry::AsphaltPlant
    };
    const FVector Locations[]={
        FVector(8100,1450,1970),FVector(8050,-1450,1970),FVector(7100,1450,1970),
        FVector(9400,-1650,1970),FVector(6400,-1450,1970),
        FVector(5750,1500,1970),FVector(5400,-1650,1970)
    };
    for(int32 Index=0;Index<7;++Index)
    {
        auto* Site=GetWorld()->SpawnActor<ANexusIndustrySite>(ANexusIndustrySite::StaticClass(),Locations[Index],FRotator::ZeroRotator);
        if(!Site) continue;
        Site->Facility=Types[Index];
        Site->SetConstructed(Types[Index]==ENexusIndustry::LoggingCamp);
        Industry.Add(Site);
    }
}
void ANexusWorldDirector::Inform(const FString& Message)
{
    RadioMessage=Message;
    UE_LOG(LogTemp,Display,TEXT("NEXUS: %s"),*Message);
}
void ANexusWorldDirector::VehicleAdvanced(ANexusVehicle* Vehicle)
{
    if(!Vehicle || Vehicle->bHelicopter || Phase!=ENexusIncidentPhase::Approach) return;
    const FVector P=Vehicle->GetActorLocation();
    if(FMath::Abs(P.X)<3800.f && FMath::Abs(P.Y)<1300.f && !bEnteredSpan)
    {
        bEnteredSpan=true;
        if(Story) Story->CompleteObjective(TEXT("scan_damage"));
    }
    if(bEnteredSpan && P.X>4600.f && FMath::Abs(P.Y)<2000.f)
    {
        Phase=ENexusIncidentPhase::Collapse;
        if(WorldMemory)
        {
            WorldMemory->SetRoadDamage(TEXT("adlerklamm"),100);
            const FName Incident=WorldMemory->EvaluateIncident(TEXT("adlerklamm"),1);
            if(Incident!=NAME_None)UE_LOG(LogTemp,Display,TEXT("NEXUS EVENT: %s"),*Incident.ToString());
        }
        if(Bridge) Bridge->Collapse();
        if(Bus) Bus->DropBehindPlayer();
        for(TObjectPtr<ANexusRescueTarget> Person:Survivors) if(Person && !Person->bRescued)
        {
            Person->SetActorHiddenInGame(false);
            Person->SetActorEnableCollision(true);
        }
        Phase=ENexusIncidentPhase::RoleChoice;
        Inform(TEXT("NOTRUF: IST HIER EIN SANITAETER ODER PILOT? F1 SANITAETER | F2 PILOT | F3 BODENSUCHE"));
    }
}
void ANexusWorldDirector::ChooseRescueRole(ENexusRescueRole NewRole)
{
    if(Phase!=ENexusIncidentPhase::RoleChoice || NewRole==ENexusRescueRole::None)return;
    Role=NewRole;
    Phase=ENexusIncidentPhase::Rescue;
    Inform(Role==ENexusRescueRole::Pilot
      ? TEXT("PILOT: F zur Ausstiegsposition, E beim Helikopter. Dann zu den Rettungspunkten fliegen und E betaetigen.")
      : TEXT("BODENEINSATZ: Mit E drei markierte Ueberlebende retten."));
}
int32 ANexusWorldDirector::RescuedCount() const
{
    int32 Num=0;
    for(TObjectPtr<ANexusRescueTarget> Person:Survivors) if(Person && Person->bRescued) ++Num;
    return Num;
}
bool ANexusWorldDirector::RescuePerson(ANexusRescueTarget* Person)
{
    if(Phase!=ENexusIncidentPhase::Rescue || !Person || Person->bRescued) return false;
    Person->MarkRescued();
    if(WorldMemory) WorldMemory->RecordRescue(FName(*FString::Printf(TEXT("survivor_%d"),Person->SurvivorId)),TEXT("adlerklamm"));
    const int32 Count=RescuedCount();
    if(Story)
    {
        if(Count==1)Story->CompleteObjective(TEXT("evacuate_bus"));
        if(Count==2)Story->CompleteObjective(TEXT("protect_medics"));
    }
    Inform(FString::Printf(TEXT("BERGUNG: %d/3 Personen gerettet."),Count));
    if(Count==3)
    {
        Phase=ENexusIncidentPhase::Reconstruction;
        if(!bPaidRescue) { Credits+=780; bPaidRescue=true; }
        Inform(TEXT("ALLE GEBORGEN. +780 Credits. Bruecke braucht Eisen, Zement und Asphalt."));
    }
    return true;
}
bool ANexusWorldDirector::TryVehicleRescue(ANexusVehicle* Vehicle)
{
    if(!Vehicle || !Vehicle->bHelicopter || Phase!=ENexusIncidentPhase::Rescue || Role!=ENexusRescueRole::Pilot)
        return false;
    for(TObjectPtr<ANexusRescueTarget> Person:Survivors)
    {
        if(!Person || Person->bRescued)continue;
        const FVector Difference=Vehicle->GetActorLocation()-Person->GetActorLocation();
        const float Distance2D=FVector2D(Difference.X,Difference.Y).Size();
        const bool bHover=Difference.Z>400.f && Difference.Z<2400.f && Distance2D<=1700.f
                        && FMath::Abs(Vehicle->LinearSpeed)<750.f;
        if(bHover) return RescuePerson(Person);
    }
    Inform(TEXT("PILOT: 4-24m ueber dem Vermissten schweben; langsam fliegen und E druecken."));
    return true;
}
bool ANexusWorldDirector::TryInteract(ANexusExplorer* Explorer)
{
    if(!Explorer) return false;
    const FVector P=Explorer->GetActorLocation();
    if(Phase==ENexusIncidentPhase::Rescue && Role!=ENexusRescueRole::Pilot)
    {
        for(TObjectPtr<ANexusRescueTarget> Person:Survivors)
            if(Person && !Person->bRescued && FVector::Dist(P,Person->GetActorLocation())<560.f)
                return RescuePerson(Person);
    }
    if(Phase==ENexusIncidentPhase::Reconstruction && P.X>4200.f && P.X<7600.f
       && FMath::Abs(P.Y)<1400.f)
        return TryReconstruct();
    for(TObjectPtr<ANexusIndustrySite> Site:Industry)
        if(Site && FVector::Dist2D(P,Site->GetActorLocation())<850.f)
            return TryBuildOrOperate(Site);
    Inform(TEXT("Zur Rettungsmarkierung, Industrieanlage oder zum Fahrzeug gehen und E druecken."));
    return false;
}
bool ANexusWorldDirector::HasCosts(const TMap<FName,int32>& Need) const
{
    return Stock.CanSpend(Need);
}
bool ANexusWorldDirector::TryBuildOrOperate(ANexusIndustrySite* Site)
{
    if(!Site) return false;
    TMap<FName,int32> Need,Output;
    int32 MoneyCost=0;
    if(!Site->bConstructed)
    {
        switch(Site->Facility)
        {
        case ENexusIndustry::Quarry: Need.Add(TEXT("Wood"),2);Need.Add(TEXT("Iron"),1);MoneyCost=120;break;
        case ENexusIndustry::Smelter: Need.Add(TEXT("Wood"),3);Need.Add(TEXT("Iron"),2);MoneyCost=240;break;
        case ENexusIndustry::OilPlatform: Need.Add(TEXT("Wood"),3);Need.Add(TEXT("Iron"),2);MoneyCost=430;break;
        case ENexusIndustry::Refinery: Need.Add(TEXT("Wood"),2);Need.Add(TEXT("Iron"),2);MoneyCost=280;break;
        case ENexusIndustry::CementPlant: Need.Add(TEXT("Wood"),2);Need.Add(TEXT("Iron"),2);MoneyCost=240;break;
        case ENexusIndustry::AsphaltPlant: Need.Add(TEXT("Wood"),2);Need.Add(TEXT("Iron"),2);MoneyCost=260;break;
        default:break;
        }
        if(Credits<MoneyCost || !Stock.Spend(Need))
        {
            Inform(TEXT("BAU: Es fehlen Holz, Eisen oder Credits."));
            return true;
        }
        Credits-=MoneyCost;
        Site->SetConstructed(true);
        Inform(TEXT("ANLAGE GEBAUT. Nochmals E: Rohstoffe produzieren."));
        return true;
    }
    if(!Site->IsReady(GetWorld()->GetTimeSeconds()))
    {
        Inform(TEXT("Produktionszyklus laeuft. Bitte einige Sekunden warten."));
        return true;
    }
    switch(Site->Facility)
    {
    case ENexusIndustry::LoggingCamp: Output.Add(TEXT("Wood"),4);break;
    case ENexusIndustry::Quarry:
        Output.Add(TEXT("IronOre"),4);Output.Add(TEXT("Limestone"),3);
        Output.Add(TEXT("Sand"),2);Output.Add(TEXT("Gravel"),3);break;
    case ENexusIndustry::Smelter:
        Need.Add(TEXT("IronOre"),3);Need.Add(TEXT("Wood"),1);Output.Add(TEXT("Iron"),3);break;
    case ENexusIndustry::OilPlatform:Output.Add(TEXT("CrudeOil"),5);break;
    case ENexusIndustry::Refinery:
        Need.Add(TEXT("CrudeOil"),3);Output.Add(TEXT("Bitumen"),2);Output.Add(TEXT("Diesel"),2);break;
    case ENexusIndustry::CementPlant:
        Need.Add(TEXT("Limestone"),3);Need.Add(TEXT("Sand"),1);Output.Add(TEXT("Cement"),3);break;
    case ENexusIndustry::AsphaltPlant:
        Need.Add(TEXT("Gravel"),3);Need.Add(TEXT("Bitumen"),1);Output.Add(TEXT("Asphalt"),4);break;
    }
    if(!Stock.Spend(Need))
    {
        Inform(TEXT("PRODUKTION: Vorprodukte fehlen. Zuerst die vorherigen Arbeitsschritte erledigen."));
        return true;
    }
    for(const auto& Pair:Output) Stock.Add(Pair.Key,Pair.Value);
    Site->Cooldown(GetWorld()->GetTimeSeconds());
    Inform(TEXT("PRODUKTION ERFOLGREICH: Rohstoffe wurden verarbeitet und eingelagert."));
    return true;
}
bool ANexusWorldDirector::TryReconstruct()
{
    if(Phase!=ENexusIncidentPhase::Reconstruction)return false;
    TMap<FName,int32> Need;
    switch(RebuildStage)
    {
    case 0:
        RebuildStage=1;Inform(TEXT("BAUPHASE 1/4: Truemmer und Schutt gerauemt."));return true;
    case 1:
        Need.Add(TEXT("Wood"),4);Need.Add(TEXT("Iron"),6);
        if(!Stock.Spend(Need)) { Inform(TEXT("STAHLTRAeGER: 4 Holz und 6 Eisen fehlen."));return true; }
        RebuildStage=2;
        if(Story) Story->CompleteObjective(TEXT("stabilize_route"));
        Inform(TEXT("BAUPHASE 2/4: Neue Stahltraeger installiert."));return true;
    case 2:
        Need.Add(TEXT("Cement"),4);Need.Add(TEXT("Wood"),2);
        if(!Stock.Spend(Need)) { Inform(TEXT("BETONIEREN: 4 Zement und 2 Holz fehlen."));return true; }
        RebuildStage=3;Inform(TEXT("BAUPHASE 3/4: Betonfahrbahn neu gegossen."));return true;
    default:
        Need.Add(TEXT("Asphalt"),3);
        if(!Stock.Spend(Need)) { Inform(TEXT("FAHRBAHN: 3 Asphalt aus der Asphaltmischanlage fehlen."));return true; }
        RebuildStage=4;
        if(Bridge)Bridge->Reconstruct();
        if(WorldMemory) WorldMemory->SetBridgeRepaired(TEXT("adlerklamm"));
        if(Story) Story->CompleteObjective(TEXT("reach_rescue_rally"));
        Phase=ENexusIncidentPhase::Complete;
        Credits+=420;
        Inform(TEXT("BAUPHASE 4/4: Asphalt und Freigabe. BRUECKE OFFEN! +420 Credits."));
        return true;
    }
}
FString ANexusWorldDirector::PhaseDescription() const
{
    switch(Phase)
    {
    case ENexusIncidentPhase::Approach: return TEXT("ADLERKLAMM | Im Rettungsfahrzeug ueber die Bruecke fahren");
    case ENexusIncidentPhase::Collapse: return TEXT("ACHTUNG: Der Bus stuerzt hinter dir ab!");
    case ENexusIncidentPhase::RoleChoice:return TEXT("NOTRUF | F1 SANITAETER  F2 PILOT  F3 BODENSUCHE");
    case ENexusIncidentPhase::Rescue:return FString::Printf(TEXT("BERGUNG | %d / 3 Ueberlebende"),RescuedCount());
    case ENexusIncidentPhase::Reconstruction:return FString::Printf(TEXT("WIEDERAUFBAU | Phase %d von 4. E am Brueckenbereich"),RebuildStage+1);
    default:return TEXT("BRUECKE WIEDERHERGESTELLT | Neue Auftraege folgen in spaeteren Versionen");
    }
}
FString ANexusWorldDirector::ResourceDescription() const
{
    return FString::Printf(TEXT("HOLZ %d  EISEN %d  ERZ %d  ZEMENT %d  ASPHALT %d  OEL %d  DIESEL %d  CREDITS %d"),
        Stock.Get(TEXT("Wood")),Stock.Get(TEXT("Iron")),Stock.Get(TEXT("IronOre")),
        Stock.Get(TEXT("Cement")),Stock.Get(TEXT("Asphalt")),Stock.Get(TEXT("CrudeOil")),
        Stock.Get(TEXT("Diesel")),Credits);
}
void ANexusWorldDirector::SaveProgress()
{
    auto* Save=Cast<UNexusSaveGame>(UGameplayStatics::CreateSaveGameObject(UNexusSaveGame::StaticClass()));
    if(!Save)return;
    Save->Stock=Stock;
    Save->Credits=Credits;
    Save->Phase=Phase;
    Save->Role=Role;
    Save->RebuildStage=RebuildStage;
    Save->bRewardPaid=bPaidRescue;
    if(Story)
    {
        Save->ActiveChapter=Story->ActiveMissionIndex;
        Save->ActiveStoryPhase=Story->ActivePhaseIndex;
        Save->CompletedChapters=Story->CompletedChapters;
        Save->Decisions=Story->DecisionJournal;
    }
    if(WorldMemory)
    {
        Save->Sectors=WorldMemory->Sectors;
        Save->Citizens=WorldMemory->Citizens;
        Save->EventHistory=WorldMemory->EventHistory;
        Save->GameDay=WorldMemory->GameDay;
    }
    for(TObjectPtr<ANexusIndustrySite> Site:Industry)if(Site && Site->bConstructed)Save->ConstructedSites.Add(Site->Facility);
    for(TObjectPtr<ANexusRescueTarget> Person:Survivors)if(Person && Person->bRescued)Save->RescuedIds.Add(Person->SurvivorId);
    if(UGameplayStatics::SaveGameToSlot(Save,TEXT("NEXUS_UNREAL_V1"),0))
        Inform(TEXT("Unreal NEXUS: Missionsfortschritt gespeichert."));
}
void ANexusWorldDirector::LoadProgress()
{
    auto* Save=Cast<UNexusSaveGame>(UGameplayStatics::LoadGameFromSlot(TEXT("NEXUS_UNREAL_V1"),0));
    if(!Save){Inform(TEXT("Kein Unreal-Spielstand vorhanden."));return;}
    Stock=Save->Stock;Credits=Save->Credits;Phase=Save->Phase;
    Role=Save->Role;RebuildStage=Save->RebuildStage;bPaidRescue=Save->bRewardPaid;
    if(Story)Story->Restore(Save->ActiveChapter,Save->ActiveStoryPhase,Save->CompletedChapters,Save->Decisions);
    if(WorldMemory)WorldMemory->Restore(Save->Sectors,Save->Citizens,Save->EventHistory,Save->GameDay);
    for(TObjectPtr<ANexusIndustrySite> Site:Industry)if(Site)Site->SetConstructed(Save->ConstructedSites.Contains(Site->Facility));
    for(TObjectPtr<ANexusRescueTarget> Person:Survivors)if(Person)
    {
        if(Save->RescuedIds.Contains(Person->SurvivorId))Person->MarkRescued();
        else {Person->SetActorHiddenInGame(Phase==ENexusIncidentPhase::Approach);Person->SetActorEnableCollision(Phase!=ENexusIncidentPhase::Approach);}
    }
    if(Phase!=ENexusIncidentPhase::Approach && Phase!=ENexusIncidentPhase::Complete)
    {
        if(Bridge)Bridge->Collapse();
        if(Bus)Bus->DropBehindPlayer();
    }
    if(Phase==ENexusIncidentPhase::Complete && Bridge)Bridge->Reconstruct();
    Inform(TEXT("NEXUS: Spielstand geladen."));
}
void ANexusWorldDirector::TeleportToApproach(ANexusExplorer* Explorer)
{
    if(!Explorer)return;
    Explorer->SetActorLocation(FVector(-7300,310,2180));
    Inform(TEXT("MISSION ADLERKLAMM | E beim Rettungsfahrzeug, dann W zum Fahren."));
}

bool ANexusWorldDirector::InvestigateEvidence(const FVector& Position)
{
    if(!HasAuthority() || Phase<ENexusIncidentPhase::Rescue || !Story)return false;
    // Evidence from the east canyon rescue rally, not a global skip button.
    if(Position.X<4400.f || Position.X>7900.f || FMath::Abs(Position.Y)>2200.f)
        return false;
    if(Story->CompleteObjective(TEXT("investigate_saboteur")))
    {
        Inform(TEXT("FUNDFUNK: Hinweise auf die sabotierte Bruecke gesichert. Auftrag aktualisiert."));
        return true;
    }
    return false;
}
bool ANexusWorldDirector::ChooseCampaignOutcome(bool bProtectCivilians)
{
    if(!HasAuthority() || !Story)return false;
    const FName Answer=bProtectCivilians?TEXT("protect_civilians"):TEXT("secure_critical_data");
    // The active mission's own objective is required by the story state machine.
    if(!Story->MissionCatalog.IsValidIndex(Story->ActiveMissionIndex))return false;
    const auto& Mission=Story->MissionCatalog[Story->ActiveMissionIndex];
    if(!Mission.Stages.IsValidIndex(Story->ActivePhaseIndex))return false;
    const FName Required=Mission.Stages[Story->ActivePhaseIndex].Action;
    if(!Story->ResolveChoice(Answer,Required))return false;
    if(WorldMemory)
    {
        if(auto* S=WorldMemory->FindSectorMutable(TEXT("adlerklamm")))
        {
            if(bProtectCivilians) S->Safety=FMath::Min(100,S->Safety+12);
            else S->TradeSupply=FMath::Min(100,S->TradeSupply+12);
        }
    }
    Inform(bProtectCivilians?TEXT("WAHL: Zivilisten gerettet. Spaetere Einsaetze merken sich das."):
        TEXT("WAHL: Beweisdaten gesichert. Versorgung gewinnt Stabilitaet."));
    return true;
}
