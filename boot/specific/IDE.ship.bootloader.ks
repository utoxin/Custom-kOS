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

COPYPATH("0:/ide/", "1:/").

WAIT 1.
TOGGLE AG1.
TOGGLE AG2.

ON AG10 {
	RUNPATH("1:/ide/tilt").
	RETURN TRUE.
}

print "IDE Loaded!".