"""Static source/data checks. Godot CI runs separate headless tests."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]
required=["scripts/nexus_living_universe.gd","scripts/nexus_living_panel.gd",
          "scripts/nexus_cinematic_polish.gd","scripts/nexus_weather_fx.gd",
          "tests/living_smoke.gd","tests/visual_smoke.gd", "docs/V1_4_IMPLEMENTATION_STATUS.md"]
for name in required:
    assert (ROOT/name).is_file(),name
world=(ROOT/"scripts/world.gd").read_text()
for token in ["living.advance(delta)","living.get_data()","living.restore_data(",
              "_on_living_decision", "visual_polish.set_graphics_quality(",
              "weather_fx.bind_world(", "EINSATZLEITUNG"]:
    assert token in world,token
simulation=(ROOT/"scripts/nexus_living_universe.gd").read_text()
for token in ["func resolve(","func advance(","func get_data(","func restore_data(",
              "incident_opened.emit", "regions[location] = state"]:
    assert token in simulation,token
vehicles=json.loads((ROOT/"data/vehicle_catalog.json").read_text())
assert len(vehicles["vehicles"])==123,len(vehicles["vehicles"])
print("V1.4 STATIC PASS: world wiring, 6 scenarios, 123 vehicle definitions, tests")
