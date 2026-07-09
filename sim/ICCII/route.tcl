###############################################################################
# route.tcl - IC Compiler II routing for rca8
# Author  : [Author]
#
# write_parasitics is disabled below - it errored out in this environment
# (workshop machine, not something I chased down further given the time
# box). The .spef PrimeTime reads for sign-off (sim/PT/run_pt_p1.tcl) was
# generated separately via StarRC rather than through this call; if
# you're rerunning the flow end to end and this line still errors for
# you, do the same - don't block route.tcl on it.
###############################################################################

write_verilog ./results/rca8.routed.v
write_sdc -output ./results/rca8.routed.sdc

# write_parasitics disabled - errored out when sourced in this environment
#write_parasitics -format spef -output ./results/full_adder_${scenario1}.spef
