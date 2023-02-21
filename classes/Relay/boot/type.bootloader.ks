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
require("/library/orbit_lib").
require("/library/launch_lib").

LOCAL target_altitude IS 100000.
LOCAL target_inclination IS 90.

execute_launch(target_altitude, target_inclination).
