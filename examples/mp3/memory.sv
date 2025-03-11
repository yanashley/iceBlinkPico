// Sample memory module

module memory #(
    parameter INIT_FILE = ""
)(
    input logic     clk,
    input logic     [7:0] read_address,
    input logic     [1:0] read_state,
    output logic    [9:0] read_data
);
    localparam PEAK = 2'b00;
    localparam FALL = 2'b01;
    localparam TROUGH = 2'b10;
    localparam RISE = 2'b11;

    // Declare memory array for storing 512 10-bit samples of a sine function
    // --> memory array for storing 128 9-bit samples of a sine function
    logic [8:0] sample_memory [0:127];

    initial if (INIT_FILE) begin
        $readmemh(INIT_FILE, sample_memory);
    end

    always_ff @(posedge clk) begin
        // if statements depending on state
        case (read_state)
            PEAK: read_data <= sample_memory[read_address];
            FALL: read_data <= 512 - sample_memory[read_address];
            TROUGH: read_data <= 0 - sample_memory[read_address];
            RISE: read_data <= sample_memory[read_address] - 512;
        endcase


        
    end

endmodule
