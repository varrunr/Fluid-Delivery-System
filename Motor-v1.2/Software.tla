--------------------------------MODULE Software----------------------------------------------
EXTENDS Naturals
VARIABLE SoftwareRec, Microcontroller, Motor, modules, ActiveTime
CONSTANTS ThresholdPulseWidth, LOW, HIGH, InputSize, input

AVRxmega16A4 == INSTANCE Microcontroller

DeliverySystem == INSTANCE Motor 

SoftwareInvariant == /\ SoftwareRec \in [
			 		intType : {"Overflow","Empty","None"},
		     			CurState : {"Active","Passive"}
		     	    	   	]
		     /\ AVRxmega16A4!MicrocontrollerInvariant
		     /\ DeliverySystem!MotorInvariant

HandleOverflowInt ==    /\ SoftwareRec.CurState = "Passive" 
		        /\ SoftwareRec.intType = "Overflow" 
			/\ AVRxmega16A4!OverflowInt
			/\ AVRxmega16A4!DisablePWM
			/\ AVRxmega16A4!DisableTC
			/\ DeliverySystem!DisableMotor
			/\ SoftwareRec'.CurState = "Active"
			/\ SoftwareRec'.intType = "None"
			/\ AVRxmega16A4!ResetPulseWidth
			
HandleEmptyInt    ==  /\ SoftwareRec.CurState = "Passive"
		      /\ SoftwareRec.intType = "Empty"
	              /\ DeliverySystem!EmptyInt
	              /\ AVRxmega16A4!DisablePWM
	              /\ AVRxmega16A4!DisableTC
	              /\ DeliverySystem!DisableMotor
		      /\ SoftwareRec'.CurState = "Active"	
		      /\ SoftwareRec'.intType = "None"
		      
Send(noOfUnits) == /\ SoftwareRec.CurState = "Passive"
		   /\ AVRxmega16A4!EnableTC
		   /\ AVRxmega16A4!EnablePWM
		   /\ DeliverySystem!EnableMotor
	       	   /\ AVRxmega16A4!StorePWM(noOfUnits)
	           /\ AVRxmega16A4!SetPeriod(noOfUnits)
	           /\ SoftwareRec'.CurState = "Active" 
	   
HandleInt == HandleOverflowInt \/ HandleEmptyInt

EnableHardware ==  /\ AVRxmega16A4!EnableMicrocontroller
		   /\ DeliverySystem!EnableMotor

Active == \/ EnableHardware 
	  \/ Send(input) 
	  \/ HandleInt

Passive ==  /\ SoftwareRec.intype = "none"
	    /\ SoftwareRec.CurState = "Active"
	    /\ SoftwareRec'.CurState = "Passive"

-----------------------------------------------------------------------------------------------
InitializeSoftware ==   /\ SoftwareInvariant
			/\ SoftwareRec = [ 
						intType |-> "None", 
						CurState |-> "Passive"
				      	 ]
		        /\ DeliverySystem!InitMotor
			/\ AVRxmega16A4!InitializeMicrocontroller
			

Next == Passive \/ Active

SoftwareSpec == InitializeSoftware /\ []Next

-----------------------------------------------------------------------------------------------
THEOREM SoftwareSpec => []SoftwareInvariant
===============================================================================================
