###############################################################################
# power_planning.tcl - IC Compiler II power planning for rca8
# Author  : [Author]
#
# Intentionally empty. At 95 leaf cells and ~440 um2 this block doesn't
# need an explicit power ring/mesh - IC Compiler II's default power
# structure off the .ndm library is sufficient for functional PnR closure
# here. Kept as its own stage (rather than deleted) so the flow matches
# the standard floorplan -> power -> placement -> CTS -> route sequence;
# on anything block-level or above I'd expect this file to actually be
# doing something (create_power_plan, ring/stripe definitions, IR-drop
# aware strap sizing).
###############################################################################
