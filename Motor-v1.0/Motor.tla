--------------------------------MODULE Motor----------------------------------------------
EXTENDS Naturals
VARIABLE pulse, holes, unit, fluidLevel 
-----------------------------------------------------------------------------------------

MotorInvariant == /\ pulse \in {0,1}
		  /\ unit \in (1..100)
		  /\ holes \in (1..60)
		  /\ fluidLevel = {"Empty","NonEmpty"}

PushFluid == IF unit = 0 THEN
		/\ fluidLevel' = "Empty"
	     ELSE
		/\ unit' = unit - 1
		 
Rotate == /\ pulse = 1
	  /\ PushFluid
	  /\ IF holes = 60 THEN holes' = 1 ELSE holes' = holes + 1


CheckEmpty == /\ fluidLevel = "Empty" 

Refill == /\ fluidLevel = "Empty"
	  /\ unit = 0
	  /\ fluidLevel' = "NonEmpty"
	  /\ unit' = 100

Next == Rotate \/ PushFluid \/ Refill

StartMotor == /\ pulse = 0
	      /\ holes = 0
	      /\ fluidLevel = "NonEmpty"
	
MotorSpec == StartMotor /\ []Next

-----------------------------------------------------------------------------------------------
THEOREM MotorSpec => []MotorInvariant
===============================================================================================
