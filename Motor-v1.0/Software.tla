--------------------------------MODULE Software----------------------------------------------
EXTENDS Naturals
VARIABLE intType, CurState, pulse, holes, unit, fluidLevel, value, state, noOfPulses, period, count, interrupt, input

AVRxmega16A4 == INSTANCE Microcontroller

INSTANCE Motor 

SoftwareInvariant == /\ intType = {"Overflow","Empty"}
		     /\ input \in (1..100)
		     /\ CurState = {"Active","Passive"}

HandleOverflowInt ==    /\ intType = "Overflow" 
			/\ AVRxmega16A4!CheckOverflow
			/\ AVRxmega16A4!InvalidatePWM
			/\ AVRxmega16A4!PowerOff
			/\ CurState' = "Active"
			
HandleEmptyInt    ==  /\ intType = "Empty"
	              /\ CheckEmpty
	              /\ AVRxmega16A4!PowerOff
		      /\ CurState' = "Active"	
		      
Send(noOfUnits) == /\ AVRxmega16A4!PowerOn
	       	   /\ AVRxmega16A4!StorePWM(noOfUnits)
	           /\ AVRxmega16A4!SetPeriod(noOfUnits)
	           /\ CurState' = "Active" 
	   
HandleInt == HandleOverflowInt \/ HandleEmptyInt

Active == Send(input) \/ HandleInt

Passive ==  /\ CurState = "Passive"

-----------------------------------------------------------------------------------------------
InitializeSoftware == /\ SoftwareInvariant
		      /\ CurState = "Passive"

SoftwareSpec == InitializeSoftware /\ [](Passive \/ Active)

-----------------------------------------------------------------------------------------------
THEOREM SoftwareSpec => []SoftwareInvariant
THEOREM Rotate => AVRxmega16A4!Increment
===============================================================================================
