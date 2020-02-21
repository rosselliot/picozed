###################################################################
# run_steps.tcl
#
# TCL file to run the various steps, up-to bitstream creation:
#  - synthesis, implementation, bitgen
#
# Requires the project to already be created
#
# How to call:
# $vivado -mode batch -source run_steps -tclargs <project_file> <step_to_run>
###################################################################

proc run_step { step } {
    if { [get_property PROGRESS [get_runs $step ]] != "100%" } {
        puts "Running $step ..."
        launch_runs -jobs 4 $step
        wait_on_run -timeout 60 $step
    } else {
        puts "Step $step already completed. Skipping..."
    }
}

# Parse input arguments
if { $argc > 0 } {
    set board [lindex $argv 0]
    if { $argc > 1 } {
        set prj_file [lindex $argv 1]
        puts "Setting project file to $prj_file"
        if { $argc < 3 } {
            set step "synth"
            puts "No step string provided. Setting to \"$step\""
        } else {
            set step [lindex $argv 2]
            puts "Setting step to $step"
        }
    } else {
        puts "ERROR: No project file provided. Exiting."
        exit
    }
}
set scripts_dir [file dirname [info script]]
set top_dir $scripts_dir/..
set outdir $top_dir/output/$board

# Check for project
if { [file exists $prj_file] == 0 } {
    puts "Project $prj_file not found"
    source $scripts_dir/make_project.tcl 
} 

# Set flags for steps to run
set runsynth 0
set runimpl 0
set runbitgen 0
switch $step {
    synth { 
        set runsynth  1 
    }
    impl { 
        set runsynth  1
        set runimpl   1 
    }
    bitstream { 
        set runsynth  1 
        set runimpl   1
        set runbitgen 1
    }
    default     { 
        puts "ERROR: Unrecognised step \"$step\". Exiting" 
        exit
    }
}


# Open vivado project in subdirectory
open_project $prj_file

if { $runsynth == 1 } {
    run_step {synth_1}
} 
if { $runimpl == 1 } {
    run_step {impl_1}
} 
if { $runbitgen == 1 } {
    puts "Running bitstream generation..."
    open_run impl_1
    write_bitstream -force $outdir/${board}_dio_fmc.bit
}
