using UnrealBuildTool;
public class NEXUS : ModuleRules
{
    public NEXUS(ReadOnlyTargetRules Target) : base(Target)
    {
        PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
        PublicDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine", "InputCore", "PhysicsCore", "UMG", "Json", "JsonUtilities", "Networking", "AIModule", "NavigationSystem", "Niagara" });
        PrivateDependencyModuleNames.AddRange(new string[] { "Slate", "SlateCore" });
        CppStandard = CppStandardVersion.Cpp20;
    }
}
