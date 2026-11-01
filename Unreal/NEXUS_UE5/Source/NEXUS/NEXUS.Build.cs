using UnrealBuildTool;
public class NEXUS : ModuleRules
{
    public NEXUS(ReadOnlyTargetRules Target) : base(Target)
    {
        PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
        PublicDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine", "InputCore", "PhysicsCore", "UMG" });
        PrivateDependencyModuleNames.AddRange(new string[] { "Slate", "SlateCore" });
        CppStandard = CppStandardVersion.Cpp20;
    }
}
