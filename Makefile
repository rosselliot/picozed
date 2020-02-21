#####################################################################
# Makefile for generating the FMC-DIO-5ch-TTL FMC Vivado prjocts
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

project_file := $(OUTDIR)/$(board)/vivado_prj/fmc-dio-5ch-ttl_$(board).xpr

.PHONY: all project synth impl bitstream clean

all: project bitstream

project:
	vivado -mode batch -source $(SCRIPTS_DIR)/make_project.tcl -tclargs $(board)

synth:
	vivado -mode batch -source $(SCRIPTS_DIR)/run_steps.tcl -tclargs $(board) $(project_file) synth

impl:
	vivado -mode batch -source $(SCRIPTS_DIR)/run_steps.tcl -tclargs $(board) $(project_file) impl

bitstream:
	vivado -mode batch -source $(SCRIPTS_DIR)/run_steps.tcl -tclargs $(board) $(project_file) bitstream

clean:
	-@rm -rf $(OUTDIR)/$(board)
	-@rm -rf ./*.log
	-@rm -rf ./*.jou
