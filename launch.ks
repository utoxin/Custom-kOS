CLEARSCREEN.

LOCK THROTTLE TO 1.0.

// Countdown loop
PRINT "Counting down:".
FROM {LOCAL countdown IS 10.} UNTIL countdown = 0 STEP {SET countdown TO countdown - 1.} DO {
   PRINT "..." + countdown.
   WAIT 1.
}

WHEN MAXTHRUST = 0 THEN {
   WAIT 0.5.
   PRINT "Staging...".
   STAGE.
   IF STAGE:NUMBER > 0 {
      PRESERVE.
   }.
}

SET MYSTEER TO HEADING(90,90).
LOCK STEERING TO MYSTEER.

UNTIL SHIP:VELOCITY:SURFACE:MAG > 1700 {
   SET v TO SHIP:VELOCITY:SURFACE:MAG.
   SET pitch to 90.

   IF v >= 100 AND v < 200 {
      SET pitch TO 80.
   } ELSE IF v >= 200 AND v < 300 {
      SET pitch TO 70.
   } ELSE IF v >= 300 AND v < 400 {
      SET pitch TO 60.
   } ELSE IF v >= 400 AND v < 500 {
      SET pitch TO 55.
   } ELSE IF v >= 500 AND v < 600 {
      SET pitch TO 50.
   } ELSE IF v >= 600 AND v < 700 {
      SET pitch TO 45.
   } ELSE IF v >= 700 AND v < 800 {
      SET pitch TO 40.
   } ELSE IF v >= 800 AND v < 900 {
      SET pitch TO 35.
   } ELSE IF v >= 900 AND v < 1000 {
      SET pitch TO 30.
   } ELSE IF v >= 1000 AND v < 1200 {
      SET pitch TO 25.
   } ELSE IF v >= 1200 AND v < 1400 {
      SET pitch TO 20.
   } ELSE IF v >= 1400 AND v < 1600 {
      SET pitch TO 15.
   } ELSE IF v >= 1600 {
      SET pitch TO 10.
   }.

   SET MYSTEER TO HEADING(90,pitch).
   PRINT "Pitching to " + pitch + " degrees." AT (0,15).
   PRINT ROUND(SHIP:APOAPSIS, 0) AT (0,16).
}.

WHEN SHIP:APOAPSIS > 80000 THEN {
   PRINT "ENABLING SAS.".
   SAS ON.
}.

WAIT UNTIL SHIP:ALTITUDE > 80000.