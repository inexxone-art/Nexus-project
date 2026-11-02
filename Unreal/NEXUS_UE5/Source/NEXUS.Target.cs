using UnrealBuildTool;
using System.Collections.Generic;
public class NEXUSTarget : TargetRules
{
    public NEXUSTarget(TargetInfo Target) : base(Target)
    {
        Type = TargetType.Game;
        DefaultBuildSettings = BuildSettingsVersion.V6;
        IncludeOrderVersion = EngineIncludeOrderVersion.Latest;
        ExtraModuleNames.Add("NEXUS");
    }
}
