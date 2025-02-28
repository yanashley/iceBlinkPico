`include "fade.sv"
`include "pwm.sv"

// Fade top level module

// draft 1: RGB LEDs up and down
// missing:
//   - third state of high and low stable
//   - offset fading
//   - doing the cycle within 1 second

// options: 
//   - modify fade so that it starts off at a certain point (mid of high state, low, incr, etc.)
//   - top level logic can assign?

// should modify to include 3 parts of RGB LEDs

module top #(
    parameter PWM_INTERVAL = 1200   // Sets the PWM period
    // parameter INC_DEC_MAX = 200      // Defines the speed of color transitions
)(
    input logic clk,
    output logic RGB_R,
    output logic RGB_G, 
    output logic RGB_B
);
    // Define state variable values
    localparam PWM_INC = 3'b000;
    localparam PWM_DEC = 3'b001;
    localparam HIGH = 3'b011;
    localparam LOW = 3'b000;
    localparam HIGH_TWO = 3'b111;
    localparam LOW_TWO = 3'b000;

    // PWM values for each RGB channel
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value_r, pwm_value_g, pwm_value_b;
    logic pwm_out_r, pwm_out_g, pwm_out_b;

    // Instantiate fade modules for each color channel
    fade #(.PWM_INTERVAL(PWM_INTERVAL), .STARTING_STATE(HIGH_TWO)) fade_r (
        .clk(clk), .pwm_value(pwm_value_r)
    );
    
    fade #(.PWM_INTERVAL(PWM_INTERVAL), .STARTING_STATE(PWM_INC)) fade_g (
        .clk(clk), .pwm_value(pwm_value_g)
    );
    
    fade #(.PWM_INTERVAL(PWM_INTERVAL), .STARTING_STATE(LOW)) fade_b (
        .clk(clk), .pwm_value(pwm_value_b)
    );

    // Instantiate PWM modules for each color channel
    pwm #(.PWM_INTERVAL(PWM_INTERVAL)) pwm_r (
        .clk(clk), .pwm_value(pwm_value_r), .pwm_out(pwm_out_r)
    );

    pwm #(.PWM_INTERVAL(PWM_INTERVAL)) pwm_g (
        .clk(clk), .pwm_value(pwm_value_g), .pwm_out(pwm_out_g)
    );

    pwm #(.PWM_INTERVAL(PWM_INTERVAL)) pwm_b (
        .clk(clk), .pwm_value(pwm_value_b), .pwm_out(pwm_out_b)
    );

    // Assign outputs (inverted because LEDs are active-low)
    assign RGB_R = ~pwm_out_r;
    assign RGB_G = ~pwm_out_g;
    assign RGB_B = ~pwm_out_b;

endmodule
