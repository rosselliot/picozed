puts "####### board_name == $::board_name"
set board $::board_name

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2019.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

set cur_design [current_bd_design -quiet]
set design_name $cur_design
set list_cells [get_bd_cells -quiet]


set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
ess.eu:icshwi:digitalIO:1.0\
xilinx.com:ip:ila:6.2\
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:xlslice:1.0\
ess.eu:icshwi:LED_Driver:1.0\
xilinx.com:ip:util_vector_logic:2.0\
xilinx.com:ip:processing_system7:5.5\
xilinx.com:ip:proc_sys_reset:5.0\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: PS7
proc create_hier_cell_PS7 { parentCell nameHier board } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_PS7() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M01_AXI


  # Create pins
  create_bd_pin -dir O -type clk FCLK_CLK0
  create_bd_pin -dir O -from 0 -to 0 -type rst S00_ARESETN

  # Create instance: ps7_0_axi_periph, and set properties
  set ps7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ps7_0_axi_periph ]
  set_property -dict [ list \
   CONFIG.NUM_MI {2} \
 ] $ps7_0_axi_periph

  # Create instance: rst_ps7_0_100M, and set properties
  set rst_ps7_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ps7_0_100M ]
  # Source board-specific PS7 tcl file
  puts [pwd] 
  source project/common/zynq_ps_config.tcl

  # Create interface connections
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_pins DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_pins FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins ps7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M00_AXI [get_bd_intf_pins M00_AXI] [get_bd_intf_pins ps7_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M01_AXI [get_bd_intf_pins M01_AXI] [get_bd_intf_pins ps7_0_axi_periph/M01_AXI]

  # Create port connections
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins FCLK_CLK0] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins ps7_0_axi_periph/ACLK] [get_bd_pins ps7_0_axi_periph/M00_ACLK] [get_bd_pins ps7_0_axi_periph/M01_ACLK] [get_bd_pins ps7_0_axi_periph/S00_ACLK] [get_bd_pins rst_ps7_0_100M/slowest_sync_clk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_ps7_0_100M/ext_reset_in]
  connect_bd_net -net rst_ps7_0_100M_peripheral_aresetn [get_bd_pins S00_ARESETN] [get_bd_pins ps7_0_axi_periph/ARESETN] [get_bd_pins ps7_0_axi_periph/M00_ARESETN] [get_bd_pins ps7_0_axi_periph/M01_ARESETN] [get_bd_pins ps7_0_axi_periph/S00_ARESETN] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: LED_Driver
proc create_hier_cell_LED_Driver { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_LED_Driver() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj
  set_property USER_COMMENTS.comment_1 "AXI-Lite connected LED Driver

Address - 0x43c00000

Simple driver to pulse the LED on/off. 
A 32-bit counter counts clock cycles up-to the provided clock frequency, 
i.e. up-to 1 second. 

The divider controls the period of the LED pulsing, in right-shifts, i.e. a value
of '1' will divide by 2, and pulse with a period of 0.5s, a value of '2' will divide 
by 4, and pulse with a period of 0.25s, etc...

Offset     Description
0x0         Clock frequency in Hz - default 100MHz
0x4         Divider (shift right) - default 1, i.e. divide by 2" [get_bd_cells /LED_Driver]

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI


  # Create pins
  create_bd_pin -dir O LED
  create_bd_pin -dir O -from 0 -to 0 Not_LED
  create_bd_pin -dir I -type clk s00_axi_aclk
  create_bd_pin -dir I -type rst s00_axi_aresetn

  # Create instance: LED_Driver_0, and set properties
  set LED_Driver_0 [ create_bd_cell -type ip -vlnv ess.eu:icshwi:LED_Driver:1.0 LED_Driver_0 ]

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_0

  # Create interface connections
  connect_bd_intf_net -intf_net PS7_M01_AXI [get_bd_intf_pins S00_AXI] [get_bd_intf_pins LED_Driver_0/S00_AXI]

  # Create port connections
  connect_bd_net -net LED_Driver_0_p_led_o [get_bd_pins LED] [get_bd_pins LED_Driver_0/p_led_o] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins s00_axi_aclk] [get_bd_pins LED_Driver_0/s00_axi_aclk]
  connect_bd_net -net s_axi_aresetn_1 [get_bd_pins s00_axi_aresetn] [get_bd_pins LED_Driver_0/s00_axi_aresetn]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins Not_LED] [get_bd_pins util_vector_logic_0/Res]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: AXI_Lite_GPIO
