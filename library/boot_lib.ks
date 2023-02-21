// Boot Library v0.0.1
// (c) Utoxin, 2018
@LAZYGLOBAL OFF.

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