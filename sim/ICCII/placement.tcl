###############################################################################
# placement.tcl - IC Compiler II placement for rca8
# Author  : [Author]
#
# Re-applies the same set_dont_use restriction set as DC. ICC2 can still
# swap/resize cells during placement optimization, so if the restriction
# isn't re-stated here it's possible for an excluded cell to reappear
# post-placement even though it was never in the synthesized netlist -
# worth remembering any time a "DC-only" cell restriction shows up
# further downstream than expected.
###############################################################################

source ./constraints/8bit.sdc

set_dont_use [get_lib_cells */FADD*]
#set_dont_use [get_lib_cells */HADD*]
set_dont_use [get_lib_cells */AO*]
set_dont_use [get_lib_cells */OA*]
#set_dont_use [get_lib_cells */NAND*]
#set_dont_use [get_lib_cells */XOR*]
#set_dont_use [get_lib_cells */NOR*]
set_dont_use [get_lib_cells */XNOR*]
set_dont_use [get_lib_cells */MUX*]

# place_pins -self intentionally omitted here - re-running it at this
# stage was shifting/overlapping pins already locked in by floorplan.tcl.
# Pin placement is a floorplan-stage decision in this flow; leave it
# alone once it's set.

save_block -as 8bitfinal1
