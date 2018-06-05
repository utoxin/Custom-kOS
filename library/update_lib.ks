@LAZYGLOBAL OFF.

FUNCTION update_files {
	LOCAL updateDir IS shipScriptSource + "updates/".
	
	await_connection().
	
	LOCAL updates IS OPEN(updateDir):LIST.

	RETURN EXISTS(localFile) OR EXISTS(remoteFile).
}

