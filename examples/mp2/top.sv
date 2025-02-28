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
    parameter PWM_INTERVAL = 1200,   // Sets the PWM period
    parameter INC_DEC_MAX = 200      // Defines the speed of color transitions
)(
    input logic clk,
    output logic RGB_R, 
    output logic RGB_G, 
    output logic RGB_B
);

    // PWM values for each RGB channel
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value_r, pwm_value_g, pwm_value_b;
    logic pwm_out_r, pwm_out_g, pwm_out_b;

    // Color fade state machine
    typedef enum logic [2:0] {
        RED_TO_YELLOW, YELLOW_TO_GREEN, GREEN_TO_CYAN,
        CYAN_TO_BLUE, BLUE_TO_MAGENTA, MAGENTA_TO_RED
    } color_state_t;
    
    color_state_t current_state = RED_TO_YELLOW;
    logic [$clog2(INC_DEC_MAX)-1:0] color_counter = 0;

    // Instantiate fade modules for each color channel
    fade #(.PWM_INTERVAL(PWM_INTERVAL), .INC_DEC_MAX(INC_DEC_MAX)) fade_r (
        .clk(clk), .pwm_value(pwm_value_r)
    );
    
    fade #(.PWM_INTERVAL(PWM_INTERVAL), .INC_DEC_MAX(INC_DEC_MAX)) fade_g (
        .clk(clk), .pwm_value(pwm_value_g)
    );
    
    fade #(.PWM_INTERVAL(PWM_INTERVAL), .INC_DEC_MAX(INC_DEC_MAX)) fade_b (
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

    // State machine to cycle through color transitions
    always_ff @(posedge clk) begin
        if (color_counter == INC_DEC_MAX - 1) begin
            color_counter <= 0;
            case (current_state)
                RED_TO_YELLOW:  current_state <= YELLOW_TO_GREEN;
                YELLOW_TO_GREEN: current_state <= GREEN_TO_CYAN;
                GREEN_TO_CYAN:  current_state <= CYAN_TO_BLUE;
                CYAN_TO_BLUE:   current_state <= BLUE_TO_MAGENTA;
                BLUE_TO_MAGENTA: current_state <= MAGENTA_TO_RED;
                MAGENTA_TO_RED: current_state <= RED_TO_YELLOW;
            endcase
        end
        else begin
            color_counter <= color_counter + 1;
        end
    end

    // Adjust fade behavior based on state
    always_ff @(posedge clk) begin
        case (current_state)
            RED_TO_YELLOW:  begin pwm_value_r <= PWM_INTERVAL; pwm_value_g <= pwm_value_g + 1; pwm_value_b <= 0; end
            YELLOW_TO_GREEN: begin pwm_value_r <= pwm_value_r - 1; pwm_value_g <= PWM_INTERVAL; pwm_value_b <= 0; end
            GREEN_TO_CYAN:  begin pwm_value_r <= 0; pwm_value_g <= PWM_INTERVAL; pwm_value_b <= pwm_value_b + 1; end
            CYAN_TO_BLUE:   begin pwm_value_r <= 0; pwm_value_g <= pwm_value_g - 1; pwm_value_b <= PWM_INTERVAL; end
            BLUE_TO_MAGENTA: begin pwm_value_r <= pwm_value_r + 1; pwm_value_g <= 0; pwm_value_b <= PWM_INTERVAL; end
            MAGENTA_TO_RED: begin pwm_value_r <= PWM_INTERVAL; pwm_value_g <= 0; pwm_value_b <= pwm_value_b - 1; end
        endcase
    end

    // Assign outputs (inverted because LEDs are active-low)
    assign RGB_R = ~pwm_out_r;
    assign RGB_G = ~pwm_out_g;
    assign RGB_B = ~pwm_out_b;

endmodule
