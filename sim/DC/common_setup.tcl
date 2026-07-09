###############################################################################
# common_setup.tcl (rm_setup) - Library and design setup for rca8
# Author  : [Author]
#
# Standard Synopsys Reference Methodology setup file, trimmed to what this
# design actually needs - single design, single corner, no hierarchy, no
# multi-corner/multi-mode. PDK_PATH points at the workshop's SAED32 install;
# repoint it at your own and everything downstream (DC, ICC2, PT) picks it
# up through this file.
###############################################################################

set DESIGN_NAME               "rca8"
set PDK_PATH                  "./../ref/"
set DESIGN_REF_DATA_PATH      ""

#############################################################################
# Hierarchical Flow Design Variables
# Not used - rca8 is small enough to run flat end to end. Left in place
# (empty) rather than stripped, in case this setup file ever gets reused
# as a template for something that does need block-level hierarchy.
#############################################################################
set HIERARCHICAL_DESIGNS      ""
set HIERARCHICAL_CELLS        ""

#############################################################################
# Library Setup Variables
#############################################################################
set ADDITIONAL_SEARCH_PATH    "$PDK_PATH $PDK_PATH/tech/milkyway $PDK_PATH/tech/star_rcxt"

# SAED32nm RVT, TT corner (0.78V, -40C - note the corner name encodes a
# cold/typical-voltage point, not the "TT/25C" naming some other kits use;
# always read the actual .lib header rather than trusting the corner
# folder name).
set TARGET_LIBRARY_FILES      "$PDK_PATH/lib/stdcell_rvt/saed32rvt_tt0p78vn40c.db"
set ADDITIONAL_LINK_LIB_FILES ""

set MIN_LIBRARY_FILES         ""

set MW_REFERENCE_LIB_DIRS     ""
set MW_REFERENCE_CONTROL_FILE ""

set TECH_FILE                 "$PDK_PATH/tech/milkyway/saed32nm_1p9m.tf"
set MAP_FILE                  "saed32nm_tf_tluplus.map"
set TLUPLUS_MAX_FILE          "saed32nm_1p9m_Cmax.tluplus"
set TLUPLUS_MIN_FILE          "saed32nm_1p9m_Cmin.tluplus"
