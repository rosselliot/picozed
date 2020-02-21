# =============================================================================
# DIO FMC CARD
# =============================================================================

# Differential clock from the FMC
set_property -dict {PACKAGE_PIN  D5 IOSTANDARD LVDS      DIFF_TERM TRUE } [ get_ports dio_clk_n_in_0 ]; # IO_L12P_T1_MRCC_35
set_property -dict {PACKAGE_PIN  C4 IOSTANDARD LVDS      DIFF_TERM TRUE } [ get_ports dio_clk_p_in_0 ]; # IO_L12N_T1_MRCC_35

# DIO LEDs
set_property -dict {PACKAGE_PIN  U2 IOSTANDARD LVCMOS18 } [ get_ports dio_led_bot_out_0 ]; # IO_L14P_T2_SRCC_34
set_property -dict {PACKAGE_PIN  U1 IOSTANDARD LVCMOS18 } [ get_ports dio_led_top_out_0 ]; # IO_L14N_T2_SRCC_34
 
# DIO Differential Outputs -- Input/Output names switched in Schematic
set_property -dict {PACKAGE_PIN  A5  IOSTANDARD LVDS   } [ get_ports dio_p_in_0[0] ]; # IO_L10P_T1_AD11P_35
set_property -dict {PACKAGE_PIN  D7  IOSTANDARD LVDS   } [ get_ports dio_p_in_0[1] ]; # IO_L2P_T0_AD8P_35
set_property -dict {PACKAGE_PIN  K4  IOSTANDARD LVDS   } [ get_ports dio_p_in_0[2] ]; # IO_L11P_T1_SRCC_34
set_property -dict {PACKAGE_PIN  M2  IOSTANDARD LVDS   } [ get_ports dio_p_in_0[3] ]; # IO_L15P_T2_DQS_34
set_property -dict {PACKAGE_PIN  L2  IOSTANDARD LVDS   } [ get_ports dio_p_in_0[4] ]; # IO_L10P_T1_34

set_property -dict {PACKAGE_PIN  A4  IOSTANDARD LVDS   } [ get_ports dio_n_in_0[0] ]; # IO_L10N_T1_AD11N_35
set_property -dict {PACKAGE_PIN  D6  IOSTANDARD LVDS   } [ get_ports dio_n_in_0[1] ]; # IO_L2N_T0_AD8N_35
set_property -dict {PACKAGE_PIN  K3  IOSTANDARD LVDS   } [ get_ports dio_n_in_0[2] ]; # IO_L11N_T1_SRCC_34
set_property -dict {PACKAGE_PIN  M1  IOSTANDARD LVDS   } [ get_ports dio_n_in_0[3] ]; # IO_L15N_T2_DQS_34
set_property -dict {PACKAGE_PIN  L1  IOSTANDARD LVDS   } [ get_ports dio_n_in_0[4] ]; # IO_L10N_T1_34

# DIO Differential Inputs -- Input/Output names switched in Schematic
set_property -dict {PACKAGE_PIN  C8  IOSTANDARD LVDS   DIFF_TERM TRUE } [ get_ports dio_p_out_0[0] ]; # IO_L7P_T1_AD2P_35
set_property -dict {PACKAGE_PIN  E4  IOSTANDARD LVDS   DIFF_TERM TRUE } [ get_ports dio_p_out_0[1] ]; # IO_L21P_T3_DQS_AD14P_35
set_property -dict {PACKAGE_PIN  J8  IOSTANDARD LVDS   DIFF_TERM TRUE } [ get_ports dio_p_out_0[2] ]; # IO_L1P_T0_34
set_property -dict {PACKAGE_PIN  P7  IOSTANDARD LVDS   DIFF_TERM TRUE } [ get_ports dio_p_out_0[3] ]; # IO_L24P_T3_34
set_property -dict {PACKAGE_PIN  T2  IOSTANDARD LVDS   DIFF_TERM TRUE } [ get_ports dio_p_out_0[4] ]; # IO_L13P_T2_MRCC_34

set_property -dict {PACKAGE_PIN  B8  IOSTANDARD LVDS   DIFF_TERM TRUE } [ get_ports dio_n_out_0[0] ]; # IO_L7N_T1_AD2N_35
set_property -dict {PACKAGE_PIN  E3  IOSTANDARD LVDS   DIFF_TERM TRUE } [ get_ports dio_n_out_0[1] ]; # IO_L21N_T3_DQS_AD14N_35
set_property -dict {PACKAGE_PIN  K8  IOSTANDARD LVDS   DIFF_TERM TRUE } [ get_ports dio_n_out_0[2] ]; # IO_L1N_T0_34
set_property -dict {PACKAGE_PIN  R7  IOSTANDARD LVDS   DIFF_TERM TRUE } [ get_ports dio_n_out_0[3] ]; # IO_L24N_T3_34
set_property -dict {PACKAGE_PIN  T1  IOSTANDARD LVDS   DIFF_TERM TRUE } [ get_ports dio_n_out_0[4] ]; # IO_L13N_T2_MRCC_34

# DIO OneWire and I2C
set_property -dict {PACKAGE_PIN  D8  IOSTANDARD LVCMOS18 } [ get_ports dio_onewire_b_0];  # IO_L3N_T0_DQS_AD1N_35

# DIO Output Enables
set_property -dict {PACKAGE_PIN  G8  IOSTANDARD LVCMOS18 } [ get_ports dio_oe_n_out_0[0] ]; # IO_L4P_T0_35
set_property -dict {PACKAGE_PIN  G1  IOSTANDARD LVCMOS18 } [ get_ports dio_oe_n_out_0[1] ]; # IO_L24N_T3_AD15N_35
set_property -dict {PACKAGE_PIN  P5  IOSTANDARD LVCMOS18 } [ get_ports dio_oe_n_out_0[2] ]; # IO_L20N_T3_34
set_property -dict {PACKAGE_PIN  L6  IOSTANDARD LVCMOS18 } [ get_ports dio_oe_n_out_0[3] ]; # IO_L4P_T0_34
set_property -dict {PACKAGE_PIN  N4  IOSTANDARD LVCMOS18 } [ get_ports dio_oe_n_out_0[4] ]; # IO_L21P_T3_DQS_34

# DIO Termination Enables
set_property -dict {PACKAGE_PIN  G7  IOSTANDARD LVCMOS18 } [ get_ports dio_term_en_out_0[0] ]; # IO_L4N_T0_35
set_property -dict {PACKAGE_PIN  P2  IOSTANDARD LVCMOS18 } [ get_ports dio_term_en_out_0[1] ]; # IO_L18N_T2_34
set_property -dict {PACKAGE_PIN  N3  IOSTANDARD LVCMOS18 } [ get_ports dio_term_en_out_0[2] ]; # IO_L21N_T3_DQS_34
set_property -dict {PACKAGE_PIN  N1  IOSTANDARD LVCMOS18 } [ get_ports dio_term_en_out_0[3] ]; # IO_L16P_T2_34
set_property -dict {PACKAGE_PIN  P1  IOSTANDARD LVCMOS18 } [ get_ports dio_term_en_out_0[4] ]; # IO_L16N_T2_34
