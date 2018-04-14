// Orbital Utility Methods v0.0.1
// (c) Utoxin, 2018
@LAZYGLOBAL OFF

FUNCTION altitude_orbit_target_velocity {
	PARAMETER base_body.  // Body to calculate orbit around
	PARAMETER semi_major. // The orbital semi major axis
	
	RETURN sqrt(base_body:MU / target_altitude).
}

FUNCTION orbit_velocity_at_altitude {
	PARAMETER base_orbit.            // The orbit to base calculation on
	PARAMETER altitude_to_calculate. // The altitude to calculate velocity at
	
	RETURN sqrt(base_orbit:BODY:MU * ((2 / altitude_to_calculate) - (1 / base_orbit:SEMIMAJORAXIS))).
}

FUNCTION time_to_execute_maneuver {
	PARAMETER maneuver_deltav.
	
	
}

FUNCTION remaining_deltav {
	PARAMETER base_ship.
	
	LOCAL dryMass IS BASE_SHIP:MASS - ((BASE_SHIP:LIQUIDFUEL + BASE_SHIP:OXIDIZER) * 0.005).
	RETURN calculate_isp() * 9.80665 * LN(BASE_SHIP:MASS / dryMass).
}

FUNCTION calculate_isp {
	PARAMETER base_ship.

	LOCAL numerator IS 0.
	LOCAL divisor IS 0.
	
	FOR shipPart IN BASE_SHIP:PARTS {
		IF shipPart:typename() = "Engine" {
			SET numerator TO numerator + (shipPart:ISP * shipPart:FUELFLOW).
			SET divisor TO divisor + shipPart:FUELFLOW.
		}
	}
	
	IF (divisor <> 0) {
		SET last_isp TO numerator / divisor.
	}
	
	RETURN last_isp.
}