`include "memory.sv"

// Sine top-level module

module top(
    input logic     clk, 
    output logic    _9b,    // D0
    output logic    _6a,    // D1
    output logic    _4a,    // D2
    output logic    _2a,    // D3
    output logic    _0a,    // D4
    output logic    _5a,    // D5
    output logic    _3b,    // D6
    output logic    _49a,   // D7
    output logic    _45a,   // D8
    output logic    _48b    // D9
);
    localparam PEAK = 2'b00;
    localparam FALL = 2'b01;
    localparam TROUGH = 2'b10;
    localparam RISE = 2'b11;
    logic [1:0] current_state = PEAK;

    logic [8:0] count = 0;
    logic [6:0] address = 0;
    logic [9:0] data;

    memory #(
        .INIT_FILE      ("sine.txt")
    ) u1 (
        .clk            (clk), 
        .read_address   (address), 
        .read_state     (current_state),
        .read_data      (data)
    );

    always_ff @(posedge clk) begin
        if (count < 128) begin
            current_state = PEAK;
        end
        else if (count < 256) begin
            current_state = FALL;
        end
        else if (count < 384) begin
            current_state = TROUGH;
        end
        else begin
            current_state = RISE;
        end

        count <= count + 1;
        address <= address + 1;
        
    end

    // thought is to keep this the same, since 0 should automatically allocate
    assign {_48b, _45a, _49a, _3b, _5a, _0a, _2a, _4a, _6a, _9b} = data;

endmodule
