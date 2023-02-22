// Boot Library v0.0.1
// (c) Utoxin, 2018
@LAZYGLOBAL OFF.

require("/library/comm_lib").

// Specialized check for available boot loader script
FUNCTION boot_file_available {
	PARAMETER file.
	
	LOCAL localFile IS PATH(CORE:VOLUME) + "boot/" + file + ".ksm".
	LOCAL remoteFile IS shipScriptSource + "boot/" + file + ".ks".

	PRINT "Checking for file: " + localFile.
	PRINT "Checking for file: " + remoteFile.
	
	await_connection().

	RETURN EXISTS(localFile) OR EXISTS(remoteFile).
}

FUNCTION class_boot_file_available {
	PARAMETER file.
	
	LOCAL localFile IS PATH(CORE:VOLUME) + "boot/" + file + ".ksm".
	LOCAL remoteFile IS classScriptSource + "boot/" + file + ".ks".

	PRINT "Checking for file: " + localFile.
	PRINT "Checking for file: " + remoteFile.
	
	await_connection().

	RETURN EXISTS(localFile) OR EXISTS(remoteFile).
}

// Used to replace the default bootloader on the core with another script
FUNCTION replace_bootloader {
	PARAMETER file.
	PARAMETER forceReplace IS FALSE.

	LOCAL oldBoot IS CORE:BOOTFILENAME.
	LOCAL localFile IS "/boot/" + file + ".ksm".
	LOCAL remoteFile IS shipScriptSource + "boot/" + file + ".ks".

	replace_file(oldBoot, localFile, remoteFile, forceReplace).
}

FUNCTION replace_class_bootloader {
	PARAMETER file.
	PARAMETER forceReplace IS FALSE.

	LOCAL oldBoot IS CORE:BOOTFILENAME.
	LOCAL localFile IS "/boot/" + file + ".ksm".
	LOCAL remoteFile IS classScriptSource + "boot/" + file + ".ks".

	replace_file(oldBoot, localFile, remoteFile, forceReplace).
}

FUNCTION replace_file {
	PARAMETER oldBoot.
	PARAMETER localFile.
	PARAMETER remoteFile.
	PARAMETER forceReplace.

	IF (forceReplace OR NOT EXISTS(localFile)) {
		await_connection().

		transfer_compiled_file(remoteFile, localFile).

		PRINT CORE:BOOTFILENAME.

		SET CORE:BOOTFILENAME TO localFile.

		if (oldBoot <> localFile) {
			DELETEPATH(oldBoot).
		}
	}

	REBOOT.
}

FUNCTION select_bootloader {
	GLOBAL shipScriptSource IS PATH(VOLUME(0)) + "ships/" + SHIP:NAME + "/".
	GLOBAL classScriptSource IS PATH(VOLUME(0)) + "classes/" + SHIP:TYPE + "/".

	LOCAL coreBoot IS CORE:PART:TAG + ".flight.bootloader".
	LOCAL shipBoot IS "flight.bootloader".
	LOCAL classBoot IS "flight.bootloader".

	IF (SHIP:STATUS = "PRELAUNCH") {
		SET coreBoot TO CORE:PART:TAG + ".launch.bootloader".
		SET shipBoot TO "launch.bootloader".
		SET classBoot TO "launch.bootloader".
	}

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
}
