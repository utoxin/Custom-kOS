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

FUNCTION await_connection {
	PARAMETER antenna IS FALSE.

	IF (NOT HOMECONNECTION:ISCONNECTED) {
		IF (antenna = FALSE) {
		}

		IF (m:HASEVENT("Activate")) {
			m:DOEVENT("Activate").
		}

		m:SETFIELD("target", "Mission Control").
		
		WAIT UNTIL HOMECONNECTION:ISCONNECTED.
	}
}

FUNCTION get_antenna {
	LOCAL antennas IS SHIP:GETMODULES("ModuleRTAntenna").
	
}

// Transfer file to specified location
FUNCTION transfer_file {
	PARAMETER originFile. // Expected to be full paths including volume
	PARAMETER destFile.
	
	IF (EXISTS(originFile)) {
		COPYPATH(originFile, destFile).
	}
}

// Transfer a compiled version of the file to specified location
FUNCTION transfer_compiled_file {
	PARAMETER originFile. // Expected to be full paths including volume
	PARAMETER destFile.
	
	print "Origin: " + originFile.
	print "Dest: " + destFile.
	
	IF (EXISTS(originFile)) {
		COMPILE originFile TO destFile.
		print "COMPILE " + originFile + " TO " + destFile.
	}
}

// HUD message
FUNCTION notify {
	PARAMETER message.
	
	HUDTEXT("kOS : " + message, 5, 2, 50, YELLOW, false).
}

