###################################################################
# make_project.tcl
#
# TCL file to create a vivado project and block design.
# Takes one input value "board" to select which target platform
# to use.
#
# How to call:
# $ vivado -mode batch -source make_project.tcl -tclargs picozed
###################################################################

# Parse input arguments
if { $argc > 0 } {
    set board [lindex $argv 0]
    puts "Setting board to $board"
    if { $argc > 1 } {
        set project [lindex $argv 1]
        puts "Setting project to $project"
    } else {
        puts "No project provided. Using default (base)"
    }
} else {
    puts "No board provided. Using default (picozed)"
    set board "picozed"
}

# Set target device based on provided board name
switch $board {
    "picozed" { set target "xc7z030sbg485-1" }
}
puts "Setting target device to $target" 

set scripts_dir [file dirname [info script]]
set top_dir $scripts_dir/..
set projects_dir $top_dir/project

# Create vivado project in subdirectory
set prj_dir ./output/$project/vivado_prj
create_project -part $target ${board}_${project} $prj_dir 
set_property target_language VHDL [current_project]

# Add IP repository
set_property ip_repo_paths ${top_dir}/hdl-ip-repo [current_project]
update_ip_catalog

# Create block design
# BD name cannot contatin hypens ("-"), so replace with underscores
regsub -all {\-} $project "_" bd_name
set bd_name "${bd_name}.bd"
create_bd_design $bd_name 

# Populate block design from sourced tcl file
set ::board_name $board
source $projects_dir/$project/${project}_bd.tcl

# Validate the block design
validate_bd_design
save_bd_design

# Create top-level HDL wrapper, and add to filelist
make_wrapper -files [get_files $bd_name] -top -import

# Add constraints file
set constr_file "${top_dir}/project/${project}/${project}_${board}.xdc"
add_files -fileset constrs_1 -norecurse $constr_file

# Close project, in case this file has been sourced
close_project
