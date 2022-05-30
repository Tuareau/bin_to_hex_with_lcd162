`timescale 1ns / 1ps

module switch_controller(
    input clk,
    input switch,
    output switched
);

    reg [19:0] timer = 20'b0;
    reg buffer = 1'b0;
    
    always @(posedge clk) begin
        buffer <= 1'b0;
        if (switch) begin
            if (timer <= 20'd1_000_000)
                timer <= timer + 1'b1;
        end
        else begin
            if (timer > 20'd1_000_000)
                buffer <= 1'b1;
            timer <= 20'b0;
        end
    end
    
    assign switched = buffer;

endmodule
