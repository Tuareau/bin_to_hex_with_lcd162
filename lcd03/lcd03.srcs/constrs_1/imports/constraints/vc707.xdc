################################################################################
# VC707 Constraints File
# Sorted (except for FMC, fuck FMC) and human readable
# Author: Mitchell Gu
################################################################################

################################################################################
# CLOCKS
################################################################################

# SYSCLK 200MHz
set_property PACKAGE_PIN E19 [get_ports SYSCLK_P]
set_property IOSTANDARD LVDS [get_ports SYSCLK_P]
set_property PACKAGE_PIN E18 [get_ports SYSCLK_N]
set_property IOSTANDARD LVDS [get_ports SYSCLK_N]

# Pushbuttons
set_property PACKAGE_PIN AR40 [get_ports GPIO_SW_N]
set_property IOSTANDARD LVCMOS18 [get_ports GPIO_SW_N]
set_property PACKAGE_PIN AU38 [get_ports GPIO_SW_E]
set_property IOSTANDARD LVCMOS18 [get_ports GPIO_SW_E]
set_property PACKAGE_PIN AP40 [get_ports GPIO_SW_S]
set_property IOSTANDARD LVCMOS18 [get_ports GPIO_SW_S]
set_property PACKAGE_PIN AW40 [get_ports GPIO_SW_W]
set_property IOSTANDARD LVCMOS18 [get_ports GPIO_SW_W]

################################################################################
# LCD Display (2x15 5x8 Dot display) (DisplayTech 162D) (ST7066U Driver)
################################################################################

set_property PACKAGE_PIN AT42 [get_ports LCD_DB_LS[0]]
set_property IOSTANDARD LVCMOS18 [get_ports LCD_DB_LS[0]]
set_property PACKAGE_PIN AR38 [get_ports LCD_DB_LS[1]]
set_property IOSTANDARD LVCMOS18 [get_ports LCD_DB_LS[1]]
set_property PACKAGE_PIN AR39 [get_ports LCD_DB_LS[2]]
set_property IOSTANDARD LVCMOS18 [get_ports LCD_DB_LS[2]]
set_property PACKAGE_PIN AN40 [get_ports LCD_DB_LS[3]]
set_property IOSTANDARD LVCMOS18 [get_ports LCD_DB_LS[3]]
set_property PACKAGE_PIN AN41 [get_ports LCD_RS_LS]
set_property IOSTANDARD LVCMOS18 [get_ports LCD_RS_LS]
set_property PACKAGE_PIN AR42 [get_ports LCD_RW_LS]
set_property IOSTANDARD LVCMOS18 [get_ports LCD_RW_LS]
set_property PACKAGE_PIN AT40 [get_ports LCD_E_LS]
set_property IOSTANDARD LVCMOS18 [get_ports LCD_E_LS]
