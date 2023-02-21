// Standard Boot Sequence v0.0.5
// (c) Utoxin, 2018
@LAZYGLOBAL OFF.

PRINT "DEBUGGING.".

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

GLOBAL shipScriptSource IS PATH(VOLUME(0)) + "ships/" + SHIP:NAME + "/".
GLOBAL classScriptSource IS PATH(VOLUME(0)) + "classes/" + SHIP:TYPE + "/".

LOCAL coreBoot IS CORE:PART:TAG + ".core.bootloader".
LOCAL shipBoot IS "ship.bootloader".
LOCAL classBoot IS "type.bootloader".

IF (boot_file_available(coreBoot)) {
	PRINT "Loading core-specific file...".
	replace_bootloader(coreBoot).
} ELSE IF (boot_file_available(shipBoot)) {
	PRINT "Loading ship-specific file...".
	replace_bootloader(shipBoot).
} ELSE IF (class_boot_file_available(classBoot)) {
	PRINT "Loading type-specific file...".
	replace_class_bootloader(classBoot).
} ELSE {
	PRINT "No boot update present. Purging boot_lib...".
	purge("/library/boot_lib").
	
	PRINT "Checking for script updates...".
	require("/library/update_lib").
}