proc create_hier_cell_AXI_Lite_GPIO { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_AXI_Lite_GPIO() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj
  set_property USER_COMMENTS.comment_0 "AXI-Lite connected GPIO

Address - 0x43c10000

32-bit software register controls the output signals:

Bit(s)    Signal
14        FPGA_Out4
13        FPGA_Out3
12        FPGA_Out2
11        FPGA_Out1
10        FPGA_Out0
9:5       term_config
4:0       output_config

Writing the 32-bit word to the baseaddress 
of the register will update the outputs" [get_bd_cells /AXI_Lite_GPIO]

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI


  # Create pins
  create_bd_pin -dir O -from 0 -to 0 FPGA_Out0
  create_bd_pin -dir O -from 0 -to 0 FPGA_Out1
  create_bd_pin -dir O -from 0 -to 0 FPGA_Out2
  create_bd_pin -dir O -from 0 -to 0 FPGA_Out3
  create_bd_pin -dir O -from 0 -to 0 FPGA_Out4
  create_bd_pin -dir O -from 4 -to 0 output_config
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn
  create_bd_pin -dir O -from 4 -to 0 term_config

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [ list \
   CONFIG.C_ALL_OUTPUTS {1} \
   CONFIG.C_ALL_OUTPUTS_2 {0} \
   CONFIG.C_IS_DUAL {0} \
 ] $axi_gpio_0

  # Create instance: output_config, and set properties
  set output_config [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 output_config ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {4} \
   CONFIG.DOUT_WIDTH {5} \
 ] $output_config

  # Create instance: xlslice_1, and set properties
  set xlslice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_1 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {9} \
   CONFIG.DIN_TO {5} \
   CONFIG.DOUT_WIDTH {5} \
 ] $xlslice_1

  # Create instance: xlslice_2, and set properties
  set xlslice_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_2 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {10} \
   CONFIG.DIN_TO {10} \
   CONFIG.DOUT_WIDTH {1} \
 ] $xlslice_2

  # Create instance: xlslice_3, and set properties
  set xlslice_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_3 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {11} \
   CONFIG.DIN_TO {11} \
   CONFIG.DOUT_WIDTH {1} \
 ] $xlslice_3

  # Create instance: xlslice_4, and set properties
  set xlslice_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_4 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {12} \
   CONFIG.DIN_TO {12} \
   CONFIG.DOUT_WIDTH {1} \
 ] $xlslice_4

  # Create instance: xlslice_5, and set properties
  set xlslice_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_5 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {13} \
   CONFIG.DIN_TO {13} \
   CONFIG.DOUT_WIDTH {1} \
 ] $xlslice_5

  # Create instance: xlslice_6, and set properties
  set xlslice_6 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_6 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {14} \
   CONFIG.DIN_TO {14} \
   CONFIG.DOUT_WIDTH {1} \
 ] $xlslice_6

  # Create interface connections
  connect_bd_intf_net -intf_net PS7_M00_AXI [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_gpio_0/S_AXI]

  # Create port connections
  connect_bd_net -net axi_gpio_0_gpio_io_o [get_bd_pins axi_gpio_0/gpio_io_o] [get_bd_pins output_config/Din] [get_bd_pins xlslice_1/Din] [get_bd_pins xlslice_2/Din] [get_bd_pins xlslice_3/Din] [get_bd_pins xlslice_4/Din] [get_bd_pins xlslice_5/Din] [get_bd_pins xlslice_6/Din]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins s_axi_aclk] [get_bd_pins axi_gpio_0/s_axi_aclk]
  connect_bd_net -net s_axi_aresetn_1 [get_bd_pins s_axi_aresetn] [get_bd_pins axi_gpio_0/s_axi_aresetn]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins output_config] [get_bd_pins output_config/Dout]
  connect_bd_net -net xlslice_1_Dout [get_bd_pins term_config] [get_bd_pins xlslice_1/Dout]
  connect_bd_net -net xlslice_2_Dout [get_bd_pins FPGA_Out0] [get_bd_pins xlslice_2/Dout]
  connect_bd_net -net xlslice_3_Dout [get_bd_pins FPGA_Out1] [get_bd_pins xlslice_3/Dout]
  connect_bd_net -net xlslice_4_Dout [get_bd_pins FPGA_Out2] [get_bd_pins xlslice_4/Dout]
  connect_bd_net -net xlslice_5_Dout [get_bd_pins FPGA_Out3] [get_bd_pins xlslice_5/Dout]
  connect_bd_net -net xlslice_6_Dout [get_bd_pins FPGA_Out4] [get_bd_pins xlslice_6/Dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell board} {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]

  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]


  # Create ports
  set dio_clk_n_in_0 [ create_bd_port -dir I dio_clk_n_in_0 ]
  set dio_clk_p_in_0 [ create_bd_port -dir I dio_clk_p_in_0 ]
  set dio_led_bot_out_0 [ create_bd_port -dir O dio_led_bot_out_0 ]
  set dio_led_top_out_0 [ create_bd_port -dir O dio_led_top_out_0 ]
  set dio_n_in_0 [ create_bd_port -dir O -from 4 -to 0 dio_n_in_0 ]
  set dio_n_out_0 [ create_bd_port -dir I -from 4 -to 0 dio_n_out_0 ]
  set dio_oe_n_out_0 [ create_bd_port -dir O -from 4 -to 0 dio_oe_n_out_0 ]
  set dio_onewire_b_0 [ create_bd_port -dir IO dio_onewire_b_0 ]
  set dio_p_in_0 [ create_bd_port -dir O -from 4 -to 0 dio_p_in_0 ]
  set dio_p_out_0 [ create_bd_port -dir I -from 4 -to 0 dio_p_out_0 ]
  set dio_term_en_out_0 [ create_bd_port -dir O -from 4 -to 0 dio_term_en_out_0 ]

  # Create instance: AXI_Lite_GPIO
  create_hier_cell_AXI_Lite_GPIO [current_bd_instance .] AXI_Lite_GPIO

  # Create instance: LED_Driver
  create_hier_cell_LED_Driver [current_bd_instance .] LED_Driver

  # Create instance: PS7
  create_hier_cell_PS7 [current_bd_instance .] PS7 $board

  # Create instance: digitalIO_0, and set properties
  set digitalIO_0 [ create_bd_cell -type ip -vlnv ess.eu:icshwi:digitalIO:1.0 digitalIO_0 ]

  # Create instance: ila_0, and set properties
  set ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_0 ]
  set_property -dict [ list \
   CONFIG.C_DATA_DEPTH {32768} \
   CONFIG.C_ENABLE_ILA_AXI_MON {false} \
   CONFIG.C_MONITOR_TYPE {Native} \
   CONFIG.C_NUM_OF_PROBES {15} \
 ] $ila_0

  # Create interface connections
  connect_bd_intf_net -intf_net PS7_M00_AXI [get_bd_intf_pins AXI_Lite_GPIO/S_AXI] [get_bd_intf_pins PS7/M00_AXI]
  connect_bd_intf_net -intf_net PS7_M01_AXI [get_bd_intf_pins LED_Driver/S00_AXI] [get_bd_intf_pins PS7/M01_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins PS7/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins PS7/FIXED_IO]

  # Create port connections
  connect_bd_net -net LED_Driver_0_p_led_o [get_bd_pins LED_Driver/LED] [get_bd_pins digitalIO_0/LED_bot] [get_bd_pins ila_0/probe7]
  connect_bd_net -net Net [get_bd_ports dio_onewire_b_0] [get_bd_pins digitalIO_0/dio_onewire_b]
  connect_bd_net -net digitalIO_0_dio_led_bot_out [get_bd_ports dio_led_bot_out_0] [get_bd_pins digitalIO_0/dio_led_bot_out]
  connect_bd_net -net digitalIO_0_dio_led_top_out [get_bd_ports dio_led_top_out_0] [get_bd_pins digitalIO_0/dio_led_top_out]
  connect_bd_net -net digitalIO_0_dio_n_in [get_bd_ports dio_n_in_0] [get_bd_pins digitalIO_0/dio_n_in]
  connect_bd_net -net digitalIO_0_dio_oe_n_out [get_bd_ports dio_oe_n_out_0] [get_bd_pins digitalIO_0/dio_oe_n_out]
  connect_bd_net -net digitalIO_0_dio_p_in [get_bd_ports dio_p_in_0] [get_bd_pins digitalIO_0/dio_p_in]
  connect_bd_net -net digitalIO_0_dio_term_en_out [get_bd_ports dio_term_en_out_0] [get_bd_pins digitalIO_0/dio_term_en_out]
  connect_bd_net -net digitalIO_0_from_FPGA_dbg_o [get_bd_pins digitalIO_0/from_FPGA_dbg_o] [get_bd_pins ila_0/probe13]
  connect_bd_net -net digitalIO_0_to_FPGA_0 [get_bd_pins digitalIO_0/to_FPGA_0] [get_bd_pins ila_0/probe8]
  connect_bd_net -net digitalIO_0_to_FPGA_1 [get_bd_pins digitalIO_0/to_FPGA_1] [get_bd_pins ila_0/probe9]
  connect_bd_net -net digitalIO_0_to_FPGA_2 [get_bd_pins digitalIO_0/to_FPGA_2] [get_bd_pins ila_0/probe10]
  connect_bd_net -net digitalIO_0_to_FPGA_3 [get_bd_pins digitalIO_0/to_FPGA_3] [get_bd_pins ila_0/probe11]
  connect_bd_net -net digitalIO_0_to_FPGA_4 [get_bd_pins digitalIO_0/to_FPGA_4] [get_bd_pins ila_0/probe12]
  connect_bd_net -net digitalIO_0_to_FPGA_dbg_o [get_bd_pins digitalIO_0/to_FPGA_dbg_o] [get_bd_pins ila_0/probe14]
  connect_bd_net -net dio_clk_n_in_0_1 [get_bd_ports dio_clk_n_in_0] [get_bd_pins digitalIO_0/dio_clk_n_in]
  connect_bd_net -net dio_clk_p_in_0_1 [get_bd_ports dio_clk_p_in_0] [get_bd_pins digitalIO_0/dio_clk_p_in]
  connect_bd_net -net dio_n_out_0_1 [get_bd_ports dio_n_out_0] [get_bd_pins digitalIO_0/dio_n_out]
  connect_bd_net -net dio_p_out_0_1 [get_bd_ports dio_p_out_0] [get_bd_pins digitalIO_0/dio_p_out]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins AXI_Lite_GPIO/s_axi_aclk] [get_bd_pins LED_Driver/s00_axi_aclk] [get_bd_pins PS7/FCLK_CLK0] [get_bd_pins ila_0/clk]
  connect_bd_net -net s_axi_aresetn_1 [get_bd_pins AXI_Lite_GPIO/s_axi_aresetn] [get_bd_pins LED_Driver/s00_axi_aresetn] [get_bd_pins PS7/S00_ARESETN]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins LED_Driver/Not_LED] [get_bd_pins digitalIO_0/LED_top] [get_bd_pins ila_0/probe6]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins AXI_Lite_GPIO/output_config] [get_bd_pins digitalIO_0/output_config] [get_bd_pins ila_0/probe0]
  connect_bd_net -net xlslice_1_Dout [get_bd_pins AXI_Lite_GPIO/term_config] [get_bd_pins digitalIO_0/term_config] [get_bd_pins ila_0/probe1]
  connect_bd_net -net xlslice_2_Dout [get_bd_pins AXI_Lite_GPIO/FPGA_Out0] [get_bd_pins digitalIO_0/from_FPGA_0]
  connect_bd_net -net xlslice_3_Dout [get_bd_pins AXI_Lite_GPIO/FPGA_Out1] [get_bd_pins digitalIO_0/from_FPGA_1] [get_bd_pins ila_0/probe2]
  connect_bd_net -net xlslice_4_Dout [get_bd_pins AXI_Lite_GPIO/FPGA_Out2] [get_bd_pins digitalIO_0/from_FPGA_2] [get_bd_pins ila_0/probe3]
  connect_bd_net -net xlslice_5_Dout [get_bd_pins AXI_Lite_GPIO/FPGA_Out3] [get_bd_pins digitalIO_0/from_FPGA_3] [get_bd_pins ila_0/probe4]
  connect_bd_net -net xlslice_6_Dout [get_bd_pins AXI_Lite_GPIO/FPGA_Out4] [get_bd_pins digitalIO_0/from_FPGA_4] [get_bd_pins ila_0/probe5]

  # Create address segments
  assign_bd_address -offset 0x43C00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces PS7/processing_system7_0/Data] [get_bd_addr_segs LED_Driver/LED_Driver_0/S00_AXI/S00_AXI_reg] -force
  assign_bd_address -offset 0x43C10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces PS7/processing_system7_0/Data] [get_bd_addr_segs AXI_Lite_GPIO/axi_gpio_0/S_AXI/Reg] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design "" $board


common::send_msg_id "BD_TCL-1000" "WARNING" "This Tcl script was generated from a block design that has not been validated. It is possible that design <$design_name> may result in errors during validation."

