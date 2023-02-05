# part: XC7Z010CLG400ABX1733-1C

# FIXME: set_property IOSTANDARD LVCMOS33 [get_ports *]???
#   LVTTL(3.3) LVCMOS{12,15,18,25,33}
# IBUF_LOW_PR=OFF for high speed diff I/O?  SLEW=FAST?
# DRIVE? 4/8/12/16/24
#  max: LVCMOS12: 12 LVCMOS{15,25,33}: 16 LVCMOS18, LVTTL: 24
# PULLUP/PULLDOWN/KEEPER?

# Connected back to CPU
set_property LOC N16 [get_ports PS_MIO16]
  # 35 IO_L21N AD14N
set_property LOC L14 [get_ports PS_MIO18]
  # 35 IO_L22P AD7P

# IC+ IP101G 10/100 Fast Ethernet Transceiver
# 25MHz clock (MRCC)
set_property LOC U18 [get_ports CLK25]
  # 34 IO_L12P MRCC (requires R1485, so NC to fpga)
set_property IOSTANDARD LVCMOS33 [get_ports CLK25]
  # Note that if it is connected, that likely means the XTAL is missing, and
  # the clock has to be generated by the FPGA.
# Not using PS_MIO16..27 or PS_MIO28..39 requires use of EMIO/FPGA.
set_property LOC W15 [get_ports ETH_MDC]
  # 34 IO_L10N
set_property LOC Y14 [get_ports ETH_MDIO]
  # 34 IO_L8N
set_property LOC U14 [get_ports ETH_RXCLK]
  # 34 IO_L11P SRCC
set_property LOC Y16 [get_ports ETH_RXD[0]]
  # 34 IO_L7P
set_property LOC V16 [get_ports ETH_RXD[1]]
  # 34 IO_L18P
set_property LOC V17 [get_ports ETH_RXD[2]]
  # 34 IO_L21P
set_property LOC Y17 [get_ports ETH_RXD[3]]
  # 34 IO_L7N
set_property LOC W16 [get_ports ETH_RXDV]
  # 34 IO_L18N
set_property LOC U15 [get_ports ETH_TXCLK]
  # 34 IO_L11N SRCC
set_property LOC W18 [get_ports ETH_TXD[0]]
  # 34 IO_L22P
set_property LOC Y18 [get_ports ETH_TXD[1]]
  # 34 IO_L17P
set_property LOC V18 [get_ports ETH_TXD[2]]
  # 34 IO_L21N
set_property LOC Y19 [get_ports ETH_TXD[3]]
  # 34 IO_L17N
set_property LOC W19 [get_ports ETH_TXEN]
  # 34 IO_L22N
