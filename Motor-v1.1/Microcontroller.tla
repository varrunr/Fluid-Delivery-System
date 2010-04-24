--------------------------------MODULE Microcontroller----------------------------------------------
EXTENDS Naturals
VARIABLES Microcontroller, module
----------------------------------------------------------------------------------------------------

MicrocontrollerInvariant == 
			 	/\ Microcontroller \in [
			    		 state : {"Off","On"},
			    		 noOfPulses \in (1..100)
			    		 period \in (1..100)
			    		 pulseWidth \in {0,LOW,MEDIUM,HIGH}
			     		 count \in (1..100)
			    		 interrupt : {"None","Overflow"}
			    		 input \in (1..100)
			    		 ]
			    	/\ modules \in [ 
			    		   PWM :{"off","on"},
			    		   TC: {"off","on"}
			    		  ]
			    
----------------------------------------------------------------------------------------------------

StorePWM(width) == /\ Microcontroller.state = "On"
	           /\ Microcontroller.pulseWidth = width
	           
ResetPulseWidth == /\ Microcontroller.pulseWidth \in {LOW,MEDIUM,HIGH}
		   /\ Microcontroller'.pulseWidth = 0

PWMenable == /\ modules.PWM = "off"
	     /\ modules'.PWM = "on"

PWMdisabe == /\ modules.PWM = "on"
	     /\ modules'.PWM = "off"
----------------------------------------------------------------------------------------------------

SetPeriod(n) == /\ Microcontroller.state = "On"
		/\ Microcontroller'.period= n

OverflowInt ==  /\ Microcontroller.interrupt = "Overflow"
		/\ Microcontroller'.interrupt= "None"

Increment == /\ modules.TC = "on"
	     /\ Microcontroller.state ="On"
	     /\ IF Microcontroller.count = period THEN
		/\ Microcontroller'.interrupt = "Overflow"
		/\ Microcontroller'.count= 0
		ELSE
		/\ Microcontroller'.count = count + 1

TCenable ==  /\ modules.TC = "off"
	     /\ modules'.TC = "on"

TCdisable ==  /\ modules.TC = "on"
	      /\ modules'.TC = "off"
		
----------------------------------------------------------------------------------------------------

PowerOn == /\ Microcontroller.state = "off"
	   /\ Microcontroller'.state = "on"

PowerOff == /\ Microcontroller.state = "on"
	    /\ Microcontroller'.state = "off"

----------------------------------------------------------------------------------------------------

PWMactions == StorePWM(input) 
TCactions == Increment \/ SetPeriod(input) 
GPIOactions == PowerOff \/ PowerOn

----------------------------------------------------------------------------------------------------

Next == \/ PWMactions 
	\/ TCactions 
	\/ GPIOactions

InitializeMicrocontroller == /\ MicrocontrollerInvariant
		             /\ Microcontroller.state = "off"
		             /\ Microcontroller.count = 0
		       	     /\ Microcontroller.period = 0
		             /\ Microcontroller.noOfPulses = 0
		             /\ Microcontroller.input = 0
	
MicrocontrollerSpec == InitializeMicrocontroller /\ []Next

-----------------------------------------------------------------------------------------------
THEOREM MicrocontrollerSpec => [] MicrocontrollerInvariant
===============================================================================================
