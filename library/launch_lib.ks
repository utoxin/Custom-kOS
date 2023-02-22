// Launch Library v0.0.1
// (c) Utoxin, 2023
@LAZYGLOBAL OFF.


GLOBAL FUNCTION execute_launch {
	PARAMETER target_altitude.
	PARAMETER target_inclination.

	SAS OFF.
	RCS OFF.

	LOCAL target_twr IS 2.31.
	LOCAL last_isp IS 0.

	LOCK targetPitch TO MIN(90, SHIP:VELOCITY:SURFACE:MAG^2 * 0.0000255805 - 0.0928737 * SHIP:VELOCITY:SURFACE:MAG + 93.3309).

	LOCAL targetDirection IS 90.
	LOCK STEERING TO HEADING(targetDirection, targetPitch).

	WAIT 5.
	STAGE.
	WAIT 0.

	LOCAL FUNCTION get_throttle {
		IF (target_twr = 0) {
			RETURN 0.
		}
		
		IF ALTITUDE > 30000 {
			RETURN MAX(0, MIN(1, (target_twr + ((ALTITUDE - 30000) / 20000)) / max_twr)).
		} ELSE {
			RETURN MAX(0, MIN(1, target_twr / max_twr)).
		}
	}

	LOCAL FUNCTION debug_data {
		RETURN.

		PRINT "Apoapsis:     " + APOAPSIS + "     " AT (0, 15).
		PRINT "Periapsis:    " + PERIAPSIS + "     " AT (0, 16).
		PRINT "Eccentricity: " + eccen + "     " AT (0, 17).
		PRINT "Q:            " + SHIP:Q + "     " AT (0, 18).
		PRINT "ISP:          " + calculate_isp() + "     " AT (0, 19).
		PRINT "DeltaV:       " + remaining_deltav() + "     " AT (0, 20).
		PRINT "Pitch:        " + targetPitch + "     " AT (0, 21).
		PRINT "Apo Mag:      " + VELOCITYAT(ship, TIME:SECONDS + ETA:APOAPSIS):ORBIT:MAG + "     " AT (0, 22).
		PRINT "Target Vel:   " + altitude_orbit_target_velocity(BODY, target_altitude) + "     " AT (0, 23).
	}

	LOCAL g IS BODY:MU / ((SHIP:ALTITUDE + BODY:RADIUS)^2).
	LOCK max_twr TO MAX(SHIP:MAXTHRUST / (g * SHIP:MASS), 0.01).
	LOCK THROTTLE TO get_throttle().
	LOCK eccen TO 1 - ( 2 / ( ( (APOAPSIS + BODY:RADIUS) / (PERIAPSIS + BODY:RADIUS) ) + 1 )).

	LOCAL last_thrust IS SHIP:MAXTHRUST.

	WHEN targetPitch < 90 THEN {
		SET targetDirection TO target_inclination.
	}

	WHEN SHIP:Q < 0.01 AND SHIP:ALTITUDE > 30000 THEN {
		LOCAL fairings IS SHIP:PARTSTAGGED("Fairing").
		IF (fairings:LENGTH > 0) {
			fairings[0]:GETMODULEBYINDEX(0):DOEVENT("deploy").
		}
	}

	UNTIL APOAPSIS > target_altitude {
		IF (last_thrust - SHIP:MAXTHRUST > 10) {
			STAGE.
			WAIT 0.
			SET last_thrust TO SHIP:MAXTHRUST.
		}

		debug_data().
		WAIT 0.
	}.

	SET TARGET_TWR TO 0.
	LOCK STEERING TO PROGRADE.

	UNTIL ALTITUDE > 70000 {
		debug_data().
		WAIT 0.
	}

	// Set up a node to do circularization
	LOCAL myNode TO NODE(TIME:SECONDS + ETA:APOAPSIS, 0, 0, 0).
	ADD myNode.

	LOCAL target_orbit_velocity TO altitude_orbit_target_velocity(BODY, target_altitude).
	SET myNode:PROGRADE TO 0.9 * (target_orbit_velocity - VELOCITYAT(ship, TIME:SECONDS + ETA:APOAPSIS):ORBIT:MAG).
	
	LOCK myNodeEcc TO 1 - ( 2 / ( ( (myNode:ORBIT:APOAPSIS + BODY:RADIUS) / (myNode:ORBIT:PERIAPSIS + BODY:RADIUS) ) + 1 )).
	LOCAL last_node_ecc IS myNodeEcc.
	

	UNTIL (myNodeEcc > last_node_ecc) {
		SET last_node_ecc TO myNodeEcc.
		SET myNode:PROGRADE TO myNode:PROGRADE + 10.
		debug_data().
		WAIT 0.
	}

	SET last_node_ecc TO myNodeEcc.

	UNTIL (myNodeEcc > last_node_ecc) {
		SET last_node_ecc TO myNodeEcc.
		SET myNode:PROGRADE TO myNode:PROGRADE - 1.
		debug_data().
		WAIT 0.
	}

	SET last_node_ecc TO myNodeEcc.

	UNTIL (myNodeEcc > last_node_ecc) {
		SET last_node_ecc TO myNodeEcc.
		SET myNode:PROGRADE TO myNode:PROGRADE + 0.1.
		debug_data().
		WAIT 0.
	}

	LOCK STEERING TO myNode:BURNVECTOR.

	LOCAL ttb IS time_to_burn(myNode:DELTAV:MAG, SHIP:MASS).
	UNTIL myNode:ETA <= TTB / 2.

	LOCK max_twr TO SHIP:AVAILABLETHRUST / SHIP:MASS.
	LOCK target_throttle TO MAX(0.01, MIN(5, myNode:DELTAV:MAG / max_twr) / 5).

	LOCK THROTTLE TO target_throttle.
	LOCAL last_thrust IS SHIP:MAXTHRUST.

	UNTIL (myNode:DELTAV:MAG < 0.1) {
		IF (last_thrust - SHIP:MAXTHRUST > 10) {
			STAGE.
			WAIT 0.
			SET last_thrust TO SHIP:MAXTHRUST.
		}

		debug_data().
		WAIT 0.
	}

	LOCK THROTTLE TO 0.
	UNLOCK ALL.
	REMOVE myNode.	
	SAS ON.
	WAIT 0.
	SET SASMODE TO "PROGRADE".
}