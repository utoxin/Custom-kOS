// Orbital Utility Methods v0.0.1
// (c) Utoxin, 2018
@LAZYGLOBAL OFF.

FUNCTION altitude_orbit_target_velocity {
	PARAMETER base_body.  // Body to calculate orbit around
	PARAMETER semi_major. // The orbital semi major axis
	
	RETURN sqrt(base_body:MU / (semi_major + base_body:RADIUS)).
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
	LOCAL last_isp IS 0.
	
	FOR shipPart IN SHIP:PARTS {
		IF shipPart:typename() = "Engine" AND shipPart:IGNITION {
			SET numerator TO numerator + (shipPart:ISP * shipPart:MAXFUELFLOW).
			SET divisor TO divisor + shipPart:MAXFUELFLOW.
		}
	}
	
	IF (divisor <> 0) {
		SET last_isp TO numerator / divisor.
	}
	
	RETURN last_isp.
}

FUNCTION execute_next_node {
	SAS OFF.

	SET node TO NEXTNODE.

	PRINT "Node in: " + ROUND(node:ETA) + "s, dV: " + ROUND(node:DELTAV:MAG).

	LOCK max_acc TO SHIP:MAXTHRUST/SHIP:MASS.
	SET burn_duration TO node:DELTAV:MAG/max_acc.

	PRINT "Crude Estimated Burn Duration: " + ROUND(burn_duration) + "s".

	WAIT UNTIL node:ETA <= (burn_duration/2 + 60).

	SET nodeBurn TO node:DELTAV.
	LOCK STEERING TO nodeBurn.

	WAIT UNTIL VANG(nodeBurn, SHIP:FACING:VECTOR) < 0.25.
	WAIT UNTIL node:ETA <= (burn_duration / 2).

	SET tset TO 0.
	LOCK THROTTLE TO tset.

	SET done TO False.

	set dv0 to node:deltav.

	UNTIL done {
		SET tset TO MIN(node:DELTAV / max_acc, 1).

		IF VDOT(dv0, node:deltav) < 0 {
			PRINT "End Burn. Remaining dV: " + ROUND(node:DELTAV:MAG, 1) + "m/s, vdot: " + ROUND(VDOT(dv0, node:DELTAV), 1).
			LOCK THROTTLE TO 0.
			BREAK.
		}

		IF node:DELTAV:MAG < 0.1 {
			PRINT "Finalizing burn. Remaining dV: " + ROUND(node:DELTAV:MAG, 1) + "m/s, vdot: " + ROUND(VDOT(dv0, node:DELTAV), 1).
			WAIT UNTIL VDOT(dv0, node:DELTAV) < 0.5.

			LOCK THROTTLE TO 0.
			PRINT "End Burn. Remaining dV: " + ROUND(node:DELTAV:MAG, 1) + "m/s, vdot: " + ROUND(VDOT(dv0, node:DELTAV), 1).
			SET done TO True.
		}
	}

	UNLOCK STEERING.
	UNLOCK THROTTLE.
	REMOVE node.
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	SAS ON.
}