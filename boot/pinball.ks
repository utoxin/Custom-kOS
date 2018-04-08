// Standard Boot Sequence v0.0.5
// (c) Utoxin, 2018
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
require("/library/boot_lib").

IF (CORE:PART:TAG = "") {
	SET CORE:PART:TAG TO "UID_" + CORE:PART:UID.
}

LOCAL coreBoot IS CORE:PART:TAG + ".core.bootloader".
LOCAL shipBoot IS SHIP:NAME + ".ship.bootloader".

IF (boot_file_available(coreBoot)) {
	print "Found core-specific bootloader...".
	replace_bootloader(coreBoot).
} ELSE IF (boot_file_available(shipBoot)) {
	print "Found ship-specific bootloader...".
	replace_bootloader(shipBoot).
} ELSE {
	PRINT "Specific bootloader not found.".
	PRINT "Searching for '" + SHIP:TYPE + "' bootloader...".

	LOCAL classBoot IS SHIP:TYPE + ".bootloader".
	IF (boot_file_available(classBoot, "type")) {
		replace_bootloader(classBoot, "type").
	} ELSE {
		PRINT "No better bootloader found. Terminating process.".
	}
}