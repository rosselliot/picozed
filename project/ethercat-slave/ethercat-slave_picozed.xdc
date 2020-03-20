# =============================================================================
# @file   picoevr.xdc
# @brief  Top constraint file for the PicoEVR firmware
# -----------------------------------------------------------------------------
# @author Felipe Torres González <felipe.torresgonzalez@ess.eu>
# @company European Spallation Source ERIC
# @date 20200117
# 
# Platform:       picoZED 7030
# Carrier board:  Tallinn picoZED carrier board (aka FPGA-based IOC)
# Based on the AVNET xdc file for the picozed 7z030 RevC v2
# =============================================================================


# =============================================================================
# Clocks
# =============================================================================
# From Si5346 Out0 - ? MHz
set_property PACKAGE_PIN V9   [get_ports {i_ZYNQ_CLKREF0_N   }];   # "V9.MGTREFCLKC0_N"
# From Si5346 Out1 - ? MHz
set_property PACKAGE_PIN V5   [get_ports {i_ZYNQ_CLKREF1_N   }];  # "V5.MGTREFCLKC1_N"
# From Si5346 Out2 - ? MHz
set_property PACKAGE_PIN Y19  [get_ports {i_ZYNQ_MRCC_LVDS_N }];  # "Y18.BANK13_LVDS_7_N"
set_property PACKAGE_PIN AB5  [get_ports {i_DP0_M2C_N        }];  # "AB5.MGTTX2_N"


# =============================================================================
# Si5346
# =============================================================================

# Si5346 Loss of signal alarm on the XA/XB pins 
set_property PACKAGE_PIN H3   [get_ports {i_SI5346_LOL_XAXB }];  # "H3.JX1_LVDS_0_N"
# Si5346 Output Enable 1
set_property PACKAGE_PIN E5   [get_ports {o_SI5346_OE1      }];  # "E5.JX1_LVDS_1_N"
# Si5346 Output Enable 0
set_property PACKAGE_PIN F5   [get_ports {o_SI5346_OE0      }];  # "F5.JX1_LVDS_1_P"
# Si5346 Loss of lock A - H: Locked | L: Out of lock
set_property PACKAGE_PIN G3   [get_ports {i_SI5346_LOL_A    }];  # "G3.JX1_LVDS_2_P"
# Si5346 Loss of lock B - H: Locked | L: Out of lock
set_property PACKAGE_PIN G2   [get_ports {i_SI5346_LOL_B    }];  # "G2.JX1_LVDS_2_N"
# Si5346 Device reset (active low)
set_property PACKAGE_PIN G4   [get_ports {o_SI5346_RST_rn   }];  # "G4.JX1_LVDS_4_P"
# Si5346 Interrupt pin (asserted low)
set_property PACKAGE_PIN F4   [get_ports {i_SI5346_INT_n    }];  # "F4.JX1_LVDS_4_N"

# =============================================================================
# SY87739
# =============================================================================
# Data In (Microwire interface)
set_property PACKAGE_PIN AB18 [get_ports {o_SY87730_PROGDI    }];  # "AB18.BANK13_LVDS_5_P"
# Chip select (Microwire interface)         
set_property PACKAGE_PIN AB19 [get_ports {o_SY87730_PROGCS[0] }];  # "AB19.BANK13_LVDS_5_N"
# Locked signal                             
set_property PACKAGE_PIN AB21 [get_ports {i_SY87730_LOCKED    }];  # "AB21.BANK13_LVDS_4_P"
# Serial clock (Microwire interface)        
set_property PACKAGE_PIN AB22 [get_ports {o_SY87730_PROGSK    }];  # "AB22.BANK13_LVDS_4_N"



# =============================================================================
# FMC
# =============================================================================

set_property PACKAGE_PIN C5   [get_ports {i_CLK1_M2C_N   }];  # "C5.JX1_LVDS_10_N"
set_property PACKAGE_PIN L4   [get_ports {i_CLK0_M2C_N   }];  # "L4.JX2_LVDS_11_N"

set_property PACKAGE_PIN AB9  [get_ports {o_DP0_C2M_N    }];  # "AB9.MGTRX2_N"

# Low when a mezzanine board is connected?
set_property PACKAGE_PIN Y14  [get_ports {i_FMC_PRSNT_N  }];  # "Y14.BANK13_LVDS_1_P"


# =============================================================================
# I2C
# =============================================================================
set_property PACKAGE_PIN T16  [get_ports {o_ZYNQ_I2C_BUS_MASTER_RST_rn}];  # "T16.BANK13_SE_0"

set_property PACKAGE_PIN AA20 [get_ports {b_FMC_SCL }];                    # "AA20.BANK13_LVDS_6_N"
set_property PACKAGE_PIN AA19 [get_ports {b_FMC_SDA }];                    # "AA19.BANK13_LVDS_6_P"

# 
set_property PACKAGE_PIN V18  [get_ports {SVC_I2C_MASTER_REQ   }];         # "V18.BANK13_LVDS_3_P"
set_property PACKAGE_PIN W18  [get_ports {SVC_I2C_MASTER_GRANT }];         # "W18.BANK13_LVDS_3_N"

