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

FUNCTION tilt {
	PRINT "Rebuilding PINBALL library...".
	CD("0:/boot").
	COMPILE pinball.
	PRINT "Done.".
}

print "IDE Loaded!".