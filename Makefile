#####################################################################
# Makefile for generating the PicoZed-based Vivado projects
#
# Author    : Ross Elliot
# Date      : 2020-02-21
# 
# Supported boards:
#   - PicoZed 7030 SoM with FPGAIOC carrier (picozed)
#####################################################################

TOP := $(PWD)
SCRIPTS_DIR := $(TOP)/scripts
OUTDIR := $(TOP)/output

board ?= picozed
project ?= base

project_name := $(board)_$(project)
project_dir := $(OUTDIR)/$(project)
project_file := $(project_dir)/vivado_prj/$(project_name).xpr

.PHONY: all project synth impl bitstream clean

all: project synth impl bitstream

project:	$(project_file)
synth:	    $(project_dir)/$(project_name).dcp
impl:	    $(project_dir)/$(project_name)_routed.dcp
bitstream:	$(project_dir)/$(project_name).bit  

$(project_file):
	-@echo -e "\033[1;92mRunning project creation: \033[0m"
	vivado -mode batch -source $(SCRIPTS_DIR)/make_project.tcl -tclargs $(board) $(project)

$(project_dir)/$(project_name).dcp:
	-@echo -e "\033[1;92mRunning synthesis: \033[0m"
	vivado -mode batch -source $(SCRIPTS_DIR)/run_steps.tcl -tclargs $(board) $(project) $(project_file) synth

$(project_dir)/$(project_name)_routed.dcp:
	-@echo -e "\033[1;92mRunning implementation: \033[0m"
	vivado -mode batch -source $(SCRIPTS_DIR)/run_steps.tcl -tclargs $(board) $(project) $(project_file) impl

$(project_dir)/$(project_name).bit:
	-@echo -e "\033[1;92mRunning bitstream generation: \033[0m"
	vivado -mode batch -source $(SCRIPTS_DIR)/run_steps.tcl -tclargs $(board) $(project) $(project_file) bitstream

clean:
	-@echo -e "\033[1;92mDeleting all generated files from $(project_dir)\033[0m"
	-@rm -rf $(project_dir)
	-@rm -rf ./*.log
	-@rm -rf ./*.jou
