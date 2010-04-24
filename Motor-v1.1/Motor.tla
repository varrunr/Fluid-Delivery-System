--------------------------------MODULE Motor----------------------------------------------
EXTENDS Naturals
CONSTANT ThresholdPulseWidth, LOW , MEDIUM , HIGH
VARIABLE Motor
-----------------------------------------------------------------------------------------

MotorInvariant == /\ Motor \in [
			 unit \in (1..100)
			 holes \in (1..60)
		  	 fluidLevel : {"Empty","NonEmpty"}
		  	 activeTime \in (0..6)
		  	 state : { "disabled","enabled" }
		         (pulseWidth \in {0,LOW,MEDIUM,HIGH} 
		  	 ]
		  /\ IncrementActiveTime
		
IncrementActiveTime == /\ IF Motor.pulseWidth \in LOW THEN Motor'.activeTime = Motor.activeTime + 0.08
		       /\ IF Motor.pulseWidth \in MEDIUM THEN Motor'.activeTime = Motor.activeTime + 0.04
		       /\ IF Motor.pulseWidth \in HIGH THEN Motor'.activeTime = Motor.activeTime + 0.01

-----------------------------------------------------------------------------------------

EnableMotor ==  /\ Motor.activeTime = 0
	  	/\ Motor.state = "disabled"
	  	/\ Motor'.state = "enabled"
	  
DisableMotor == /\ activeTime > 0
	   	/\ Motor.state = "enabled"
	   	/\ Motor'.state = "disabled"

-----------------------------------------------------------------------------------------
	   
Deliver == IF unit = 0 THEN
		/\ Motor'.fluidLevel = "Empty"
		/\ DisableMotor
	     ELSE
		/\ Motor'.unit = Motor.unit - 1
		 
Rotate == /\ pulseWidth > ThresholdPulseWidth
	  /\ Deliver
	  /\ IF Motor.holes = 60 THEN Motor'.holes = 1 ELSE Motor'.holes = Motor.holes + 1

-----------------------------------------------------------------------------------------

EmptyInt == /\ Motor.fluidLevel = "Empty"
	    /\ Motor'.fluidLevel = "NonEmpty"

Refill == /\ Motor.MotorState = "disabled"
	  /\ Motor'.fluidLevel = "NonEmpty"
	  /\ Motor'.unit = 100

Next == Rotate \/ Refill 

StartMotor == /\ EnableMotor
	      /\ Motor.pulse = 0
	      /\ Motor.holes = 0
	      /\ Motor.fluidLevel = "NonEmpty"
	
MotorSpec == StartMotor /\ []Next

-----------------------------------------------------------------------------------------------
THEOREM MotorSpec => []MotorInvariant
===============================================================================================
