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

IF (CORE:PART:TAG = "SECONDARY") {
	LOCAL processorList IS list().
	LIST PROCESSORS IN processorList.
	IF (processorList:LENGTH() > 1) {
		PRINT "Secondary Core: Detected other cores on vehicle... Exitting.".
	} ELSE {
		select_bootloader().
	}
} ELSE {
	select_bootloader().
}
