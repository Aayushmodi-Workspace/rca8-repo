###############################################################################
# 8bit.sdc - Timing constraints for rca8
# Author  : [Author]
#
# Sign-off corner: TT unless a specific case in the cell-tradeoff study
# overrides it (see docs/cell-tradeoff-study.md). Clock period, I/O delays
# and uncertainty below reflect the final case used for the top-level
# result reported in README.md; earlier cases in the tradeoff study reused
# this file with only create_clock's -period edited.
###############################################################################

# Primary clock. 2.4 ns was the period that closed setup cleanly with the
# full cell-tradeoff-study restriction set applied (see Case-12) - not an
# arbitrary target, it's the point past which the ripple-carry chain
# itself becomes the limiter regardless of cell selection.
create_clock -period 2.4 [get_ports Clock]

# I/O timing. Values are representative workshop defaults, not derived
# from a real interface spec - there's no external IP this block talks
# to in this exercise, so 0.5 ns / 0.25 ns budgets are just "enough
# margin to be a non-trivial constraint" rather than anything a real
# chip-level timing budget would hand down.
set_input_delay -max 0.5 -clock Clock [all_inputs]
set_input_transition 0.5 [all_inputs]
set_output_delay -max 0.25 -clock Clock [all_outputs]

# Clock uncertainty: setup budget wider than hold, as usual - setup
# uncertainty is standing in for on-chip variation + a placeholder skew
# allowance ahead of CTS, hold uncertainty for the (smaller) skew you
# still expect post-CTS.
set_clock_uncertainty -setup 0.25 [get_clocks Clock]
set_clock_uncertainty -hold  0.15 [get_clocks Clock]

# Max transition, data and clock path. Kept tight deliberately - this is
# what actually forces DC to insert buffers once cells start getting
# excluded from the library (see Case-7 onward in the tradeoff study);
# loosen this and a lot of the buffer-count story in that writeup goes
# away along with it.
set_max_transition 0.075 [current_design]
set_max_transition -clock_path 0.075 [get_clocks Clock]
