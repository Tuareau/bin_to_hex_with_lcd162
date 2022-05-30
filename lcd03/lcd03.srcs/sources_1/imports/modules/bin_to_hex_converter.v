`timescale 1ns / 1ps

module bin_to_hex_converter(
        input wire CLK,
        input wire BF,
        input wire GPIO_SW_W_ON,
        input wire GPIO_SW_N_ON,
        input wire GPIO_SW_E_ON,
        input wire GPIO_SW_S_ON,
        
        output reg [5:0] IDX = 0,
        output reg [7:0] DATA = 0, // char 0
        output reg DATA_WR = 0,
        output reg SHOW_ON_DISP = 0,
        output reg [7:0] CURSOR_ADDR = 8'b1000_0000
    );
    
    parameter [7:0] A = 8'b01000001;
    parameter [7:0] B = 8'b01000010;
    parameter [7:0] C = 8'b01000011;
    parameter [7:0] D = 8'b01000100;
    parameter [7:0] E = 8'b01000101;
    parameter [7:0] F = 8'b01000110;
    parameter [7:0] x = 8'b01111000;
    
    parameter [7:0] CH0 = 8'b00110000;
    parameter [7:0] CH1 = 8'b00110001;
    parameter [7:0] CH2 = 8'b00110010;
    parameter [7:0] CH3 = 8'b00110011;
    parameter [7:0] CH4 = 8'b00110100;
    parameter [7:0] CH5 = 8'b00110101;
    parameter [7:0] CH6 = 8'b00110110;
    parameter [7:0] CH7 = 8'b00110111;
    parameter [7:0] CH8 = 8'b00111000;
    parameter [7:0] CH9 = 8'b00111001;
    
    parameter [7:0] LEFT = 8'b1000_0000;
    parameter [7:0] RIGHT = 8'b0000_0001;
    
    parameter [7:0] LINE2_POS3_IDX = 8'b0001_0010; 
    parameter [7:0] LINE2_POS4_IDX = 8'b0001_0011;     
    
    reg [7:0] LINE = 8'b0000_0000;
    reg [7:0] CURSOR = 8'b1000_0000;
        
    reg [1:0] WR_STAGE = 0;
    reg LINE_CHANGED = 0;
    reg CURSOR_CHANGED = 0;
    reg [5:0] IDX_SAVED = 0;   
    
    reg [23:0] timer = 0;
        
    always @(posedge CLK)
    begin    

        // change lines
        if (LINE_CHANGED) begin
            case (WR_STAGE)
            2'b00: begin                      
                if (timer == 5000) begin
                    WR_STAGE <= WR_STAGE + 1;
                    timer <= 0;
                    DATA_WR <= 0;
                end
                else timer <= timer + 1;   
            end                              
            2'b01: begin  // set line2 address
                if (IDX < 4) begin // left tetrade
                    IDX <= LINE2_POS3_IDX;
                    case (LINE[7:4])
                    4'b0000: DATA <= CH0;
                    4'b0001: DATA <= CH1;
                    4'b0010: DATA <= CH2;
                    4'b0011: DATA <= CH3;
                    4'b0100: DATA <= CH4;
                    4'b0101: DATA <= CH5;
                    4'b0110: DATA <= CH6;
                    4'b0111: DATA <= CH7;
                    4'b1000: DATA <= CH8;
                    4'b1001: DATA <= CH9;
                    4'b1010: DATA <= A;
                    4'b1011: DATA <= B;
                    4'b1100: DATA <= C;
                    4'b1101: DATA <= D;
                    4'b1110: DATA <= E;
                    4'b1111: DATA <= F;                      
                    endcase
                end
                else begin // right tetrade
                    IDX <= LINE2_POS4_IDX;
                    case (LINE[3:0])
                    4'b0000: DATA <= CH0;
                    4'b0001: DATA <= CH1;
                    4'b0010: DATA <= CH2;
                    4'b0011: DATA <= CH3;
                    4'b0100: DATA <= CH4;
                    4'b0101: DATA <= CH5;
                    4'b0110: DATA <= CH6;
                    4'b0111: DATA <= CH7;
                    4'b1000: DATA <= CH8;
                    4'b1001: DATA <= CH9;
                    4'b1010: DATA <= A;
                    4'b1011: DATA <= B;
                    4'b1100: DATA <= C;
                    4'b1101: DATA <= D;
                    4'b1110: DATA <= E;
                    4'b1111: DATA <= F;                    
                    endcase
                end        
                DATA_WR <= 1;
                WR_STAGE <= WR_STAGE + 1;
            end                
            2'b10: begin  // wait till line2 is set
                if (timer == 5000) begin
                    WR_STAGE <= WR_STAGE + 1;
                    timer <= 0;
                    IDX <= IDX_SAVED;                            
                    DATA_WR <= 0;    
                    SHOW_ON_DISP <= 1;                                            
                end
                else timer <= timer + 1;  
            end     
            2'b11: begin  // return IDX to line 2                   
                 if (timer == 5000) begin                    
                     timer <= 0;                                
                     SHOW_ON_DISP <= 0;                                            
                 end
                 else timer <= timer + 1;  
                 if (!SHOW_ON_DISP && !BF) begin
                    WR_STAGE <= 0;
                    LINE_CHANGED <= 0; 
                 end
            end                            
            endcase
        end  
        
        
        else if (CURSOR_CHANGED) begin
            case (WR_STAGE)
            2'b00: begin                                                               
                 SHOW_ON_DISP <= 1;   
                 WR_STAGE <= WR_STAGE + 1;                                          
            end                                 
            2'b01: begin                 
                 if (timer == 5000) begin                    
                     timer <= 0;                                
                     SHOW_ON_DISP <= 0;                                            
                 end
                 else timer <= timer + 1;  
                 if (!SHOW_ON_DISP && !BF) begin
                    WR_STAGE <= 0;
                    CURSOR_CHANGED <= 0; 
                 end
            end                            
            endcase                        
        end
            
        // cursor shifted left
        else if (GPIO_SW_W_ON && (CURSOR != LEFT) && !BF) begin
            CURSOR <= { CURSOR[6:0], 1'b0 };
            CURSOR_ADDR <= CURSOR_ADDR - 1;
            IDX <= IDX - 1;
            CURSOR_CHANGED <= 1;
        end
        // cursor shifted right
        else if (GPIO_SW_E_ON && (CURSOR != RIGHT) && !BF) begin
            CURSOR <= { 1'b0, CURSOR[7:1] };
            CURSOR_ADDR <= CURSOR_ADDR + 1;
            IDX <= IDX + 1;    
            CURSOR_CHANGED <= 1;                     
        end          
          
        // change lines 
        else if (GPIO_SW_N_ON && !BF) begin
            LINE <= LINE | CURSOR;
            DATA <= CH1;
            LINE_CHANGED <= 1;
            IDX_SAVED <= IDX;
            DATA_WR <= 1;
        end
        else if (GPIO_SW_S_ON && !BF) begin
            LINE <= LINE & ~CURSOR;
            DATA <= CH0;
            LINE_CHANGED <= 1;
            IDX_SAVED <= IDX;
            DATA_WR <= 1;
        end                              
    end 
    
endmodule
