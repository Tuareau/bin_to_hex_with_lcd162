`timescale 1ns / 1ps

module main_tb();

    // bin_to_hex_converter outputs
    wire data_wr, show_on_disp;
    wire [5:0] idx;
    wire [7:0] data;
    wire [7:0] cursor_addr;
    
    // inputs
    reg clk_reg = 0;
    reg e_sw_on_reg = 0, s_sw_on_reg = 0, w_sw_on_reg = 0, n_sw_on_reg = 0;
    wire clk;
    wire e_sw_on, s_sw_on, w_sw_on, n_sw_on;
    assign clk = clk_reg;
    assign e_sw_on = e_sw_on_reg, s_sw_on = s_sw_on_reg, 
        w_sw_on = w_sw_on_reg, n_sw_on = n_sw_on_reg;
        
    // lcd162st_alternative outputs
    wire [3:0] LCD_DB_LS;
    wire LCD_E_LS, LCD_RW_LS, LCD_RS_LS, bf;
    
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
    
    always #2.5 clk_reg <= ~clk_reg;
    
    reg [31:0] timer = 0;
    
    always @(posedge clk) 
        timer <= (timer == 1_000_000) ? 0 : timer + 1; 
    
    always @(posedge clk) 
    begin
        case (timer)
        0: e_sw_on_reg <= 1;
        1: e_sw_on_reg <= 0;
        500_000: n_sw_on_reg <= 1;
        500_001: n_sw_on_reg <= 0;
        endcase
    end

endmodule
