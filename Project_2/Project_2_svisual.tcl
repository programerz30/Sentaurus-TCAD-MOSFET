###########################################################################
# Sentaurus Visual Tcl Script
# Project 2 : 180 nm 2D nMOS — Structure + Id-Vg + Id-Vd + C-V
###########################################################################

#############################################################################
## PLOT 0 : Final structure cross-section
#############################################################################
load_file n@previous@_fps.tdr
create_plot
select_plots {Plot_0}
set_plot_prop -plot {Plot_0} -frame_width 4
set_plot_prop -plot {Plot_0} -title "180nm nMOS — Final Structure (Net Doping)"
set_plot_prop -plot {Plot_0} -title_font_family times -title_font_size 20 \
    -title_font_color #000000 -title_font_att bold

#############################################################################
## PLOT 1 : Id-Vg Linear  (Vd = 50 mV)
#############################################################################
load_file IdVg_lin_n@previous@_des.plt
create_plot -1d
select_plots {Plot_1}

create_curve -axisX {gate OuterVoltage} -axisY {drain TotalCurrent} \
    -dataset {IdVg_lin_n@previous@_des} -plot Plot_1

set_plot_prop -plot {Plot_1} -frame_width 4
set_plot_prop -plot {Plot_1} -title "Id-Vg Linear  (Vd = 50 mV)"
set_plot_prop -plot {Plot_1} -title_font_family times -title_font_size 20 \
    -title_font_color #000000 -title_font_att bold
set_curve_prop {Curve_1} -plot Plot_1 -line_width 3
set_axis_prop -plot Plot_1 -axis y -title "Id (A/um)" \
    -title_font_family arial -title_font_size 18 -title_font_att bold
set_axis_prop -plot Plot_1 -axis x -title "Vg (V)" \
    -title_font_family arial -title_font_size 18 -title_font_att bold

#############################################################################
## PLOT 2 : Id-Vg Saturation (Vd = 1.5 V) — log scale
#############################################################################
load_file IdVg_sat_n@previous@_des.plt
create_plot -1d
select_plots {Plot_2}

create_curve -axisX {gate OuterVoltage} -axisY {drain TotalCurrent} \
    -dataset {IdVg_sat_n@previous@_des} -plot Plot_2

set_plot_prop -plot {Plot_2} -frame_width 4
set_plot_prop -plot {Plot_2} -title "Id-Vg Saturation  (Vd = 1.5 V) — Log Scale"
set_plot_prop -plot {Plot_2} -title_font_family times -title_font_size 20 \
    -title_font_color #000000 -title_font_att bold
set_curve_prop {Curve_1} -plot Plot_2 -line_width 3
set_axis_prop -plot Plot_2 -axis y -title "Id (A/um)" -type log \
    -title_font_family arial -title_font_size 18 -title_font_att bold
set_axis_prop -plot Plot_2 -axis x -title "Vg (V)" \
    -title_font_family arial -title_font_size 18 -title_font_att bold

#############################################################################
## PLOT 3 : Id-Vd Output Characteristic
#############################################################################
load_file IdVd_n@previous@_des.plt
create_plot -1d
select_plots {Plot_3}

create_curve -axisX {drain OuterVoltage} -axisY {drain TotalCurrent} \
    -dataset {IdVd_n@previous@_des} -plot Plot_3

set_plot_prop -plot {Plot_3} -frame_width 4
set_plot_prop -plot {Plot_3} -title "Id-Vd Output Characteristic  (Vg = 1.0 V)"
set_plot_prop -plot {Plot_3} -title_font_family times -title_font_size 20 \
    -title_font_color #000000 -title_font_att bold
set_curve_prop {Curve_1} -plot Plot_3 -line_width 3
set_axis_prop -plot Plot_3 -axis y -title "Id (A/um)" \
    -title_font_family arial -title_font_size 18 -title_font_att bold
set_axis_prop -plot Plot_3 -axis x -title "Vd (V)" \
    -title_font_family arial -title_font_size 18 -title_font_att bold

#############################################################################
## PLOT 4 : Gate C-V  (Cgg vs Vg at 1 MHz)
#############################################################################
load_file CV_n@previous@_des.plt
create_plot -1d
select_plots {Plot_4}

create_curve -axisX {gate OuterVoltage} -axisY {gate/gate} \
    -dataset {CV_n@previous@_des} -plot Plot_4

set_plot_prop -plot {Plot_4} -frame_width 4
set_plot_prop -plot {Plot_4} -title "Gate C-V  (Cgg vs Vg, f = 1 MHz)"
set_plot_prop -plot {Plot_4} -title_font_family times -title_font_size 20 \
    -title_font_color #000000 -title_font_att bold
set_curve_prop {Curve_1} -plot Plot_4 -line_width 3
set_axis_prop -plot Plot_4 -axis y -title "Cgg (F/um)" \
    -title_font_family arial -title_font_size 18 -title_font_att bold
set_axis_prop -plot Plot_4 -axis x -title "Vg (V)" \
    -title_font_family arial -title_font_size 18 -title_font_att bold
