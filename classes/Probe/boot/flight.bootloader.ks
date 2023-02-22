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

UNTIL False {
    WAIT UNTIL SHIP:HASNODE.

    LOCK max_acc TO SHIP:MAXTHRUST/SHIP:MASS.
    SET burn_duration TO node:DELTAV:MAG/max_acc.
    SET node TO NEXTNODE.

    WAIT UNTIL node:ETA <= (burn_duration/2 + 60).


    WAIT 1.
}