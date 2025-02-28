// Fade; calculates pwm signals and timing basically

// simple PWM up and down every 200s
// idea: can have third state of not changing
// 1 second / 6 --> 40 ish ms; 66 ms

// start with parameter of where in cycle + timer
// can do a separate case with high and low bundled together (so don't mess with current timer)
   // can have redundancy with pwm values incrementing even while high & low

module fade #(
    parameter INC_DEC_INTERVAL = 12000,     // CLK frequency is 12MHz, so 12,000 cycles is 1ms; new is 10,000 cycles or around 0.833 ms per?
    // Transition to next state after 200 increments / decrements, which is 0.2s; pwm value updated 200 times before changing from incr to decr
    // full cycle takes 400 ms; new cycle takes 200 * 6 --> 1.2 s
    parameter INC_DEC_MAX = 167,            
    parameter PWM_INTERVAL = 1200,          // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX, // increment value; by a small step each update 
    // parameter STARTING_COUNT = 0 // should be overwritten
    parameter STARTING_STATE = 3'b000 // should be overwritten
)(
    input logic clk, 
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value 
);

    // Define state variable values
    localparam PWM_INC = 3'b000;
    localparam PWM_DEC = 3'b001;
    localparam HIGH = 3'b011;
    localparam LOW = 3'b000;
    localparam HIGH_TWO = 3'b111;
    localparam LOW_TWO = 3'b000;

    // Declare state variables
    logic current_state; // current state of FSM; either PWM_INC or PWM_DEC
    logic next_state;

    // Declare variables for timing state transitions
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0;
    logic time_to_transition = 1'b0;

    // TO-DO: MODIFY INITIALIZATION FOR CUSTOM START
        // WILL BE STATE, AND COUNT
        // ex. can start in high state, with inc_dec_count in the middle alr
    initial begin
        // pwm_value = 0;
        // inc_dec_count = STARTING_COUNT;
        current_state = STARTING_STATE;
        case (STARTING_STATE)
            PWM_INC: 
                pwm_value = 0;                  // Start from low brightness
            HIGH: 
                pwm_value = PWM_INTERVAL;          // Start from max brightness
            LOW: 
                pwm_value = 0;                      // Start from low brightness
            HIGH_TWO: 
                pwm_value = PWM_INTERVAL;      // Start from max brightness
            LOW_TWO: 
                pwm_value = 0;   // Start from low
            PWM_DEC: 
                pwm_value = PWM_INTERVAL;   // Start from high, so can go to low
        default: pwm_value = 0;
    endcase
    current_state = STARTING_STATE;
    end

    // Register the next state of the FSM
    // LEAVE AS IS
    always_ff @(posedge time_to_transition) // transitions between PWM_INC and PWM_DEC
        current_state <= next_state;

    // Compute the next state of the FSM
    // TO-DO: CHANGE TO INCLUDE HIGH AND LOW
    always_comb begin
        next_state = 3'bxxx; // may throw error?
        case (current_state)
            PWM_INC:
                next_state = HIGH;
            PWM_DEC:
                next_state = LOW;
            HIGH:
                next_state = HIGH_TWO;
            LOW:
                next_state = LOW_TWO;
            HIGH_TWO:
                next_state = PWM_DEC;
            LOW_TWO:
                next_state = PWM_INC;
        endcase
    end

    // Implement counter for incrementing / decrementing PWM value
    // CAN LEAVE AS IS
    always_ff @(posedge clk) begin
        if (count == INC_DEC_INTERVAL - 1) begin
            count <= 0;
            time_to_inc_dec <= 1'b1;
        end
        else begin
            count <= count + 1;
            time_to_inc_dec <= 1'b0;
        end
    end

    // Increment / Decrement PWM value as appropriate given current state
    // TO-DO: MODIFY TO SET HIGH AND LOW 
    always_ff @(posedge time_to_inc_dec) begin
        // when time_to_inc_dec high, PWM value increases; when low, decreases
        // add two states here: high and low; OR add a separate high level one
        case (current_state)
            PWM_INC:
                pwm_value <= pwm_value + INC_DEC_VAL;
            PWM_DEC:
                pwm_value <= pwm_value - INC_DEC_VAL;
            HIGH:
                pwm_value <= PWM_INTERVAL; // max value
            LOW:
                pwm_value <= 0; 
            HIGH_TWO:
                pwm_value <= PWM_INTERVAL; // max value
            LOW_TWO:
                pwm_value <= 0; 
        endcase
    end

    // Implement counter for timing state transitions; handling transition timing
    // LEAVE AS IS
    always_ff @(posedge time_to_inc_dec) begin
        if (inc_dec_count == INC_DEC_MAX - 1) begin
            inc_dec_count <= 0;
            time_to_transition <= 1'b1;
        end
        else begin
            inc_dec_count <= inc_dec_count + 1;
            time_to_transition <= 1'b0;
        end
    end

endmodule