# I2C Zynq-SVC (managment)
set_property PACKAGE_PIN C13  [get_ports {b_ZYNQ_I2C_SDA       }];         # PS_MIO51
set_property PACKAGE_PIN B13  [get_ports {b_ZYNQ_I2C_SCL       }];         # PS_MIO50

set_property PACKAGE_PIN AA16 [get_ports {i_ZYNQ_BUS_MASTER_I2C_INT_n    }];  # "AA16.BANK13_LVDS_8_P"
set_property PACKAGE_PIN D15  [get_ports {o_ZYNQ_I2C_BUS_SWITCH_RESET_rn }];


# =============================================================================
# ECATS FMC
# =============================================================================
set_property PACKAGE_PIN N4  [get_ports {o_ECATS_PHY1_LINK_LED  }];  # "D11.JX2_LVDS_6_P"
set_property PACKAGE_PIN N3  [get_ports {o_ECATS_PHY2_LINK_LED  }];  # "D12.JX2_LVDS_6_P"
set_property PACKAGE_PIN N1  [get_ports {o_ECATS_PHY1_RUN_LED   }];  # "D14.JX2_LVDS_9_P"
set_property PACKAGE_PIN R5  [get_ports {o_ECATS_PHY1_ERR_LED   }];  # "D17.JX2_LVDS_17_P"

