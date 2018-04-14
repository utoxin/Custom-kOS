@LAZYGLOBAL OFF.

// Pruned down boot-only require
LOCAL FUNCTION require {
	PARAMETER file.

	LOCAL localFile IS PATH(VOLUME(1)) + file + ".ksm".
	LOCAL remoteFile IS PATH(VOLUME(0)) + file + ".ks".

	IF (NOT EXISTS(localFile) AND EXISTS(remoteFile)) {
		COMPILE remoteFile TO localFile.
	}

	RUNPATH(localFile).
}

require("/library/standard_lib").
require("/library/orbit_lib").

GLOBAL target_twr IS 2.31.
GLOBAL last_isp IS 0.

SAS OFF.
RCS OFF.

LOCK targetPitch TO 90 - 1.038 * ALT:RADAR^0.4.
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
	PRINT "Apoapsis:     " + APOAPSIS AT (0, 15).
	PRINT "Periapsis:    " + PERIAPSIS AT (0, 16).
	PRINT "Eccentricity: " + eccen AT (0, 17).
	PRINT "Q:            " + SHIP:Q AT (0, 18).
	PRINT "ISP:          " + calculate_isp() AT (0, 19).
	PRINT "DeltaV:       " + remaining_deltav() AT (0, 20).
}

LOCAL g IS BODY:MU / ((SHIP:ALTITUDE + BODY:RADIUS)^2).
LOCK max_twr TO MAX(SHIP:MAXTHRUST / (g * SHIP:MASS), 0.01).
LOCK THROTTLE TO get_throttle().
LOCK eccen TO 1 - ( 2 / ( ( (APOAPSIS + BODY:RADIUS) / (PERIAPSIS + BODY:RADIUS) ) + 1 )).

LOCAL last_thrust IS SHIP:MAXTHRUST.

WHEN ALTITUDE > 40000 THEN {
	LOCAL fairings IS SHIP:PARTSTAGGED("Fairing").
	IF (fairings:LENGTH > 0) {
		fairings[0]:GETMODULEBYINDEX(0):DOEVENT("deploy").
	}
}

UNTIL APOAPSIS > 75000 {
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

UNTIL ETA:APOAPSIS < 10 {
	debug_data().
	WAIT 0.
}

SET TARGET_TWR TO MAX(0.05, eccen * 2).

LOCAL last_eccen IS 1.

UNTIL ((last_eccen - eccen) < -0.00001 AND PERIAPSIS > 70000) OR (APOAPSIS > 80000 AND PERIAPSIS > 70000) {
	debug_data().

	SET last_eccen TO eccen.
	WAIT 0.
}

LOCK THROTTLE TO 0.

UNTIL FALSE.