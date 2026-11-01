extends SceneTree
## Deterministic domain test: no graphical renderer required.
const LEGACY = preload("res://scripts/nexus_legacy.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(condition: bool, description: String) -> bool:
    if condition: return true
    push_error("NEXUS V2.1 LEGACY: " + description)
    quit(1)
    return false

func _run() -> void:
    var state: NexusLegacy = LEGACY.new()
    root.add_child(state)
    if not _check(not state.choose_career("BadCareer").get("ok",true),"bad career accepted"): return
    if not _check(state.set_identity("Nova", "Pilot").get("ok",false),"valid avatar rejected"): return
    if not _check(not state.set_identity("X", "Pilot").get("ok",true),"invalid callsign accepted"): return
    if not _check(state.choose_career("Forschung").get("ok",false),"career switch rejected"): return
    var first: Dictionary = state.meet_npc("Mara")
    var xp_after_meet: int = state.xp
    state.meet_npc("Mara")
    if not _check(first.get("ok",false) and xp_after_meet == state.xp,"NPC interaction can farm XP"): return
    for index in range(8): state.award_activity("rescue","Rettung %d" % index,100)
    if not _check(state.level >= 3 and state.skill_points > 0,"XP level-up missing"): return
    if not _check(state.invest_skill("rescue").get("ok",false),"talent spending missing"): return
    if not _check(not state.purchase_property("garage",0).get("ok",true),"purchase without money succeeded"): return
    var purchased: Dictionary = state.purchase_property("garage",1000)
    if not _check(purchased.get("ok",false) and purchased.get("money",0) == -850,"property purchase failed"): return
    if not _check(not state.purchase_property("garage",1000).get("ok",true),"duplicate property bought"): return
    if not _check(not state.purchase_ship_module("scanner",0).get("ok",true),"ship no-money gate missing"): return
    if not _check(state.purchase_ship_module("scanner",800).get("money",0)==-700,"ship purchase failed"): return
    if not _check(not state.purchase_ship_module("scanner",800).get("ok",true),"ship duplicate succeeded"): return
    var wallet: int = 3000
    for i in range(3):
        var outcome: Dictionary = state.upgrade_vehicle("nexus-vortex","motor",wallet)
        if not _check(outcome.get("ok",false),"motor rank upgrade failed"): return
        wallet += int(outcome.get("money",0))
    if not _check(state.tuning_for("nexus-vortex")["motor"] == 3,"motor tuning not saved"): return
    if not _check(not state.upgrade_vehicle("nexus-vortex","motor",wallet).get("ok",true),"tuning rank exceeded"): return
    if not _check(not state.upgrade_vehicle("", "motor",wallet).get("ok",true),"empty vehicle id succeeded"): return
    if not _check(state.reveal_planet_secret("umbra","vault_01").get("ok",false),"discovery missing"): return
    if not _check(not state.reveal_planet_secret("umbra","vault_01").get("ok",true),"discovery duplicated"): return
    for i in range(130): state.record_decision("decision_%d" % i,"Dauerhafte Entscheidung %d" % i)
    if not _check(state.events.size() == 100,"chronicle cap broken"): return
    var snapshot: Dictionary = state.get_data()
    var clone: NexusLegacy = LEGACY.new()
    root.add_child(clone)
    clone.restore_data(snapshot)
    if not _check(clone.summary().contains("Nova") and clone.properties.has("garage") and clone.ship_modules.has("scanner"),"save roundtrip missing profile/property/ship"): return
    if not _check(clone.tuning_for("nexus-vortex")["motor"] == 3 and clone.events.size() == 100,"save roundtrip lost tuning/history"): return
    clone.restore_data({"level":-5,"xp":999999999,"style":"rogue","skills":{"driving":999}})
    if not _check(clone.level == 1 and clone.style == "Explorer" and int(clone.skills["driving"]) == 5,"corrupted saves bypass limits"): return
    print("NEXUS V2.1 LEGACY LOGIC PASS: avatar, careers, XP, NPC, tuning, property, ship, discovery, bounded chronicle, save migration")
    quit(0)