#set_property PACKAGE_PIN  [get_ports {io_ECATS_PROM_DATA       }];  # "D17.JX2_LVDS_17_P"
#set_property PACKAGE_PIN  [get_ports {o_ECATS_PROM_CLK         }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN R7  [get_ports {i_ECATS_PHY0_AN1         }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN K4  [get_ports {i_ECATS_PHY0_AN2         }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN P7  [get_ports {i_ECATS_PHY0_EN          }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN K2  [get_ports {i_ECATS_PHY1_AN1         }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN L2  [get_ports {i_ECATS_PHY1_AN2         }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN J3  [get_ports {i_ECATS_PHY1_EN          }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN T2  [get_ports {i_ECATS_MII_RX_CLK0      }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN C6  [get_ports {i_ECATS_MII_RX_DV0       }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN B1  [get_ports {i_ECATS_MII_RX_DATA0[3]  }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN B2  [get_ports {i_ECATS_MII_RX_DATA0[2]  }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN E3  [get_ports {i_ECATS_MII_RX_DATA0[1]  }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN E4  [get_ports {i_ECATS_MII_RX_DATA0[0]  }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN C5  [get_ports {i_ECATS_MII_RX_ERR0      }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN B4  [get_ports {i_ECATS_MII_RX_CLK1      }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN A7  [get_ports {i_ECATS_MII_RX_DV1       }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN B6  [get_ports {i_ECATS_MII_RX_DATA1[3]  }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN B7  [get_ports {i_ECATS_MII_RX_DATA1[2]  }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN G7  [get_ports {i_ECATS_MII_RX_DATA1[1]  }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN G8  [get_ports {i_ECATS_MII_RX_DATA1[0]  }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN A6  [get_ports {i_ECATS_MII_RX_ERR1      }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN F6  [get_ports {io_ECATS_MDIO_DATA       }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN G6  [get_ports {o_ECATS_MCLK             }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN J8  [get_ports {o_ECATS_MII_TX_ENA0      }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN P5  [get_ports {o_ECATS_MII_TX_DATA0[3]  }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN P6  [get_ports {o_ECATS_MII_TX_DATA0[2]  }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN M6  [get_ports {o_ECATS_MII_TX_DATA0[1]  }];  # "D17.JX2_LVDS_17_P" 
set_property PACKAGE_PIN L6  [get_ports {o_ECATS_MII_TX_DATA0[0]  }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN A5  [get_ports {o_ECATS_NPHY_RESET_OUT0  }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN P3  [get_ports {o_ECATS_MII_TX_ENA1      }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN J6  [get_ports {o_ECATS_MII_TX_DATA1[3]  }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN J7  [get_ports {o_ECATS_MII_TX_DATA1[2]  }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN R2  [get_ports {o_ECATS_MII_TX_DATA1[1]  }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN R3  [get_ports {o_ECATS_MII_TX_DATA1[0]  }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN E2  [get_ports {o_ECATS_CLK25            }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN A2  [get_ports {o_ECATS_FMC_CLK_EN       }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN K3  [get_ports {o_ECATS_SW_STRAP1        }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN L1  [get_ports {o_ECATS_SW_STRAP2        }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN J5  [get_ports {o_ECATS_PWDN1            }];  # "D17.JX2_LVDS_17_P"
set_property PACKAGE_PIN M2  [get_ports {o_ECATS_PWDN2            }];  # "D17.JX2_LVDS_17_P"

set_property IOSTANDARD LVCMOS18 [get_ports -regexp {.*ECATS_.*}]

# =============================================================================
# OpenEVR
# =============================================================================

# EVR enable
set_property PACKAGE_PIN W16  [get_ports {o_EVR_ENABLE}];      # "W16.BANK13_LVDS_16_N"
# Rx signal from SFP
set_property PACKAGE_PIN AB7  [get_ports {i_EVR_RX_N      }];  # "AB7.MGTRX0_N"
# EVR Link LED
set_property PACKAGE_PIN H5   [get_ports {o_EVR_LINK_LED  }];  # "H5.JX1_SE_1"
set_property PACKAGE_PIN H6   [get_ports {o_EVR_EVNT_LED  }];  # "H6.JX1_SE_0"

set_property PACKAGE_PIN Y13  [get_ports {EVR_RX_RATE     }];  # "Y13.BANK13_LVDS_10_N"
set_property PACKAGE_PIN Y12  [get_ports {EVR_RX_LOS      }];  # "Y12.BANK13_LVDS_10_P"
set_property PACKAGE_PIN V13  [get_ports {EVR_MOD_DEF_0   }];  # "V13.BANK13_LVDS_12_P"
set_property PACKAGE_PIN AB3  [get_ports {EVR_TX_N        }];  # "AB3.MGTTX0_N"
set_property PACKAGE_PIN AB11 [get_ports {EVR_TX_DISABLE  }];  # "AB11.BANK13_LVDS_9_N"
set_property PACKAGE_PIN AA11 [get_ports {EVR_TX_FAULT    }];  # "AA11.BANK13_LVDS_9_P"
set_property PACKAGE_PIN W11  [get_ports {EVR_MOD_DEF_2   }];  # "W11.BANK13_LVDS_11_N"
set_property PACKAGE_PIN V11  [get_ports {EVR_MOD_DEF_1   }];  # "V11.BANK13_LVDS_11_P"




# =============================================================================
# Secondary SFP port
# =============================================================================

# COM RX signal from SFP
set_property PACKAGE_PIN Y8   [get_ports {i_COM_RX_N      }];  # "Y8.MGTRX1_N"
set_property PACKAGE_PIN V14  [get_ports {COM_RX_LOS      }];  # "V14.BANK13_LVDS_12_N"
set_property PACKAGE_PIN T17  [get_ports {COM_MOD_DEF_0   }];  # "T17.BANK13_LVDS_14_N"
set_property PACKAGE_PIN R17  [get_ports {COM_RX_RATE     }];  # "R17.BANK13_LVDS_14_P"
set_property PACKAGE_PIN Y4   [get_ports {COM_TX_N        }];  # "Y4.MGTTX1_N"
set_property PACKAGE_PIN W13  [get_ports {COM_TX_DISABLE  }];  # "W13.BANK13_LVDS_13_N"
set_property PACKAGE_PIN W12  [get_ports {COM_TX_FAULT    }];  # "W12.BANK13_LVDS_13_P"
set_property PACKAGE_PIN W15  [get_ports {COM_MOD_DEF_2   }];  # "W15.BANK13_LVDS_15_N"
set_property PACKAGE_PIN V15  [get_ports {COM_MOD_DEF_1   }];  # "V15.BANK13_LVDS_15_P"


# =============================================================================
# General I/O
# =============================================================================

set_property PACKAGE_PIN B14  [get_ports {o_FPGA_RUN_LED  }];  # PS_MIO45

# =============================================================================
# UART
# =============================================================================
set_property PACKAGE_PIN B13  [get_ports {o_ZYNQ_UART_TX  }];  # PS_MIO47
set_property PACKAGE_PIN D12  [get_ports {o_SVC_UART_TX   }];  # PS_MIO48
set_property PAKCAGE_PIN C9   [get_ports {i_SVC_UART_RX   }];  # PS_MIO49
set_property PACKAGE_PIN D11  [get_ports {i_ZYNQ_UART_RX  }];  # PS_MIO46

set_property PACKAGE_PIN AA17 [get_ports {o_ZYNQ_UART_SWITCH_FPGA }];  # "AA17.BANK13_LVDS_8_N"


# ----------------------------------------------------------------------------
# IOSTANDARD Constraints
#
# Note that these IOSTANDARD constraints are applied to all IOs currently
# assigned within an I/O bank.  If these IOSTANDARD constraints are 
# evaluated prior to other PACKAGE_PIN constraints being applied, then 
# the IOSTANDARD specified will likely not be applied properly to those 
# pins.  Therefore, bank wide IOSTANDARD constraints should be placed 
# within the XDC file in a location that is evaluated AFTER all 
# PACKAGE_PIN constraints within the target bank have been evaluated.
#
# Un-comment one or more of the following IOSTANDARD constraints according to
# the bank pin assignments that are required within a design.
#
# Warning! Bank 34 and Bank 35 are a High Performance Banks on the 7030 
# and will only accept 1.8V level signals

# ---------------------------------------------------------------------------- 

# Set the bank voltage for IO Bank 34 to 1.8V by default.
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]];

# Set the bank voltage for IO Bank 35 to 1.8V by default.
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 35]];

# Set the bank voltage for IO Bank 13 to 1.8V by default. 
# set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 13]];
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 13]];
# IO Banck 13 is set to 3.3V in the carrier design.
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]];
