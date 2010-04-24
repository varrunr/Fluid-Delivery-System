--------------------------------MODULE Software----------------------------------------------
EXTENDS Naturals
VARIABLE intType, CurState, input, Microcontroller, module, Motor

AVRxmega16A4 == INSTANCE Microcontroller

INSTANCE Motor 

SoftwareInvariant == /\ intType = {"Overflow","Empty","None"}
		     /\ input \in (1..100)
		     /\ CurState = {"Active","Passive"}

HandleOverflowInt ==    /\ intType = "Overflow" 
			/\ AVRxmega16A4!OverflowInt
			/\ AVRxmega16A4!PowerOff
			/\ CurState' = "Active"
			/\ intType' = "None"
			/\ AVRxmega16A4!ResetPulseWidth
			
HandleEmptyInt    ==  /\ intType = "Empty"
	              /\ EmptyInt
	              /\ AVRxmega16A4!PowerOff
		      /\ CurState' = "Active"	
		      /\ intType' = "None"
		      
Send(noOfUnits) == /\ AVRxmega16A4!PowerOn
	       	   /\ AVRxmega16A4!StorePWM(noOfUnits)
	           /\ AVRxmega16A4!SetPeriod(noOfUnits)
	           /\ CurState' = "Active" 
	   
HandleInt == HandleOverflowInt \/ HandleEmptyInt

Active == Send(input) \/ HandleInt

Passive ==  /\ CurState = "Active"
	    /\ CurState' = "Passive"

-----------------------------------------------------------------------------------------------
InitializeSoftware == /\ SoftwareInvariant
		      /\ CurState = "Passive"

SoftwareSpec == InitializeSoftware /\ [](Passive \/ Active)

-----------------------------------------------------------------------------------------------
THEOREM SoftwareSpec => []SoftwareInvariant
THEOREM Rotate => AVRxmega16A4!Increment
===============================================================================================
