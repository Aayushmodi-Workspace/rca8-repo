###############################################################################
# clock.tcl - IC Compiler II clock tree synthesis for rca8
# Author  : [Author]
#
# Single clock, no explicit CTS spec (clock_opt_design defaults) - one
# clock root driving a small, low-fanout register bank doesn't warrant a
# custom CTS spec at this size. block_schematic_pt.png in results/ shows
# the resulting tree; skew came in well inside the -hold uncertainty
# budgeted in 8bit.sdc, so this stage needed no rework.
###############################################################################

save_block -as 8bitfinal1
