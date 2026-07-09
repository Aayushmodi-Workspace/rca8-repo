###############################################################################
# floorplan.tcl - IC Compiler II floorplanning for rca8
# Author  : [Author]
#
# Only "Scenario 4" is kept below - there were three earlier floorplan
# attempts (different utilization / pin-side assignments) that either
# produced awkward aspect ratios or pin congestion on one side once
# placement ran. Not worth carrying the dead scenarios in the script;
# the important structural decision (operands top, sum bottom, carry-in/
# carry-out left/right) is noted inline where it's set.
###############################################################################

set PDK_PATH ./../ref
create_lib -ref_lib $PDK_PATH/lib/ndm/saed32rvt_c.ndm 8bitfinal_LIB
read_verilog {./../DC/results/rca8.mapped.v} -library 8bitfinal_LIB -design rca8 -top rca8

open_lib 8bitfinal_LIB
open_block 8bitfinal1
save_block -as 8bitfinal1
save_lib

# --- Floorplan (Scenario 4 - final scenario used) ---
# 0.6 core utilization: comfortable margin for a 95-cell design; no
# reason to push density higher on a block this small and it leaves
# routing headroom for CTS/route to work with rather than fighting
# congestion on a near-trivial adder.
initialize_floorplan -core_utilization 0.6 -core_offset {3 3} -coincident_boundary false

# Pin-side assignment: operands (A, B) on top, sum out the bottom,
# carry chain left-to-right (Cin in on the left, Cout out on the
# right) - mirrors the logical data flow of the adder so the floorplan
# reads the same way the RTL does.
set ports_top    [get_ports {A* B*}]
set ports_bottom [get_ports {Sum*}]
set ports_left   [get_ports {Cin}]
set ports_right  [get_ports {Cout}]
set ports_clock  [get_ports {clk clock CLK}]

set_individual_pin_constraints -offset {1 20} -sides 1 -ports $ports_top
set_individual_pin_constraints -offset {1 20} -sides 3 -ports $ports_bottom
set_individual_pin_constraints -offset {1 20} -sides 4 -ports $ports_left
set_individual_pin_constraints -offset {1 20} -sides 2 -ports $ports_right

place_pins -self
create_placement -floorplan -effort high
