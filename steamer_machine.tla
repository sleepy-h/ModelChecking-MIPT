---- MODULE steamer_machine ----
EXTENDS Integers

VARIABLES water, temperature, button, power

CONSTANTS HomeTemparuture, BoilingTemparuture, TankCapacity

(*--algorithm SteamerUnit
variables water = TankCapacity,
          temperature = HomeTemparuture,
          button = FALSE,
          power = FALSE;

        
define
    HomeTemparuture == 30
    BoilingTemparuture == 100
    TankCapacity == 100

    IsBoiling == temperature >= BoilingTemparuture
    IsHomeTemp == temperature <= HomeTemparuture
    TankEmpty == water = 0
    TankFull == water = TankCapacity
end define;


macro inc_temparuture() begin
    if (power /\ ~IsBoiling) then
        temperature := temperature + 10;
    end if;
end macro;


macro dec_temparuture() begin
    if (~power /\ ~IsHomeTemp) then
        temperature := temperature - 10;
    end if;
end macro;

process Steamer = 1

begin
    heat_loop:
    while power /\ ~TankEmpty do 
    heat_steamer:
        inc_temparuture();
    press_button:
    button := IsBoiling;
    if ~TankEmpty /\ button then
        generate_steam:
        water := water - 10;
        dec_temparuture();
    end if;
    empty_tank:
    if TankEmpty then
        power := FALSE;
    end if;

    end while;
end process;

process AddWater = 2
begin
    Add_water_power_up:
        if TankEmpty /\ ~power then
            water := TankCapacity;
            power := TRUE;
        end if;
end process;


end algorithm; *)
\* BEGIN TRANSLATION (chksum(pcal) = "b252ff25" /\ chksum(tla) = "68f300c3")
VARIABLES  pc

(* define statement *)

IsBoiling == temperature >= BoilingTemparuture
IsHomeTemp == temperature <= HomeTemparuture
TankEmpty == water = 0
TankFull == water = TankCapacity


vars == << water, temperature, button, power, pc >>

ProcSet == {1} \cup {2}

Init == (* Global variables *)
        /\ water = TankCapacity
        /\ temperature = HomeTemparuture
        /\ button = FALSE
        /\ power = FALSE
        /\ pc = [self \in ProcSet |-> CASE self = 1 -> "write_loop"
                                        [] self = 2 -> "Add_water_power_up"]

write_loop == /\ pc[1] = "write_loop"
              /\ IF power /\ ~TankEmpty
                    THEN /\ pc' = [pc EXCEPT ![1] = "heat_steamer"]
                    ELSE /\ pc' = [pc EXCEPT ![1] = "Done"]
              /\ UNCHANGED << water, temperature, button, power >>

heat_steamer == /\ pc[1] = "heat_steamer"
                /\ IF (power /\ ~IsBoiling)
                      THEN /\ temperature' = temperature + 10
                      ELSE /\ TRUE
                           /\ UNCHANGED temperature
                /\ pc' = [pc EXCEPT ![1] = "press_button"]
                /\ UNCHANGED << water, button, power >>

press_button == /\ pc[1] = "press_button"
                /\ button' = IsBoiling
                /\ IF ~TankEmpty /\ button'
                      THEN /\ pc' = [pc EXCEPT ![1] = "generate_steam"]
                      ELSE /\ pc' = [pc EXCEPT ![1] = "empty_tank"]
                /\ UNCHANGED << water, temperature, power >>

generate_steam == /\ pc[1] = "generate_steam"
                  /\ water' = water - 10
                  /\ IF (~power /\ ~IsHomeTemp)
                        THEN /\ temperature' = temperature - 10
                        ELSE /\ TRUE
                             /\ UNCHANGED temperature
                  /\ pc' = [pc EXCEPT ![1] = "empty_tank"]
                  /\ UNCHANGED << button, power >>

empty_tank == /\ pc[1] = "empty_tank"
              /\ IF TankEmpty
                    THEN /\ power' = FALSE
                    ELSE /\ TRUE
                         /\ power' = power
              /\ pc' = [pc EXCEPT ![1] = "write_loop"]
              /\ UNCHANGED << water, temperature, button >>

Steamer == write_loop \/ heat_steamer \/ press_button \/ generate_steam
              \/ empty_tank

Add_water_power_up == /\ pc[2] = "Add_water_power_up"
                      /\ IF TankEmpty /\ ~power
                            THEN /\ water' = TankCapacity
                                 /\ power' = TRUE
                            ELSE /\ TRUE
                                 /\ UNCHANGED << water, power >>
                      /\ pc' = [pc EXCEPT ![2] = "Done"]
                      /\ UNCHANGED << temperature, button >>

AddWater == Add_water_power_up

(* Allow infinite stuttering to prevent deadlock on termination. *)
Terminating == /\ \A self \in ProcSet: pc[self] = "Done"
               /\ UNCHANGED vars

Next == Steamer \/ AddWater
           \/ Terminating

Spec == Init /\ [][Next]_vars

Termination == <>(\A self \in ProcSet: pc[self] = "Done")

\* END TRANSLATION 


=============================================================================