#  REGOUT (tp?)
# From raw ethernet example:
set_property IOSTANDARD LVCMOS33 [get_ports ETH_MDC]
set_property IOSTANDARD LVCMOS33 [get_ports ETH_MDIO]
set_property IOSTANDARD LVCMOS33 [get_ports ETH_RXCLK]
set_property IOSTANDARD LVCMOS33 [get_ports {ETH_RXD[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ETH_RXD[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ETH_RXD[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ETH_RXD[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports ETH_RXDV]
set_property IOSTANDARD LVCMOS33 [get_ports ETH_TXCLK]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {ETH_TXCLK_IBUF}]
set_property IOSTANDARD LVCMOS33 [get_ports {ETH_TXD[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ETH_TXD[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ETH_TXD[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ETH_TXD[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ETH_TXEN}]

# Fan control on rear: J3, J5.
set_property LOC V13 [get_ports SPEED_J3]
  # 34 IO_L3N
set_property LOC U12 [get_ports PWM_J3]
  # 34 IO_L2N
set_property LOC V15 [get_ports SPEED_J5]
  # 34 IO_L10P
set_property LOC V12 [get_ports PWM_J5]
  # 34 IO_L4P

# Green LED to left of FPGA.  Not GPIO-capable
#set_property LOC R11 [get_ports LED[1]]
  # DONE_0 (and pullup)
# LED2 and LED3 are likely the ethernet LEDS, controlled by the IP101G.
# LED4 is the power LED in upper left near IP101G (can't control)
# There is a two-LED package on the rear labeled LED6.  I suspect LED5
# is the bottom (red), and LED6 is the top (green).
# Apparently emio[0] is red, and emio[1] is green by default
set_property LOC W13 [get_ports LED_GREEN]
  # 34 IO_L4N
set_property LOC W14 [get_ports LED_RED]
  # 34 IO_L8P
set_property LOC W13 [get_ports LED[6]]
  # 34 IO_L4N
set_property LOC W14 [get_ports LED[5]]
  # 34 IO_L8P
set_property IOSTANDARD LVCMOS33 [get_ports LED_GREEN]
set_property IOSTANDARD LVCMOS33 [get_ports LED_RED]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[5]}]


# DATA connectors (20 pin, 2mm) (numbered l-r, t-b)
set_property LOC A20 [get_ports DATA1_5]
  # 35 IO_L2N  AD8N
set_property LOC H16 [get_ports DATA1_6]
  # 35 IO_L13P MRCC
set_property LOC B19 [get_ports DATA1_7]
  # 35 IO_L2P  AD8P
set_property LOC B20 [get_ports DATA1_8]
  # 35 IO_L1N  AD0N
set_property LOC C20 [get_ports DATA1_9]
  # 35 IO_L1P  AD0P
set_property LOC H17 [get_ports DATA1_11]
  # 35 IO_L13N MRCC
set_property LOC D20 [get_ports DATA1_13]
  # 35 IO_L4N
set_property LOC D18 [get_ports DATA1_14]
  # 35 IO_L3N  AD1N
set_property LOC H18 [get_ports DATA1_15]
  # 35 IO_L14N AD4N SRCC
set_property LOC D19 [get_ports DATA1_16]
  # 35 IO_L4P
set_property LOC F20 [get_ports DATA1_17]
  # 35 IO_L15N AD12N
set_property LOC E19 [get_ports DATA1_18]
  # 35 IO_L5N  AD9N
set_property LOC F19 [get_ports DATA1_19]
  # 35 IO_L15P AD12P
set_property LOC K17 [get_ports DATA1_20]
  # 35 IO_L12P MRCC

set_property LOC G20 [get_ports DATA2_4]
  # 35 IO_L18N AD13N
set_property LOC J18 [get_ports DATA2_6]
  # 35 IO_L14P AD4P SRCC
set_property LOC G19 [get_ports DATA2_7]
  # 35 IO_L18P AD13P
set_property LOC H20 [get_ports DATA2_8]
  # 35 IO_L17N AD5N
set_property LOC J19 [get_ports DATA2_9]
  # 35 IO_L10N AD11N
set_property LOC K18 [get_ports DATA2_11]
  # 35 IO_L12N MRCC
set_property LOC K19 [get_ports DATA2_13]
  # 35 IO_L10P AD11P
set_property LOC J20 [get_ports DATA2_14]
  # 35 IO_L17P AD5P
set_property LOC L16 [get_ports DATA2_15]
  # 35 IO_L11P SRCC
set_property LOC L19 [get_ports DATA2_16]
  # 35 IO_L9P  AD3P
set_property LOC M18 [get_ports DATA2_17]
  # 35 IO_L8N  AD10N
set_property LOC L20 [get_ports DATA2_18]
  # 35 IO_L9N  AD3N
set_property LOC M20 [get_ports DATA2_19]
  # 35 IO_L7N  AD2N
set_property LOC L17 [get_ports DATA2_20]
  # 35 IO_L11N SRCC

set_property LOC M19 [get_ports DATA3_5]
  # 35 IO_L7P  AD2P
set_property LOC N20 [get_ports DATA3_6]
  # 34 IO_L14P SRCC
set_property LOC P18 [get_ports DATA3_7]
  # 34 IO_L23N
set_property LOC M17 [get_ports DATA3_8]
  # 35 IO_L8P  AD10P
set_property LOC N17 [get_ports DATA3_9]
  # 34 IO_L23P
set_property LOC P20 [get_ports DATA3_11]
  # 34 IO_L14N SRCC
set_property LOC R18 [get_ports DATA3_13]
  # 34 IO_L20N
set_property LOC R19 [get_ports DATA3_14]
  # 34 IO_0
set_property LOC P19 [get_ports DATA3_15]
  # 34 IO_L13N MRCC
set_property LOC T20 [get_ports DATA3_16]
  # 34 IO_L15P
set_property LOC U20 [get_ports DATA3_17]
  # 34 IO_L15N
set_property LOC T19 [get_ports DATA3_18]
  # 34 IO_25
set_property LOC V20 [get_ports DATA3_19]
  # 34 IO_L16P
set_property LOC U19 [get_ports DATA3_20]
  # 34 IO_L12N MRCC

# ??? U30-ACO1 ??? (voltage from data or voltage from power sense?)
# May not even be present.  Need closer look if it is, to get part #.
set_property LOC W20 [get_ports VIN_OK]
  # 34 IO_L16N

# JTAG connector (not GPIO capable)
#set_property LOC F6 [get_ports JTAG_TDO]
  # TDO_0
#set_property LOC F9 [get_ports JTAG_TCK]
  # TCK_0
#set_property LOC G6 [get_ports JTAG_TDI]
  # TDI_0
#set_property LOC J6 [get_ports JTAG_TMS]
  # TMS_0

# XTAL 5 (not present)
#N18  IO_L13P MRCC

#####################
# HDMI breakout board
#####################

# USB Serial, and also ext. UART connector
set_property LOC H16 [get_ports FPGA_RXD]
  # 35 DATA1_6  IO_L13P
set_property LOC H17 [get_ports FPGA_TXD]
  # 35 DATA1_11 IO_L13N
set_property IOSTANDARD LVCMOS33 [get_ports FPGA_RXD]
  # 35 DATA1_6  IO_L13P
set_property IOSTANDARD LVCMOS33 [get_ports FPGA_TXD]
  # 35 DATA1_11 IO_L13N

# KEY1..KEY5 active low
set_property LOC T19 [get_ports KEY[1]]
  # 34 DATA3_18 IO_25
set_property LOC P19 [get_ports KEY[2]]
  # 34 DATA3_15 IO_L13N
set_property LOC U20 [get_ports KEY[3]]
  # 34 DATA3_17 IO_L15N
set_property LOC U19 [get_ports KEY[4]]
  # 34 DATA3_20 IO_L12N
set_property LOC V20 [get_ports KEY[5]]
  # 34 DATA3_19 IO_L16P
# Or, if you hold it so that display is "North":
set_property LOC T19 [get_ports KEY_N]
  # 34 DATA3_18 IO_25
set_property LOC P19 [get_ports KEY_W]
  # 34 DATA3_15 IO_L13N
set_property LOC U20 [get_ports KEY_C]
  # 34 DATA3_17 IO_L15N
set_property LOC U19 [get_ports KEY_S]
  # 34 DATA3_20 IO_L12N
set_property LOC V20 [get_ports KEY_E]
  # 34 DATA3_19 IO_L16P

set_property IOSTANDARD LVCMOS33 [get_ports KEY[1]]
  # 34 DATA3_18 IO_25
set_property IOSTANDARD LVCMOS33 [get_ports KEY[2]]
  # 34 DATA3_15 IO_L13N
set_property IOSTANDARD LVCMOS33 [get_ports KEY[3]]
  # 34 DATA3_17 IO_L15N
set_property IOSTANDARD LVCMOS33 [get_ports KEY[4]]
  # 34 DATA3_20 IO_L12N
set_property IOSTANDARD LVCMOS33 [get_ports KEY[5]]
  # 34 DATA3_19 IO_L16P
set_property IOSTANDARD LVCMOS33 [get_ports KEY_N]
  # 34 DATA3_18 IO_25
set_property IOSTANDARD LVCMOS33 [get_ports KEY_W]
  # 34 DATA3_15 IO_L13N
set_property IOSTANDARD LVCMOS33 [get_ports KEY_C]
  # 34 DATA3_17 IO_L15N
set_property IOSTANDARD LVCMOS33 [get_ports KEY_S]
  # 34 DATA3_20 IO_L12N
set_property IOSTANDARD LVCMOS33 [get_ports KEY_E]
  # 34 DATA3_19 IO_L16P


# LED1-LED3
set_property LOC E19 [get_ports LED[1]]
  # 35 DATA1_18 IO_L5N
set_property LOC K17 [get_ports LED[2]]
  # 35 DATA1_20 IO_L12P
set_property LOC H18 [get_ports LED[3]]
  # 35 DATA1_15 IO_L14N
set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[3]}]

# LCD Connector
# LCD is 1.3" 240x240 IPS130-12?
set_property LOC T20 [get_ports LCD_BL]
  # 34 DATA3_16 IO_L15P
set_property LOC R18 [get_ports LCD_DC]
  # 34 DATA3_13 IO_L20N
set_property LOC N17 [get_ports LCD_RES]
  # 34 DATA3_9  IO_L23P
set_property LOC R19 [get_ports LCD_SCL]
  # 34 DATA3_14 IO_0
set_property LOC P20 [get_ports LCD_SDA]
  # 34 DATA3_11 IO_L14N
set_property IOSTANDARD LVCMOS33 [get_ports LCD_BL]
set_property IOSTANDARD LVCMOS33 [get_ports LCD_DC]
set_property IOSTANDARD LVCMOS33 [get_ports LCD_RES]
set_property IOSTANDARD LVCMOS33 [get_ports LCD_SCL]
set_property IOSTANDARD LVCMOS33 [get_ports LCD_SDA]

# Buzzer
set_property LOC D18 [get_ports BEEP]
  # 35 DATA1_14 IO_L3N
set_property IOSTANDARD LVCMOS33 [get_ports BEEP]
  # 35 DATA1_14 IO_L3N

# HDMI port
# SDA, SCL, CEC not attached
# I wonder if I could wire LCD_SCL/LCD_SDA to SDA/SCL.
set_property LOC F19 [get_ports HDMI_CK_P]
  # 35 DATA1_19 IO_L15P
set_property LOC F20 [get_ports HDMI_CK_N]
  # 35 DATA1_17 IO_L15N
set_property LOC D19 [get_ports HDMI_TX_P[0]]
  # 35 DATA1_16 IO_L4P
set_property LOC D20 [get_ports HDMI_TX_N[0]]
  # 35 DATA1_13 IO_L4N
set_property LOC C20 [get_ports HDMI_TX_P[1]]
  # 35 DATA1_9  IO_L1P
set_property LOC B20 [get_ports HDMI_TX_N[1]]
  # 35 DATA1_8  IO_L1N
set_property LOC B19 [get_ports HDMI_TX_P[2]]
  # 35 DATA1_7  IO_L2P
set_property LOC A20 [get_ports HDMI_TX_N[2]]
  # 35 DATA1_5  IO_L2N
# Repeat of clk for easier array usage
set_property LOC F19 [get_ports HDMI_TX_P[3]]
  # 35 DATA1_19 IO_L15P
set_property LOC F20 [get_ports HDMI_TX_N[3]]
  # 35 DATA1_17 IO_L15N

set_property IOSTANDARD TMDS_33 [get_ports HDMI_CK_P]
set_property IOSTANDARD TMDS_33 [get_ports HDMI_CK_N]
set_property IOSTANDARD TMDS_33 [get_ports HDMI_TX_P[0]]
set_property IOSTANDARD TMDS_33 [get_ports HDMI_TX_N[0]]
set_property IOSTANDARD TMDS_33 [get_ports HDMI_TX_P[1]]
set_property IOSTANDARD TMDS_33 [get_ports HDMI_TX_N[1]]
set_property IOSTANDARD TMDS_33 [get_ports HDMI_TX_P[2]]
set_property IOSTANDARD TMDS_33 [get_ports HDMI_TX_N[2]]
set_property IOSTANDARD TMDS_33 [get_ports HDMI_TX_P[3]]
set_property IOSTANDARD TMDS_33 [get_ports HDMI_TX_N[3]]

# SLEW FAST not supported by TMDS_33, apparently
#set_property SLEW FAST [get_ports HDMI_CK_P]
#set_property SLEW FAST [get_ports HDMI_CK_N]
#set_property SLEW FAST [get_ports HDMI_TX_P[0]]
#set_property SLEW FAST [get_ports HDMI_TX_N[0]]
#set_property SLEW FAST [get_ports HDMI_TX_P[1]]
#set_property SLEW FAST [get_ports HDMI_TX_N[1]]
#set_property SLEW FAST [get_ports HDMI_TX_P[2]]
#set_property SLEW FAST [get_ports HDMI_TX_N[2]]

# .100 header
# H4_01 3.3V
# H4_02 GND
# diff pairs: 03-07 06-08 09-10 11-12 14-13 16-15 18-17
set_property LOC M17 [get_ports H4_03]
  # 35 DATA3_8  IO_L8P  AD10P
set_property LOC P18 [get_ports H4_04]
  # 34 DATA3_7  IO_L23N
set_property LOC N20 [get_ports H4_05]
  # 34 DATA3_6  IO_L14P SRCC
set_property LOC M19 [get_ports H4_06]
  # 35 DATA3_5  IO_L7P  AD2P
set_property LOC M18 [get_ports H4_07]
  # 35 DATA2_17 IO_L8N  AD10N
set_property LOC M20 [get_ports H4_08]
  # 35 DATA2_19 IO_L7N  AD2N
set_property LOC L16 [get_ports H4_09]
  # 35 DATA2_15 IO_L11P SRCC
set_property LOC L17 [get_ports H4_10]
  # 35 DATA2_20 IO_L11N SRCC
set_property LOC L19 [get_ports H4_11]
  # 35 DATA2_16 IO_L9P  AD3P
set_property LOC L20 [get_ports H4_12]
  # 35 DATA2_18 IO_L9N  AD3N
set_property LOC J19 [get_ports H4_13]
  # 35 DATA2_9  IO_L10N AD11N
set_property LOC K19 [get_ports H4_14]
  # 35 DATA2_13 IO_L10P AD11P
set_property LOC H20 [get_ports H4_15]
  # 35 DATA2_8  IO_L17N AD5N
set_property LOC J20 [get_ports H4_16]
  # 35 DATA2_14 IO_L17P AD5P
set_property LOC G20 [get_ports H4_17]
  # 35 DATA2_4  IO_L18N AD13N
set_property LOC G19 [get_ports H4_18]
  # 35 DATA2_7  IO_L18P AD13P
set_property LOC J18 [get_ports H4_19]
  # 35 DATA2_6  IO_L14P AD4P SRCC
set_property LOC K18 [get_ports H4_20]
  # 35 DATA2_11 IO_L12N MRCC
