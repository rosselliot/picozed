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
xilinx.com:ip:util_vector_logic:2.0\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:clk_wiz:6.0\
Beckhoff:ess:ethercat_slave:3.0\
xilinx.com:ip:processing_system7:5.5\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:xlslice:1.0\
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


# Hierarchical cell: LED_Slice
proc create_hier_cell_LED_Slice { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_LED_Slice() - Empty argument(s)!"}
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

  # Create pins
  create_bd_pin -dir I -from 1 -to 0 Din
  create_bd_pin -dir O -from 0 -to 0 o_ECATS_PHY1_LINK_LED
  create_bd_pin -dir O -from 0 -to 0 o_ECATS_PHY2_LINK_LED

  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [ list \
   CONFIG.DIN_WIDTH {2} \
 ] $xlslice_0

  # Create instance: xlslice_1, and set properties
  set xlslice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_1 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {1} \
   CONFIG.DIN_TO {1} \
   CONFIG.DIN_WIDTH {2} \
   CONFIG.DOUT_WIDTH {1} \
 ] $xlslice_1

  # Create port connections
  connect_bd_net -net test_conf_0_LED_LINK_ACT [get_bd_pins Din] [get_bd_pins xlslice_0/Din] [get_bd_pins xlslice_1/Din]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins o_ECATS_PHY1_LINK_LED] [get_bd_pins xlslice_0/Dout]
  connect_bd_net -net xlslice_1_Dout [get_bd_pins o_ECATS_PHY2_LINK_LED] [get_bd_pins xlslice_1/Dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: GPIO_Bus
proc create_hier_cell_GPIO_Bus { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_GPIO_Bus() - Empty argument(s)!"}
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

  # Create pins
  create_bd_pin -dir O -from 31 -to 0 dout
  create_bd_pin -dir I -from 0 -to 0 i_SY87730_LOCKED

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {32} \
 ] $xlconcat_0

  # Create port connections
  connect_bd_net -net i_SY87730_LOCKED_1 [get_bd_pins i_SY87730_LOCKED] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins dout] [get_bd_pins xlconcat_0/dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

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
  set i_ECATS_MII_RX_CLK0 [ create_bd_port -dir I i_ECATS_MII_RX_CLK0 ]
  set i_ECATS_MII_RX_CLK1 [ create_bd_port -dir I i_ECATS_MII_RX_CLK1 ]
  set i_ECATS_MII_RX_DATA0 [ create_bd_port -dir I -from 3 -to 0 i_ECATS_MII_RX_DATA0 ]
  set i_ECATS_MII_RX_DATA1 [ create_bd_port -dir I -from 3 -to 0 i_ECATS_MII_RX_DATA1 ]
  set i_ECATS_MII_RX_DV0 [ create_bd_port -dir I i_ECATS_MII_RX_DV0 ]
  set i_ECATS_MII_RX_DV1 [ create_bd_port -dir I i_ECATS_MII_RX_DV1 ]
  set i_ECATS_MII_RX_ERR0 [ create_bd_port -dir I i_ECATS_MII_RX_ERR0 ]
  set i_ECATS_MII_RX_ERR1 [ create_bd_port -dir I i_ECATS_MII_RX_ERR1 ]
  set i_ECATS_PHY0_AN1 [ create_bd_port -dir I i_ECATS_PHY0_AN1 ]
  set i_ECATS_PHY1_AN1 [ create_bd_port -dir I i_ECATS_PHY1_AN1 ]
  set i_SY87730_LOCKED [ create_bd_port -dir I -type data i_SY87730_LOCKED ]
  set io_ECATS_MDIO_DATA [ create_bd_port -dir IO io_ECATS_MDIO_DATA ]
  set o_ECATS_CLK25 [ create_bd_port -dir O -type clk o_ECATS_CLK25 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {25000000} \
 ] $o_ECATS_CLK25
  set o_ECATS_MCLK [ create_bd_port -dir O o_ECATS_MCLK ]
  set o_ECATS_MII_TX_DATA0 [ create_bd_port -dir O -from 3 -to 0 o_ECATS_MII_TX_DATA0 ]
  set o_ECATS_MII_TX_DATA1 [ create_bd_port -dir O -from 3 -to 0 o_ECATS_MII_TX_DATA1 ]
  set o_ECATS_MII_TX_ENA0 [ create_bd_port -dir O o_ECATS_MII_TX_ENA0 ]
  set o_ECATS_MII_TX_ENA1 [ create_bd_port -dir O o_ECATS_MII_TX_ENA1 ]
  set o_ECATS_NPHY_RESET_OUT0 [ create_bd_port -dir O o_ECATS_NPHY_RESET_OUT0 ]
  set o_ECATS_PHY1_ERR_LED [ create_bd_port -dir O -from 0 -to 0 o_ECATS_PHY1_ERR_LED ]
  set o_ECATS_PHY1_LINK_LED [ create_bd_port -dir O -from 0 -to 0 o_ECATS_PHY1_LINK_LED ]
  set o_ECATS_PHY1_RUN_LED [ create_bd_port -dir O o_ECATS_PHY1_RUN_LED ]
  set o_ECATS_PHY2_LINK_LED [ create_bd_port -dir O -from 0 -to 0 o_ECATS_PHY2_LINK_LED ]
  set o_ECATS_PWDN1 [ create_bd_port -dir O -from 0 -to 0 o_ECATS_PWDN1 ]
  set o_ECATS_PWDN2 [ create_bd_port -dir O -from 0 -to 0 o_ECATS_PWDN2 ]
  set o_ECATS_SW_STRAP1 [ create_bd_port -dir O -from 0 -to 0 o_ECATS_SW_STRAP1 ]
  set o_ECATS_SW_STRAP2 [ create_bd_port -dir O -from 0 -to 0 o_ECATS_SW_STRAP2 ]
  set o_EVR_ENABLE [ create_bd_port -dir O -from 0 -to 0 o_EVR_ENABLE ]
  set o_EVR_EVNT_LED [ create_bd_port -dir O -from 0 -to 0 o_EVR_EVNT_LED ]
  set o_EVR_LINK_LED [ create_bd_port -dir O -from 0 -to 0 -type data o_EVR_LINK_LED ]
  set o_SI5346_RST_rn [ create_bd_port -dir O -from 0 -to 0 o_SI5346_RST_rn ]
  set o_SY87730_PROGCS [ create_bd_port -dir O -from 0 -to 0 -type data o_SY87730_PROGCS ]
  set o_SY87730_PROGDI [ create_bd_port -dir O -type data o_SY87730_PROGDI ]
  set o_SY87730_PROGSK [ create_bd_port -dir O -type clk o_SY87730_PROGSK ]

  # Create instance: GPIO_Bus
  create_hier_cell_GPIO_Bus [current_bd_instance .] GPIO_Bus

  # Create instance: LED_Slice
  create_hier_cell_LED_Slice [current_bd_instance .] LED_Slice

  # Create instance: SPI0_SS_O_Not, and set properties
  set SPI0_SS_O_Not [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 SPI0_SS_O_Not ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $SPI0_SS_O_Not

  # Create instance: SPI0_SS_VCC, and set properties
  set SPI0_SS_VCC [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 SPI0_SS_VCC ]

  # Create instance: Si5346_RST_N, and set properties
  set Si5346_RST_N [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 Si5346_RST_N ]

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [ list \
   CONFIG.CLKOUT1_JITTER {175.402} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {25} \
   CONFIG.CLKOUT2_JITTER {130.958} \
   CONFIG.CLKOUT2_PHASE_ERROR {98.575} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {100} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {40.000} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {10} \
   CONFIG.NUM_OUT_CLKS {2} \
   CONFIG.RESET_PORT {resetn} \
   CONFIG.RESET_TYPE {ACTIVE_LOW} \
   CONFIG.USE_LOCKED {false} \
 ] $clk_wiz_0

  # Create instance: ecats_IP_latch_0, and set properties
  set ecats_IP_latch_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 ecats_IP_latch_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $ecats_IP_latch_0

  # Create instance: ethercat_FMC_IP, and set properties
  set ethercat_FMC_IP [ create_bd_cell -type ip -vlnv Beckhoff:ess:ethercat_slave:3.0 ethercat_FMC_IP ]

  # Create instance: evr_clk_en, and set properties
  set evr_clk_en [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 evr_clk_en ]

  # Create instance: leddriver, and set properties
  set leddriver [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 leddriver ]

  # Source board-specific PS7 tcl file
  source project/common/zynq_ps_config.tcl
  # PS7 settings specific to this project   
  set_property -dict [list CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_IRQ_F2P_INTR {1} CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {1}] [get_bd_cells processing_system7_0]

  # Create instance: ps7_0_axi_periph, and set properties
  set ps7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ps7_0_axi_periph ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
 ] $ps7_0_axi_periph

  # Create instance: rst_ps7_0_100M, and set properties
  set rst_ps7_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ps7_0_100M ]

  # Create instance: strapping_pins, and set properties
  set strapping_pins [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 strapping_pins ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {1} \
 ] $strapping_pins

  # Create interface connections
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins ps7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M00_AXI [get_bd_intf_pins ethercat_FMC_IP/PDI_AXI] [get_bd_intf_pins ps7_0_axi_periph/M00_AXI]

  # Create port connections
  connect_bd_net -net GPIO_Bus_dout [get_bd_pins GPIO_Bus/dout] [get_bd_pins processing_system7_0/GPIO_I]
  connect_bd_net -net MII_RX_CLK0_0_1 [get_bd_ports i_ECATS_MII_RX_CLK0] [get_bd_pins ethercat_FMC_IP/MII_RX_CLK0]
  connect_bd_net -net MII_RX_CLK1_0_1 [get_bd_ports i_ECATS_MII_RX_CLK1] [get_bd_pins ethercat_FMC_IP/MII_RX_CLK1]
  connect_bd_net -net MII_RX_DATA0_0_1 [get_bd_ports i_ECATS_MII_RX_DATA0] [get_bd_pins ethercat_FMC_IP/MII_RX_DATA0]
  connect_bd_net -net MII_RX_DATA1_0_1 [get_bd_ports i_ECATS_MII_RX_DATA1] [get_bd_pins ethercat_FMC_IP/MII_RX_DATA1]
  connect_bd_net -net MII_RX_DV0_0_1 [get_bd_ports i_ECATS_MII_RX_DV0] [get_bd_pins ethercat_FMC_IP/MII_RX_DV0]
  connect_bd_net -net MII_RX_DV1_0_1 [get_bd_ports i_ECATS_MII_RX_DV1] [get_bd_pins ethercat_FMC_IP/MII_RX_DV1]
  connect_bd_net -net MII_RX_ERR0_0_1 [get_bd_ports i_ECATS_MII_RX_ERR0] [get_bd_pins ethercat_FMC_IP/MII_RX_ERR0]
  connect_bd_net -net MII_RX_ERR1_0_1 [get_bd_ports i_ECATS_MII_RX_ERR1] [get_bd_pins ethercat_FMC_IP/MII_RX_ERR1]
  connect_bd_net -net Net [get_bd_ports io_ECATS_MDIO_DATA] [get_bd_pins ethercat_FMC_IP/MDIO_DATA_IO]
  connect_bd_net -net SPI0_SS_VCC1_dout [get_bd_pins ecats_IP_latch_0/dout] [get_bd_pins ethercat_FMC_IP/LATCH_IN0] [get_bd_pins ethercat_FMC_IP/LATCH_IN1]
  connect_bd_net -net Si5346_RST_N_dout [get_bd_ports o_SI5346_RST_rn] [get_bd_pins Si5346_RST_N/dout]
  connect_bd_net -net clk_wiz_0_clk_out1 [get_bd_ports o_ECATS_CLK25] [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins ethercat_FMC_IP/CLK25]
  connect_bd_net -net clk_wiz_0_clk_out2 [get_bd_pins clk_wiz_0/clk_out2] [get_bd_pins ethercat_FMC_IP/CLK100]
  connect_bd_net -net ecats_IP_latch_1_dout [get_bd_ports o_ECATS_PWDN1] [get_bd_ports o_ECATS_PWDN2] [get_bd_ports o_ECATS_SW_STRAP1] [get_bd_ports o_ECATS_SW_STRAP2] [get_bd_pins strapping_pins/dout]
  connect_bd_net -net evr_clk_en_dout [get_bd_ports o_EVR_ENABLE] [get_bd_pins evr_clk_en/dout]
  connect_bd_net -net i_SY87730_LOCKED_1 [get_bd_ports i_SY87730_LOCKED] [get_bd_pins GPIO_Bus/i_SY87730_LOCKED]
  connect_bd_net -net leddriver_dout [get_bd_ports o_EVR_EVNT_LED] [get_bd_ports o_EVR_LINK_LED] [get_bd_pins leddriver/dout]
  connect_bd_net -net nMII_LINK0_0_1 [get_bd_ports i_ECATS_PHY0_AN1] [get_bd_pins ethercat_FMC_IP/nMII_LINK0]
  connect_bd_net -net nMII_LINK1_0_1 [get_bd_ports i_ECATS_PHY1_AN1] [get_bd_pins ethercat_FMC_IP/nMII_LINK1]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins clk_wiz_0/clk_in1] [get_bd_pins ethercat_FMC_IP/PDI_AXI_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins ps7_0_axi_periph/ACLK] [get_bd_pins ps7_0_axi_periph/M00_ACLK] [get_bd_pins ps7_0_axi_periph/S00_ACLK] [get_bd_pins rst_ps7_0_100M/slowest_sync_clk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_ps7_0_100M/ext_reset_in]
  connect_bd_net -net processing_system7_0_SPI0_MOSI_O [get_bd_ports o_SY87730_PROGDI] [get_bd_pins processing_system7_0/SPI0_MOSI_O]
  connect_bd_net -net processing_system7_0_SPI0_SCLK_O [get_bd_ports o_SY87730_PROGSK] [get_bd_pins processing_system7_0/SPI0_SCLK_O]
  connect_bd_net -net processing_system7_0_SPI0_SS_O [get_bd_pins SPI0_SS_O_Not/Op1] [get_bd_pins processing_system7_0/SPI0_SS_O]
  connect_bd_net -net rst_ps7_0_100M_peripheral_aresetn [get_bd_pins clk_wiz_0/resetn] [get_bd_pins ethercat_FMC_IP/NRESET] [get_bd_pins ps7_0_axi_periph/ARESETN] [get_bd_pins ps7_0_axi_periph/M00_ARESETN] [get_bd_pins ps7_0_axi_periph/S00_ARESETN] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
  connect_bd_net -net spiSSTieOff_dout [get_bd_pins SPI0_SS_VCC/dout] [get_bd_pins processing_system7_0/SPI0_SS_I]
  connect_bd_net -net test_conf_0_LED_ERR [get_bd_ports o_ECATS_PHY1_ERR_LED] [get_bd_pins ethercat_FMC_IP/LED_ERR]
  connect_bd_net -net test_conf_0_LED_LINK_ACT [get_bd_pins LED_Slice/Din] [get_bd_pins ethercat_FMC_IP/LED_LINK_ACT]
  connect_bd_net -net test_conf_0_LED_RUN [get_bd_ports o_ECATS_PHY1_RUN_LED] [get_bd_pins ethercat_FMC_IP/LED_RUN]
  connect_bd_net -net test_conf_0_MCLK [get_bd_ports o_ECATS_MCLK] [get_bd_pins ethercat_FMC_IP/MCLK]
  connect_bd_net -net test_conf_0_MII_TX_DATA0 [get_bd_ports o_ECATS_MII_TX_DATA0] [get_bd_pins ethercat_FMC_IP/MII_TX_DATA0]
  connect_bd_net -net test_conf_0_MII_TX_DATA1 [get_bd_ports o_ECATS_MII_TX_DATA1] [get_bd_pins ethercat_FMC_IP/MII_TX_DATA1]
  connect_bd_net -net test_conf_0_MII_TX_ENA0 [get_bd_ports o_ECATS_MII_TX_ENA0] [get_bd_pins ethercat_FMC_IP/MII_TX_ENA0]
  connect_bd_net -net test_conf_0_MII_TX_ENA1 [get_bd_ports o_ECATS_MII_TX_ENA1] [get_bd_pins ethercat_FMC_IP/MII_TX_ENA1]
  connect_bd_net -net test_conf_0_NPHY_RESET_OUT0 [get_bd_ports o_ECATS_NPHY_RESET_OUT0] [get_bd_pins ethercat_FMC_IP/NPHY_RESET_OUT0]
  connect_bd_net -net test_conf_0_PDI_AXI_IRQ_MAIN [get_bd_pins ethercat_FMC_IP/PDI_AXI_IRQ_MAIN] [get_bd_pins processing_system7_0/IRQ_F2P]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_ports o_SY87730_PROGCS] [get_bd_pins SPI0_SS_O_Not/Res]
  connect_bd_net -net xlslice_0_Dout [get_bd_ports o_ECATS_PHY1_LINK_LED] [get_bd_pins LED_Slice/o_ECATS_PHY1_LINK_LED]
  connect_bd_net -net xlslice_1_Dout [get_bd_ports o_ECATS_PHY2_LINK_LED] [get_bd_pins LED_Slice/o_ECATS_PHY2_LINK_LED]

  # Create address segments
  assign_bd_address -offset 0x43C00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs ethercat_FMC_IP/PDI_AXI/reg0] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


