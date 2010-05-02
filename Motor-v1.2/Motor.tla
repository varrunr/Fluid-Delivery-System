--------------------------------MODULE Motor----------------------------------------------
EXTENDS Naturals
CONSTANT ThresholdPulseWidth, LOW , HIGH
VARIABLE Motor, ActiveTime
-----------------------------------------------------------------------------------------


MotorInvariant == /\ Motor \in [
			 unit : (1..100),
			 holes : (1..60),
		  	 fluidLevel : {"Empty","NonEmpty"},
		  	 state : { "disabled","enabled" },
		         pulseWidth : (0..HIGH)
		  	 ]
		  /\ ActiveTime \in (0..600)
		  
IncrementActiveTime == 	/\ ActiveTime' = IF (Motor.pulseWidth \in (0..LOW)) THEN 
						ActiveTime + 8
			   		 ELSE 
						IF Motor.pulseWidth \in (LOW..HIGH) THEN
							ActiveTime + 4
  					        ELSE 	
  					        	ActiveTime + 1		
-----------------------------------------------------------------------------------------

EnableMotor ==  /\ ActiveTime = 0
	  	/\ Motor.state = "disabled"
	  	/\ Motor'= [Motor EXCEPT !.state = "enabled"]
	  
DisableMotor == /\ ActiveTime > 0
	   	/\ Motor.state = "enabled"
	   	/\ Motor'= [Motor EXCEPT !.state = "disabled"]
		/\ ActiveTime' = 0
-----------------------------------------------------------------------------------------

Deliver ==  /\ IF Motor.unit = 0 THEN
		/\ Motor'.fluidLevel = "Empty"
		/\ DisableMotor
		/\ UNCHANGED << Motor.holes , Motor.unit >>
	     ELSE
		/\ Motor'.unit = Motor.unit - 1 
		/\ UNCHANGED Motor.fluidlevel 

Rotate == /\ Motor.pulseWidth > Motor.ThresholdPulseWidth
	  /\ Deliver
	  /\ IF Motor.holes = 60 THEN Motor'.holes = 1 ELSE Motor'.holes = Motor.holes + 1
	  /\ IncrementActiveTime

-----------------------------------------------------------------------------------------

EmptyInt == /\ Motor.fluidLevel = "Empty"
	    /\ Motor'= [Motor EXCEPT !.fluidLevel = "NonEmpty"]

Refill == /\ Motor.state = "disabled"
	  /\ Motor.fluidLevel = "Empty"
	  /\ Motor'= [Motor EXCEPT !.fluidLevel = "NonEmpty", !.unit = 100]
	  /\ IncrementActiveTime

Next == EnableMotor \/ Rotate \/ Refill

InitMotor ==  /\ MotorInvariant
	      /\ Motor = [  pulseWidth |-> 0,
			   holes |-> 1,
			   unit |-> 100,
			   fluidLevel |-> "NonEmpty",
			   state |-> "disabled"
	      		 ]
      	      /\ ActiveTime = 0

MotorSpec == InitMotor /\ []Next

-----------------------------------------------------------------------------------------------
THEOREM MotorSpec => []MotorInvariant
===============================================================================================
