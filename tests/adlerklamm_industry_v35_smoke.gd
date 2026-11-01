extends SceneTree
const INDUSTRY = preload("res://scripts/nexus_industry_v35.gd")
const RESCUE = preload("res://scripts/nexus_adlerklamm_rescue_v35.gd")
const OVERLAY = preload("res://scripts/nexus_v35_operations.gd")
const WORLD = preload("res://scripts/world.gd")

func _initialize() -> void:
    call_deferred("_test")

func check(value: bool, text: String, code: int) -> bool:
    if value:
        return true
    push_error("V3.5 FAIL | "+text)
    quit(code)
    return false

func _test() -> void:
    var industry: NexusIndustryV35 = INDUSTRY.new()
    root.add_child(industry)
    await process_frame
    var p: Vector3 = NexusIndustryV35.SITES["quarry"]["position"]
    if not check(not industry.operate("quarry",p,10).get("ok",false),"unbuilt quarry produces",1): return
    if not check(not industry.build_site("quarry",Vector3.ZERO,20,20,9999).get("ok",false),"remote construction",2): return
    if not check(industry.build_site("quarry",p,20,20,9999).get("ok",false),"quarry construction",3): return
    var quarry: Dictionary = industry.operate("quarry",p,20)
    if not check(quarry.get("ok",false) and industry.inventory["iron_ore"] == 4,"ore extraction",4): return
    for id in ["smelter","oilrig","refinery","cement","asphalt"]:
        var at: Vector3 = NexusIndustryV35.SITES[id]["position"]
        if not check(industry.build_site(id,at,20,20,9999).get("ok",false),"site "+id,5): return
    if not check(industry.operate("smelter",NexusIndustryV35.SITES["smelter"]["position"],20).get("iron",0) == 3,"smelting iron",6): return
    industry.operate("oilrig",NexusIndustryV35.SITES["oilrig"]["position"],20)
    industry.operate("refinery",NexusIndustryV35.SITES["refinery"]["position"],20)
    industry.operate("cement",NexusIndustryV35.SITES["cement"]["position"],20)
    industry.operate("asphalt",NexusIndustryV35.SITES["asphalt"]["position"],20)
    if not check(industry.inventory["cement"] == 3 and industry.inventory["asphalt"] == 4,"cement/asphalt from refinery chain",7): return
    if not check(not industry.take_materials(4,3),"insufficient cement must not be consumed",8): return
    industry.operate("quarry",p,20)
    industry.operate("cement",NexusIndustryV35.SITES["cement"]["position"],20)
    if not check(industry.take_materials(4,3),"building consumes both materials",9): return
    var data: Dictionary = industry.get_data()
    var industry_copy: NexusIndustryV35 = INDUSTRY.new()
    root.add_child(industry_copy)
    await process_frame
    industry_copy.restore_data(data)
    if not check(industry_copy.get_data()["inventory"] == industry.inventory and industry_copy.built.size() == 6,"industrial save/load",10): return
    var mission: NexusAdlerklammRescueV35 = RESCUE.new()
    root.add_child(mission)
    await process_frame
    if not check(mission.trigger(),"radio distress call",11): return
    if not check(mission.choose_role("sanitaeter"),"medical role",12): return
    for target in NexusAdlerklammRescueV35.TARGETS:
        var saved: Dictionary = mission.try_rescue(target)
        if not check(saved.get("handled",false),"survivor interaction",13): return
    if not check(mission.phase == "completed" and mission.claim_reward() and not mission.claim_reward(),"rescue exactly-once reward",14): return
    var save: Dictionary = mission.get_data()
    var mission_copy: NexusAdlerklammRescueV35 = RESCUE.new()
    root.add_child(mission_copy)
    await process_frame
    mission_copy.restore_data(save)
    if not check(mission_copy.phase == "completed" and mission_copy.rescued.size() == 3 and mission_copy.reward_claimed,"rescue save",15): return
    var helicopter_mission: NexusAdlerklammRescueV35 = RESCUE.new()
    root.add_child(helicopter_mission)
    await process_frame
    helicopter_mission.trigger()
    helicopter_mission.choose_role("pilot")
    var bad: Dictionary = helicopter_mission.try_rescue(NexusAdlerklammRescueV35.TARGETS[0]+Vector3(0,9,0),"Auto",0)
    if not check(bad.get("handled",false) and helicopter_mission.rescued.size() == 0,"pilot requires helicopter",16): return
    var good: Dictionary = helicopter_mission.try_rescue(NexusAdlerklammRescueV35.TARGETS[0]+Vector3(0,10,0),"Helikopter",3)
    if not check(good.get("handled",false) and helicopter_mission.rescued.size() == 1,"winch hover",17): return
    var arm: NexusV35Operations = OVERLAY.new()
    if not check(arm != null and WORLD != null,"new world integration scripts load",18): return
    print("NEXUS V3.5 PASS | automatic mission state, role choice, production, resource costs, saves")
    quit(0)
