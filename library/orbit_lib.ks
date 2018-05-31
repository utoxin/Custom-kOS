// Orbital Utility Methods v0.0.1
// (c) Utoxin, 2018
@LAZYGLOBAL OFF.

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

FUNCTION time_to_burn {
	PARAMETER delta_v.
	PARAMETER starting_weight.
	
	// dv = isp * g0 * ln(starting_weight / final_weight)
	// dv / (isp * g0) = ln (start / final)
	// e^(dv / (isp * g0)) = start / final
	// e^(dv / (isp * g0)) / start = 1 / final
	// start / (e ^ ( dv / (isp * g0))) = final
	
	LOCAL final_weight IS starting_weight / ( CONSTANT:E ^ ( delta_v / (calculate_isp() * 9.80665))).
	
	LOCAL fuel_to_burn IS starting_weight - final_weight.
	LOCAL burn_rate IS SHIP:AVAILABLETHRUST / (9.80665 * calculate_isp()).
	
	RETURN fuel_to_burn / burn_rate.

	// thrust = kg/s * g0 * isp
	// thrust / (g0 * isp) = kg/s
	
}

FUNCTION remaining_deltav {
	LOCAL dryMass IS SHIP:MASS - ((SHIP:LIQUIDFUEL + SHIP:OXIDIZER) * 0.005).
	RETURN calculate_isp() * 9.80665 * LN(SHIP:MASS / dryMass).
}

FUNCTION calculate_isp {
	LOCAL numerator IS 0.
	LOCAL divisor IS 0.
	
	FOR shipPart IN SHIP:PARTS {
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