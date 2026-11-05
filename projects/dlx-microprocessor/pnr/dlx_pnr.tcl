# DLX place & route, based on lab 6

# 1. configuration
source DLX.globals
init_design
puts "CHECK init: [llength [dbGet top.insts]] instances"

# 2. floorplan: aspect ratio 1.0, utilization 0.6, 5 um margins
floorPlan -r 1.0 0.6 5 5 5 5
saveDesign dlx_floorplan.enc

# 3. power rings (M9 horizontal, M10 vertical)
addRing -nets {vdd gnd} -type core_rings -follow core -layer {top M9 bottom M9 left M10 right M10} -width 0.8 -spacing 0.8 -offset 0.8

# 4. power stripes
addStripe -nets {vdd gnd} -layer M10 -direction vertical -width 0.8 -spacing 0.8 -set_to_set_distance 20 -start_from left -start_offset 15

# 5. standard cell power routing
sroute -nets {vdd gnd}

# 6. placement
setPlaceMode -fp false -maxRouteLayer 6 -place_global_place_io_pins true
placeDesign
saveDesign dlx_placed.enc

# 8. pre-CTS timing and optimization
setDelayCalMode -siAware false
timeDesign -preCTS -outDir timing_preCTS
optDesign -preCTS
puts "CHECK preCTS: [llength [dbGet top.insts]] instances"

# 9. clock tree synthesis (not needed for the combinational adder)
create_ccopt_clock_tree_spec
set_ccopt_property target_max_trans 0.05
set_ccopt_property target_skew 0.02
clock_opt_design
timeDesign -postCTS -outDir timing_postCTS

# 10. post-CTS optimization, then filler cells
optDesign -postCTS

# 11. routing
setNanoRouteMode -quiet -routeTopRoutingLayer 6
routeDesign -globalDetail
timeDesign -postRoute -outDir timing_postRoute

# 12. post-route optimization: setup and hold
optDesign -postRoute
optDesign -postRoute -hold
addFiller -cell {FILLCELL_X32 FILLCELL_X16 FILLCELL_X8 FILLCELL_X4 FILLCELL_X2 FILLCELL_X1} -prefix FILL
ecoRoute -target
timeDesign -postRoute       -outDir timing_final
timeDesign -postRoute -hold -outDir timing_final_hold
saveDesign dlx_routed.enc

# 13. parasitic extraction
setExtractRCMode -engine postRoute -effortLevel low
extractRC
rcOut -spef dlx.spef

# 14. checks and deliverables
verifyConnectivity -type all
report_power  > dlx_power_pnr.rpt
report_area   > dlx_area_pnr.rpt
report_timing > dlx_timing_pnr.rpt
saveNetlist dlx_routed.v
write_sdf   dlx_routed.sdf