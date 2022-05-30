`timescale 1ns / 1ps

module main(
    input        SYSCLK_P,
    input        SYSCLK_N,
    input        GPIO_SW_W,
    input        GPIO_SW_N,
    input        GPIO_SW_E,
    input        GPIO_SW_S,
    
    output       LCD_RS_LS,
    output       LCD_RW_LS,
    output       LCD_E_LS,
    output [3:0] LCD_DB_LS    
    );
    
    wire clk;
    clk_generator clk_gen(SYSCLK_P, SYSCLK_N, clk);
    
    wire n_sw_on, e_sw_on, s_sw_on, w_sw_on;
    switch_controller nswc(clk, GPIO_SW_N, n_sw_on);
    switch_controller eswc(clk, GPIO_SW_E, e_sw_on);
    switch_controller sswc(clk, GPIO_SW_S, s_sw_on);
    switch_controller wswc(clk, GPIO_SW_W, w_sw_on);
    
    wire [5:0] idx;
    wire [7:0] data;
    wire data_wr, show_on_disp, bf;
    wire [7:0] cursor_addr;    
    
    lcd_162st_alternative lcdc(
        .clk(clk),
        .addr(idx),
        .data(data),
        .data_wr(data_wr),
        .show_on_disp(show_on_disp),
        .cursor_addr(cursor_addr),
        
        .DB(LCD_DB_LS),
        .E(LCD_E_LS),
        .RS(LCD_RS_LS),
        .RW(LCD_RW_LS),
        .BF(bf)
    );
    
    bin_to_hex_converter btoh(
        .CLK(clk),
        .BF(bf),
        .GPIO_SW_W_ON(w_sw_on),
        .GPIO_SW_N_ON(n_sw_on),
        .GPIO_SW_E_ON(e_sw_on),
        .GPIO_SW_S_ON(s_sw_on),
        
        .IDX(idx),
        .DATA(data),
        .DATA_WR(data_wr),
        .SHOW_ON_DISP(show_on_disp),
        .CURSOR_ADDR(cursor_addr)        
    ); 
    
endmodule
