`timescale 1ns / 1ps

module clk_generator(
    input SYSCLK_P,
    input SYSCLK_N,
    output clk
    );
    
   // IBUFDS: Differential Input Buffer 
    IBUFDS #(
       .DIFF_TERM("FALSE"),       // Differential Termination
       .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
       .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
    ) CLK_BUFFER (
       .O(clk),  // Buffer output
       .I(SYSCLK_P),  // Diff_p buffer input (connect directly to top-level port)
       .IB(SYSCLK_N) // Diff_n buffer input (connect directly to top-level port)
    );
    
endmodule
