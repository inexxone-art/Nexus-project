extends RefCounted
class_name NexusDriveModel
## Deterministic arcade vehicle dynamics with surfaces, precipitation, brakes and wear.
## No claim of tyre telemetry, suspension solver or real vehicle homologation.

static func grip_factor(kind: String, weather_code: int) -> float:
    var base: float = 1.0
    match kind:
        "helicopter": base = 1.0
        "tank": base = 0.86
        "excavator": base = 0.74
        "utility": base = 0.88
        _: base = 1.0
    match weather_code:
        2: base *= 0.77 # Rain
        3: base *= 0.58 # Snow
        1: base *= 0.95 # Fog: visibility penalty separate
    return clampf(base,0.3,1.0)

static func maximum_speed_kmh(record: Dictionary, health: float, fuel: float) -> float:
    if health <= 0.0 or fuel <= 0.0:
        return 0.0
    var rated: float = maxf(5.0,float(record.get("top_kmh",85.0)))
    return rated * lerpf(0.42,1.0,clampf(health/100.0,0,1))

static func braking_distance(speed_mps: float, grip: float) -> float:
    # Game simulation with fixed nominal braking, not a real-road safety estimate.
    return absf(speed_mps)*absf(speed_mps)/(2.0*maxf(1.5,9.5*grip))

static func service_price(condition: float, fuel: float) -> int:
    return maxi(0,ceili((100.0-clampf(condition,0,100))*0.85+(100.0-clampf(fuel,0,100))*0.35))
