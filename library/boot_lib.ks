// Boot Library v0.0.1
// (c) Utoxin, 2018
@LAZYGLOBAL OFF.

// Specialized check for available boot loader script
FUNCTION boot_file_available {
	PARAMETER file.
	
	LOCAL localFile IS PATH(CORE:VOLUME) + "boot/" + file + ".ksm".
	LOCAL remoteFile IS shipScriptSource + "boot/" + file + ".ks".
	
	await_connection().

	RETURN EXISTS(localFile) OR EXISTS(remoteFile).
}

// Used to replace the default bootloader on the core with another script
FUNCTION replace_bootloader {
	PARAMETER file.
	PARAMETER forceReplace IS FALSE.

	LOCAL oldBoot IS CORE:BOOTFILENAME.
	LOCAL localFile IS PATH(CORE:VOLUME) + "boot/" + file + ".ksm".
	LOCAL remoteFile IS shipScriptSource + "boot/" + file + ".ks".

	IF (forceReplace OR NOT EXISTS(localFile)) {
		await_connection().

		transfer_compiled_file(remoteFile, localFile).
	}

	SET CORE:BOOTFILENAME TO "/boot/" + file + ".ksm".
	DELETEPATH(oldBoot).
	MOVEPATH(remoteFile, remoteFile + ".done").

	REBOOT.
}