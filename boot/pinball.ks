// Standard Boot Sequence v0.0.5
// (c) Utoxin, 2018
@LAZYGLOBAL OFF.

// Pruned down boot-only require
LOCAL FUNCTION require {
	PARAMETER file.

	PRINT "Compiling file " + file + " to local storage.".

	LOCAL localFile IS PATH(VOLUME(1)) + file + ".ksm".
	LOCAL remoteFile IS PATH(VOLUME(0)) + file + ".ks".

	COMPILE remoteFile TO localFile.

	RUNPATH(localFile).
}

require("/library/standard_lib").
require("/library/comm_lib").
require("/library/boot_lib").

IF (CORE:PART:TAG = "") {
	SET CORE:PART:TAG TO "UID_" + CORE:PART:UID.
}

select_bootloader().
