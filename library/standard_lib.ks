// Standard Library v0.0.2
// (c) Utoxin, 2018
@LAZYGLOBAL OFF.

FUNCTION require {
	PARAMETER file.
	PARAMETER runOnce IS TRUE.
	PARAMETER copyFromVol IS Volume(0).
	PARAMETER runFromVol IS CORE:VOLUME.

	LOCAL localFile IS PATH(runFromVol) + file + ".ksm".
	LOCAL remoteFile IS PATH(copyFromVol) + file + ".ks".

	IF (NOT EXISTS(localFile) AND EXISTS(remoteFile)) {
		COMPILE remoteFile TO localFile.
	}

	IF (runOnce) {
		RUNONCEPATH(localFile).
	} ELSE {
		RUNPATH(localFile).
	}
}

FUNCTION purge {
	PARAMETER file.
	
	LOCAL localFile IS PATH(CORE:VOLUME) + file.
	
	IF (EXISTS(localFile)) {
		DELETEPATH(localFile).
	}
}

// HUD message
FUNCTION notify {
	PARAMETER message.
	
	HUDTEXT("kOS : " + message, 5, 2, 50, YELLOW, false).
}