--------------------------------MODULE Microcontroller----------------------------------------------
EXTENDS Naturals
VARIABLES value, state, noOfPulses, period, count, interrupt,input
----------------------------------------------------------------------------------------------------

MicrocontrollerInvariant == /\ value = {"Valid","Invalid"}
			    /\ state = {"Off","On"}
			    /\ noOfPulses \in (1..100)
			    /\ period \in (1..100)
			    /\ count \in (1..100)
			    /\ interrupt = {"None","Overflow","Empty"}
			    /\ input \in (1..100)
----------------------------------------------------------------------------------------------------

StorePWM(n) == /\ value = "Invalid"
	       /\ state = "On"
	       /\ noOfPulses = n
	       /\ value' = "Valid"

InvalidatePWM == /\ value = "Valid"
	         /\ value' = "Invalid"
	      	
----------------------------------------------------------------------------------------------------

SetPeriod(n) == /\ state = "On"
		/\ period'= n

CheckOverflow == /\ interrupt = "Overflow"

Increment == /\ state ="On"
	     /\ IF count = period THEN
		/\ interrupt' = "Overflow"
		/\ count'= 0
		ELSE
		/\ count' = count + 1
		
----------------------------------------------------------------------------------------------------

PowerOn == /\ state = "off"
	   /\ state' = "on"

PowerOff == /\ state = "on"
	    /\ state' = "off"

----------------------------------------------------------------------------------------------------

PWMactions == StorePWM(input) \/ InvalidatePWM
TCactions == Increment \/ SetPeriod(input) 
GPIOactions == PowerOff \/ PowerOn

----------------------------------------------------------------------------------------------------

Next == \/ PWMactions 
	\/ TCactions 
	\/ GPIOactions

InitializeMicrocontroller == /\ MicrocontrollerInvariant
		             /\ state = "off"
		             /\ count = 0
		       	     /\ period = 0
		             /\ noOfPulses = 0
		             /\ input = 0
	
MicrocontrollerSpec == InitializeMicrocontroller /\ []Next

-----------------------------------------------------------------------------------------------
THEOREM MicrocontrollerSpec => [] MicrocontrollerInvariant
===============================================================================================
