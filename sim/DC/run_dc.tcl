###############################################################################
# run_dc.tcl - Design Compiler synthesis script for rca8
# Author  : [Author]
#
# Cell-restriction block below is the knob varied across the twelve runs
# in docs/cell-tradeoff-study.md - whatever's active here is what the
# committed screenshots/reports in results/ correspond to. Uncomment/
# comment lines to reproduce a specific case; the case table in the
# tradeoff study writeup lists exactly which lines were live for each run.
###############################################################################

source -echo -verbose ./rm_setup/dc_setup.tcl
set RTL_SOURCE_FILES ./rtl/8bit_rtl.v

define_design_lib WORK -path ./WORK

# Cell restrictions (edit per experiment case - see docs/cell-tradeoff-study.md)
# Current state below = full restriction set (Case 6-12 family).
set_dont_use [get_lib_cells */FADD*]
#set_dont_use [get_lib_cells */HADD*]
set_dont_use [get_lib_cells */AO*]
set_dont_use [get_lib_cells */OA*]
#set_dont_use [get_lib_cells */AND*]
#set_dont_use [get_lib_cells */NAND*]
#set_dont_use [get_lib_cells */OR*]
#set_dont_use [get_lib_cells */NOR*]
set_dont_use [get_lib_cells */XNOR*]
set_dont_use [get_lib_cells */MUX*]

analyze -format verilog ${RTL_SOURCE_FILES}
elaborate ${DESIGN_NAME}
current_design

read_sdc ./constraints/8bit.sdc

# compile_ultra over plain compile for anything past the unconstrained
# baseline cases - the incremental optimization pass is what actually
# clears the hold violations that plain `compile` leaves behind once
# cells start getting excluded (Case-4 vs Case-6 in the tradeoff study).
#compile
compile_ultra

report_timing
write -format verilog -hierarchy -output ${RESULTS_DIR}/${DCRM_FINAL_VERILOG_OUTPUT_FILE}
