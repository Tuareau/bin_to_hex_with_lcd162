`timescale 1ns / 1ps

module lcd_162st_alternative(    
    input wire clk,
    input wire [5:0] addr,
    input wire [7:0] data,
    input wire data_wr,
    input wire show_on_disp, 
    input wire [7:0] cursor_addr,
    
    output reg [3:0] DB = 0,
    output reg E = 0, 
    output reg RS = 0,
    output reg RW = 0,
    output reg BF = 1
);
   
parameter cycles_per_us  = 200;
parameter wait_power_on  = 16000 * cycles_per_us; // 15ms

parameter E_wait_d = 200 * cycles_per_us;
parameter E_wait = 100 * cycles_per_us;
parameter E_wait_h = 50 * cycles_per_us;

reg [7:0] LCD_DATA [31:0];
reg [7:0] LCD_byte_tx = 0;

always @(posedge clk)
begin
    if (data_wr)
        LCD_DATA[addr] <= data;
end

reg [35:0] timer = 0;  
reg [35:0] E_timer = 100_000_000;

reg E_en = 0;
reg E_en0 = 0;
reg bit4 = 0;
    
reg [7:0] ST = 0;

parameter S_START = 0;
parameter S_INIT1 = 1;
parameter S_INIT2 = 2;
parameter S_INIT3 = 3;
parameter S_INIT4 = 4;
parameter S_SET_PAR = 5;
parameter S_DISP_OFF = 6;
parameter S_DISP_CLR = 7;
parameter S_SET_ENTRY_MODE = 8;
parameter S_DISP_ON = 9;

parameter S_SET_STR1 = 10;
parameter S_WRITE1 = 11;
parameter S_SET_STR2 = 12;
parameter S_WRITE2 = 13;
parameter S_SET_CURSOR = 14;
parameter S_WAIT_DATA = 15;

reg [7:0] wait_timer = 0;
reg [7:0] D_full = 0;

initial
begin
    LCD_DATA[0] <= "0";
    LCD_DATA[1] <= "0";
    LCD_DATA[2] <= "0";
    LCD_DATA[3] <= "0";

    LCD_DATA[4] <= "0";
    LCD_DATA[5] <= "0";
    LCD_DATA[6] <= "0";
    LCD_DATA[7] <= "0";
    
    LCD_DATA[8] <= " ";
    LCD_DATA[9] <= " ";
    LCD_DATA[10] <= " ";
    LCD_DATA[11] <= " ";

    LCD_DATA[12] <= " ";
    LCD_DATA[13] <= " ";
    LCD_DATA[14] <= " ";
    LCD_DATA[15] <= " ";

    LCD_DATA[16] <= "0";
    LCD_DATA[17] <= "x";
    LCD_DATA[18] <= "0";
    LCD_DATA[19] <= "0";

    LCD_DATA[20] <= " ";
    LCD_DATA[21] <= " ";
    LCD_DATA[22] <= " ";
    LCD_DATA[23] <= " ";
    
    LCD_DATA[24] <= " ";
    LCD_DATA[25] <= " ";
    LCD_DATA[26] <= " ";
    LCD_DATA[27] <= " ";

    LCD_DATA[28] <= " ";
    LCD_DATA[29] <= " ";
    LCD_DATA[30] <= " ";
    LCD_DATA[31] <= " ";  
end

always @(posedge clk)
begin
    case (ST)
            S_START:
                begin
                    if (timer > wait_power_on)
                    begin
                        timer <= 0;
                        ST <= S_INIT1;
                    end
                    else
                        timer <= timer + 1;
                end
                
            S_INIT1:
                begin
                    if (timer < E_wait_h)
                    begin
                        bit4 <= 1;
                        E_en <= 1;
                        D_full <= 8'b0000_0011;
                        RS <= 0;
                        RW <= 0;
                        timer <= timer + 1;
                    end
                    else
                    begin
                        E_en <= 0;
                        if (timer == (E_wait*10))
                        begin
                            timer <= 0;
                            ST <= S_INIT2;
                        end
                        else
                            timer <= timer + 1;
                    end
                end
                
            S_INIT2:
                begin
                    if (timer < E_wait_h)
                    begin
                        bit4 <= 1;
                        E_en <= 1;
                        D_full <= 8'b0000_0011;
                        RS <= 0;
                        RW <= 0;
                        timer <= timer + 1;
                    end
                    else
                    begin
                        E_en <= 0;
                        if (timer == (E_wait*10))
                        begin
                            timer <= 0;
                            ST <= S_INIT3;
                        end
                        else
                            timer <= timer + 1;
                    end
                end
                
            S_INIT3:
                begin
                    if (timer < E_wait_h)
                    begin
                        bit4 <= 1;
                        E_en <= 1;
                        D_full <= 8'b0000_0011;
                        RS <= 0;
                        RW <= 0;
                        timer <= timer + 1;
                    end
                    else
                    begin
                        E_en <= 0;
                        if (timer == (E_wait*10))
                        begin
                            timer <= 0;
                            ST <= S_INIT4;
                        end
                        else
                            timer <= timer + 1;
                    end
                end
                
            S_INIT4:
                begin
                    if (timer < E_wait_h)
                    begin
                        bit4 <= 1;
                        E_en <= 1;
                        D_full <= 8'b0000_0010;
                        RS <= 0;
                        RW <= 0;
                        timer <= timer + 1;
                    end
                    else
                    begin
                        E_en <= 0;
                        if (timer == (E_wait*10))
                        begin
                            timer <= 0;
                            ST <= S_SET_PAR;
                        end
                        else
                            timer <= timer + 1;
                    end
                end
                
            S_SET_PAR:
                begin
                    if (timer < E_wait)
                    begin
                        bit4 <= 0;
                        E_en <= 1;
                        D_full <= 8'b0010_1100;//set 4bit interface, 2 lines and 5*10 dots
                        RS <= 0;
                        RW <= 0;
                        timer <= timer + 1;
                    end
                    else
                    begin
                        E_en <= 0;
                        if (timer == (E_wait_d*10))
                        begin
                            timer <= 0;
                            ST <= S_DISP_OFF;
                        end
                        else
                            timer <= timer + 1;
                    end
                end
                
            S_DISP_OFF:
                begin
                    if (timer < E_wait)
                    begin
                        bit4 <= 0;
                        E_en <= 1;
                        D_full <= 8'b0000_1000;// display off
                        RS <= 0;
                        RW <= 0;
                        timer <= timer + 1;
                    end
                    else
                    begin
                        E_en <= 0;
                        if (timer == (E_wait_d*10))
                        begin
                            timer <= 0;
                            ST <= S_DISP_CLR;
                        end
                        else
                            timer <= timer + 1;
                    end
                end
                
            S_DISP_CLR:
                begin
                    if (timer < E_wait)
                    begin
                        bit4 <= 0;
                        E_en <= 1;
                        D_full <= 8'b00000001;// display clear
                        RS <= 0;
                        RW <= 0;
                        timer <= timer + 1;
                    end
                    else
                    begin
                        E_en <= 0;
                        if (timer == (E_wait_d*10))
                        begin
                            timer <= 0;
                            ST <= S_SET_ENTRY_MODE;
                        end
                        else
                            timer <= timer + 1;
                    end
                end
                
            S_SET_ENTRY_MODE:
                begin
                    if (timer < E_wait)
                    begin
                        bit4 <= 0;
                        E_en <= 1;
                        D_full <= 8'b0000_0110;// set entry mode: cursor increase, display not shifted
                        RS <= 0;
                        RW <= 0;
                        timer <= timer + 1;
                    end
                    else
                    begin
                        E_en <= 0;
                        if (timer == (E_wait_d*10))
                        begin
                            timer <= 0;
                            ST <= S_DISP_ON;
                        end
                        else
                            timer <= timer + 1;
                    end
                end
                
            S_DISP_ON:
                begin
                    if (timer < E_wait)
                    begin
                        bit4 <= 0;
                        E_en <= 1;
                        D_full <= 8'b00001110;//Display: disp on, cursor on, blink off
                        RS <= 0;
                        RW <= 0;
                        timer <= timer + 1;
                    end
                    else
                    begin
                        E_en <= 0;
                        if (timer == (E_wait_d*10))
                        begin
                            timer <= 0;
                            ST <= S_SET_STR1;
                            BF <= 1;
                        end
                        else
                            timer <= timer + 1;
                    end
                end
                
            S_SET_STR1:
                    begin                        
                        if (timer < E_wait)
                        begin
                            bit4 <= 0;
                            E_en <= 1;
                            D_full <= 8'b10000000;//1 str
                            RS <= 0;
                            RW <= 0;
                            timer <= timer + 1;
                        end
                        else
                        begin
                            E_en <= 0;
                            if (timer == (E_wait_d*10))
                            begin
                                timer <= 0;
                                ST <= S_WRITE1;
                            end
                            else
                                timer <= timer + 1;
                        end
                    end                
                
            S_WRITE1:
                begin
                    if (timer < E_wait)
                    begin
                        bit4 <= 0;
                        E_en <= 1;
                        D_full <= LCD_DATA[LCD_byte_tx];
                        RS <= 1;
                        RW <= 0;
                        timer <= timer + 1;
                    end
                    else
                    begin
                        E_en <= 0;
                        if (timer == (E_wait_d*10))
                        begin
                            timer <= 0;
                            if (LCD_byte_tx == 15)
                            begin
                                ST <= S_SET_STR2;
                                LCD_byte_tx <= LCD_byte_tx + 1;
                            end
                            else
                            begin
                                LCD_byte_tx <= LCD_byte_tx + 1;
                            end
                        end
                        else
                            timer <= timer + 1;
                    end
                end
                
            S_SET_STR2:
                begin
                    if (timer < E_wait)
                    begin
                        bit4 <= 0;
                        E_en <= 1;
                        D_full <= 8'b11000000;//2 str
                        RS <= 0;
                        RW <= 0;
                        timer <= timer + 1;
                    end
                    else
                    begin
                        E_en <= 0;
                        if (timer == (E_wait_d*10))
                        begin
                            timer <= 0;
                            ST <= S_WRITE2;
                        end
                        else
                            timer <= timer + 1;
                    end
                end              
                
            S_WRITE2:
                begin
                    if (timer < E_wait)
                    begin
                        bit4 <= 0;
                        E_en <= 1;
                        D_full <= LCD_DATA[LCD_byte_tx];
                        RS <= 1;
                        RW <= 0;
                        timer <= timer + 1;
                    end
                    else
                    begin
                        E_en <= 0;
                        if (timer == (E_wait_d*10))
                        begin
                            timer <= 0;
                            if (LCD_byte_tx == 31)
                            begin
                                ST <= S_SET_CURSOR;
                                LCD_byte_tx <= LCD_byte_tx + 1;
                            end
                            else
                            begin
                                LCD_byte_tx <= LCD_byte_tx + 1;
                            end
                        end
                        else
                            timer <= timer + 1;
                    end
                end
                
            S_SET_CURSOR:
                begin
                if (timer < E_wait)
                begin
                    bit4 <= 0;
                    E_en <= 1;
                    D_full <= cursor_addr;// cursor position
                    RS <= 0;
                    RW <= 0;
                    timer <= timer + 1;
                end
                else
                begin
                    E_en <= 0;
                    if (timer == (E_wait_d*10))
                    begin
                        timer <= 0;
                        BF <= 0;
                        ST <= S_WAIT_DATA;
                    end
                    else
                        timer <= timer + 1;
                end
            end            
                
            S_WAIT_DATA:
                begin
                    timer <= 0;
                    LCD_byte_tx <= 0;
                    if (show_on_disp) begin
                        ST <= S_SET_STR1;
                        BF <= 1;
                    end
                end
             
    endcase
end
    
    
//Generate E signal
//Set "bit4" to generate 4 bit data only
//reset E_en to start generate    
always @(posedge clk)
begin
    E_en0 <= E_en;
    if ((E_en == 1) && (E_en0 == 0))
    begin
        if (bit4 == 1)
        begin
            E_timer <= 50 * cycles_per_us;
        end
        else
        begin
            E_timer <= 0;
        end
    end
    else
    begin
        if (E_timer <= 100 * cycles_per_us) //100 us
        begin
            case (E_timer)
            1 * cycles_per_us: DB <= D_full[7:4];
            10 * cycles_per_us: E <= 1;
            40 * cycles_per_us: E <= 0;
            51 * cycles_per_us: DB <= D_full[3:0];
            60 * cycles_per_us: E <= 1;
            90 * cycles_per_us: E <= 0;
            endcase
            E_timer <= E_timer + 1;
        end
    end
end 

endmodule
