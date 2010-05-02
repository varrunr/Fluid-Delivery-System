--------------------------------MODULE Microcontroller----------------------------------------------
EXTENDS Naturals
VARIABLES Microcontroller, modules
CONSTANT LOW,HIGH, InputSize, input
----------------------------------------------------------------------------------------------------

MicrocontrollerInvariant ==	/\ Microcontroller \in [
			    		 state : {"Off","On"},
			    		 period : (1..100),
			    		 pulseWidth : (0..HIGH),
			     		 count : (1..100),
			    		 interrupt : {"None","Overflow"}
			    		 ]
			    	/\ modules \in [ 
			    		   PWM :{"off","on"},
			    		   TC: {"off","on"}
			    		  ]
			    
----------------------------------------------------------------------------------------------------

StorePWM(width) == /\ Microcontroller.state = "On"
	           /\ Microcontroller' = [Microcontroller EXCEPT !.pulseWidth = width ]
	           
ResetPulseWidth == /\ Microcontroller.pulseWidth \in (0..HIGH)
		   /\ Microcontroller' = [Microcontroller EXCEPT !.pulseWidth = 0]

EnablePWM == /\ modules.PWM = "off"
	     /\ modules' = [modules EXCEPT !.PWM = "on"]

DisablePWM == /\ modules.PWM = "on"
	     /\ modules' = [modules EXCEPT !.PWM = "off" ]
----------------------------------------------------------------------------------------------------

SetPeriod(n) == /\ Microcontroller.state = "On"
		/\ Microcontroller' = [Microcontroller EXCEPT !.period= n ]

OverflowInt ==  /\ Microcontroller.interrupt = "Overflow"
		/\ Microcontroller' = [Microcontroller EXCEPT !.interrupt= "None"]

Increment == /\ modules.TC = "on"
	     /\ Microcontroller.state ="On"
	     /\ IF Microcontroller.count = Microcontroller.period THEN
		/\ Microcontroller' = [Microcontroller EXCEPT !.interrupt = "Overflow" , !.count= 0 ]
		ELSE
		/\ Microcontroller' = [Microcontroller EXCEPT !.count = @ + 1]

EnableTC ==  /\ modules.TC = "off"
	     /\ modules' = [modules EXCEPT !.TC = "on"]

DisableTC ==  /\ modules.TC = "on"
	      /\ modules' = [modules EXCEPT !.TC = "off"]
		
----------------------------------------------------------------------------------------------------

EnableMicrocontroller == /\ Microcontroller.state = "off"
	   		 /\ Microcontroller' = [Microcontroller EXCEPT !.state = "on"]

DisableMicrocontroller == /\ Microcontroller.state = "on"
	    		  /\ Microcontroller' = [Microcontroller EXCEPT !.state = "off"]

----------------------------------------------------------------------------------------------------

PWMactions == StorePWM(input) 
TCactions == Increment \/ SetPeriod(input) 
GPIOactions == EnableMicrocontroller \/ DisableMicrocontroller

----------------------------------------------------------------------------------------------------

Next == \/ PWMactions 
	\/ TCactions 
	\/ GPIOactions

InitializeMicrocontroller == /\ MicrocontrollerInvariant
			     /\ Microcontroller = [ 
						 	state |-> "off", 
						 	count |-> 0,
						 	period |-> 0,
						 	interrupt |-> "None",
						 	pulseWidth |-> 0
					          ]
			     /\ modules = [ 
			    		   PWM |-> "off",
			    		   TC |-> "off"
			    		  ]
	
MicrocontrollerSpec == InitializeMicrocontroller /\ []Next

-----------------------------------------------------------------------------------------------
THEOREM MicrocontrollerSpec => [] MicrocontrollerInvariant
===============================================================================================
