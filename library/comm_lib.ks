@LAZYGLOBAL OFF.

FUNCTION await_connection {
	PARAMETER antenna IS FALSE.
	PARAMETER commTarget IS "Kerbin".

	IF (NOT HOMECONNECTION:ISCONNECTED) {
		UNTIL antenna {
			LOCAL p IS SHIP:PARTSTAGGED("Default Antenna").
			
			IF (p:LENGTH > 0) {
				SET antenna TO p:GETMODULE("ModuleRTAntenna")[0].
			} ELSE {
				SET p TO SHIP:PARTSDUBBEDPATTERN("antenna").
				IF (p:LENGTH > 0) {
					SET antenna TO p:GETMODULE("ModuleRTAntenna")[0].
				} ELSE {
					PRINT "No antenna found... Sleeping for ten seconds.".
					WAIT 10.
				}
			}
		}

		IF (antenna:HASEVENT("Activate")) {
			antenna:DOEVENT("Activate").
		}

		antenna:SETFIELD("target", commTarget).
		
		WAIT UNTIL HOMECONNECTION:ISCONNECTED.
	}
}

// Transfer file to specified location
FUNCTION transfer_file {
	PARAMETER originFile. // Expected to be full paths including volume
	PARAMETER destFile.
	
	IF (EXISTS(originFile)) {
		COPYPATH(originFile, destFile).
	}
}

// Transfer a compiled version of the file to specified location
FUNCTION transfer_compiled_file {
	PARAMETER originFile. // Expected to be full paths including volume
	PARAMETER destFile.
	
	IF (EXISTS(originFile)) {
		COMPILE originFile TO destFile.
	}
}

