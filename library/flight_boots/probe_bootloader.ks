// Probe Boot Sequence v0.0.1
// (c) Utoxin, 2018

FUNCTION require {
	PARAMETER file.
	PARAMETER runOnce IS TRUE.
	PARAMETER copyFromVol IS 0.
	PARAMETER runFromVol IS 1.
	
	LOCAL localFile IS runFromVol+":"+file.
	LOCAL remoteFile IS copyFromVol+":"+file.
	
	IF (NOT EXISTS(localFile) AND EXISTS(remoteFile)) {
		COMPILE remoteFile TO localFile + ".ksm".
	}

	IF (runOnce) {
		RUNONCEPATH(localFile).
	} ELSE {
		RUNPATH(localFile).
	}
}

require("/library/standard_lib").
require("/library/probe_lib").

// Make sure default throttle is at 0 to avoid accidents
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

SET updateScript TO "0:/updates/"+SHIP:NAME + ".update".

IF (HOMECONNECTION:ISCONNECTED) {
	IF (EXISTS(updateScript)) {
		NOTIFY("Update script found...").

		COMPILE updateScript TO "1:/update"
		transfer_file(updateScript, "1:/update").
		RUNPATH("1:/update").
		DELETEPATH("1:/update").
		transfer_file(updateScript, updateScript + ".done".
	}
}

IF (EXISTS("1:/startup")) {
	NOTIFY("Running startup script...").

	RUNPATH("1:/startup").
} ELSE {
	NOTIFY("No startup script...").

	WAIT UNTIL HOMECONNECTION:ISCONNECTED.
	WAIT 15.
	REBOOT.
}