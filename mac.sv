module mac (
        i_nrst,
        i_clk,
        i_a0,
        i_a1,
        i_a2,
        i_a3,
        i_a4,
        i_a5,
        i_a6,
        i_a7, 
        i_b0,
        i_b1,
        i_b2,
        i_b3,
        i_b4,
        i_b5,
        i_b6,
        i_b7,
        o_res
    );

    input                      i_nrst;
    input                      i_clk;
    input  logic signed  [7:0] i_a0, i_a1, i_a2, i_a3, i_a4, i_a5, i_a6, i_a7; // Input group A
    input  logic signed  [7:0] i_b0, i_b1, i_b2, i_b3, i_b4, i_b5, i_b6, i_b7; // Input group B
    output logic signed [18:0] o_res;                                          // Output Result

    logic signed [15:0] mul2add_wire_0, mul2add_wire_1, mul2add_wire_2, mul2add_wire_3, mul2add_wire_4, mul2add_wire_5, mul2add_wire_6, mul2add_wire_7;
    logic signed [18:0] o_sum;

    multiplier_array mult_array
        (
            .i_nrst(i_nrst),
            .i_clk(i_clk),
            .i_a0(i_a0),
            .i_a1(i_a1),
            .i_a2(i_a2),
            .i_a3(i_a3),
            .i_a4(i_a4),
            .i_a5(i_a5),
            .i_a6(i_a6),
            .i_a7(i_a7), 
            .i_b0(i_b0),
            .i_b1(i_b1),
            .i_b2(i_b2),
            .i_b3(i_b3),
            .i_b4(i_b4),
            .i_b5(i_b5),
            .i_b6(i_b6),
            .i_b7(i_b7),
            .o_0(mul2add_wire_0),
            .o_1(mul2add_wire_1),
            .o_2(mul2add_wire_2),
            .o_3(mul2add_wire_3),
            .o_4(mul2add_wire_4),
            .o_5(mul2add_wire_5),
            .o_6(mul2add_wire_6),
            .o_7(mul2add_wire_7)
        );

    adder_tree adder_tree
        (
            .i_nrst(i_nrst),
            .i_clk(i_clk),
            .i_0(mul2add_wire_0),
            .i_1(mul2add_wire_1),
            .i_2(mul2add_wire_2),
            .i_3(mul2add_wire_3),
            .i_4(mul2add_wire_4),
            .i_5(mul2add_wire_5),
            .i_6(mul2add_wire_6),
            .i_7(mul2add_wire_7),
            .o_sum(o_sum)
        ); 
    
    assign o_res = o_sum;

endmodule

// Adder Tree Module Definition
module adder_tree (
        i_nrst,
        i_clk,
        i_0,
        i_1,
        i_2,
        i_3,
        i_4,
        i_5,
        i_6,
        i_7,
        o_sum
    );

    input                      i_nrst;
    input                      i_clk;
    input  logic signed [15:0] i_0, i_1, i_2, i_3, i_4, i_5, i_6, i_7;
    output logic signed [18:0] o_sum;

    // Wires for propagation of results
    logic signed [16:0] sum_stage_0_0, sum_stage_0_1, sum_stage_0_2, sum_stage_0_3; // Sums of Stage 0
    logic signed [17:0] sum_stage_1_0, sum_stage_1_1;                               // Sums of Stage 1
    logic signed [17:0] sum_stage_2_0;                                              // Sums of Stage 2

    // Intermediate Registers
    logic signed [16:0] sum_stage_0_0_reg, sum_stage_0_1_reg, sum_stage_0_2_reg, sum_stage_0_3_reg; // Sums of Stage 0
    logic signed [17:0] sum_stage_2_0_reg; // Sums of Stage 2 
    
    // Stage 0
    adder #(.BITWIDTH(16)) add_stage_0_0
        (
            .i_a(i_0),
            .i_b(i_1),
            .o_sum(sum_stage_0_0)
        ); 

    adder #(.BITWIDTH(16)) add_stage_0_1
        (
            .i_a(i_2),
            .i_b(i_3),
            .o_sum(sum_stage_0_1)
        ); 

    adder #(.BITWIDTH(16)) add_stage_0_2
        (
            .i_a(i_4),
            .i_b(i_5),
            .o_sum(sum_stage_0_2)
        ); 

    adder #(.BITWIDTH(16)) add_stage_0_3
        (
            .i_a(i_6),
            .i_b(i_7),
            .o_sum(sum_stage_0_3)
        ); 

    // Stage 1
    adder #(.BITWIDTH(17)) add_stage_1_0
        (
            .i_a(sum_stage_0_0_reg),
            .i_b(sum_stage_0_1_reg),
            .o_sum(sum_stage_1_0)
        ); 

    adder #(.BITWIDTH(17)) add_stage_1_1
        (
            .i_a(sum_stage_0_2_reg),
            .i_b(sum_stage_0_3_reg),
            .o_sum(sum_stage_1_1)
        ); 

    // Stage 2
    adder #(.BITWIDTH(18)) add_stage_2_0
        (
            .i_a(sum_stage_1_0),
            .i_b(sum_stage_1_1),
            .o_sum(sum_stage_2_0)
        );

    always_ff @( posedge i_clk ) begin
        if ( !i_nrst ) begin
            sum_stage_0_0_reg <= 0;
            sum_stage_0_1_reg <= 0;
            sum_stage_0_2_reg <= 0;
            sum_stage_0_3_reg <= 0;
            sum_stage_2_0_reg <= 0;
        end else begin
            sum_stage_0_0_reg <= sum_stage_0_0;
            sum_stage_0_1_reg <= sum_stage_0_1;
            sum_stage_0_2_reg <= sum_stage_0_2;
            sum_stage_0_3_reg <= sum_stage_0_3;
            sum_stage_2_0_reg <= sum_stage_2_0;
        end
    end

    assign o_sum = sum_stage_2_0;

endmodule

// Multiplier Module Definition
module multiplier_array (
        i_nrst,
        i_clk,
        i_a0,
        i_a1,
        i_a2,
        i_a3,
        i_a4,
        i_a5,
        i_a6,
        i_a7, 
        i_b0,
        i_b1,
        i_b2,
        i_b3,
        i_b4,
        i_b5,
        i_b6,
        i_b7,
        o_0,
        o_1,
        o_2,
        o_3,
        o_4,
        o_5,
        o_6,
        o_7
    );

    input                      i_nrst;
    input                      i_clk;
    input  logic signed  [7:0] i_a0, i_a1, i_a2, i_a3, i_a4, i_a5, i_a6, i_a7; // Input group A
    input  logic signed  [7:0] i_b0, i_b1, i_b2, i_b3, i_b4, i_b5, i_b6, i_b7; // Input group B
    output logic signed [15:0] o_0, o_1, o_2, o_3, o_4, o_5, o_6, o_7; // Products

    logic signed [15:0] o_0_wire, o_1_wire, o_2_wire, o_3_wire, o_4_wire, o_5_wire, o_6_wire, o_7_wire;
    logic signed [15:0] o_0_reg, o_1_reg, o_2_reg, o_3_reg, o_4_reg, o_5_reg, o_6_reg, o_7_reg;

    multiplier mult_0
        (
            .i_a(i_a0),
            .i_b(i_b0),
            .o_p(o_0_wire)
        );

    multiplier mult_1
        (
            .i_a(i_a1),
            .i_b(i_b1),
            .o_p(o_1_wire)
        );

    multiplier mult_2
        (
            .i_a(i_a2),
            .i_b(i_b2),
            .o_p(o_2_wire)
        );

    multiplier mult_3
        (
            .i_a(i_a3),
            .i_b(i_b3),
            .o_p(o_3_wire)
        );

    multiplier mult_4
        (
            .i_a(i_a4),
            .i_b(i_b4),
            .o_p(o_4_wire)
        );

    multiplier mult_5
        (
            .i_a(i_a5),
            .i_b(i_b5),
            .o_p(o_5_wire)
        );

    multiplier mult_6
        (
            .i_a(i_a6),
            .i_b(i_b6),
            .o_p(o_6_wire)
        );

    multiplier mult_7
        (
            .i_a(i_a7),
            .i_b(i_b7),
            .o_p(o_7_wire)
        );

    always_ff @( posedge i_clk ) begin
        if ( !i_nrst ) begin
            o_0_reg <= 0;
            o_1_reg <= 0; 
            o_2_reg <= 0; 
            o_3_reg <= 0; 
            o_4_reg <= 0; 
            o_5_reg <= 0; 
            o_6_reg <= 0; 
            o_7_reg <= 0; 
        end else begin
            o_0_reg <= o_0_wire;
            o_1_reg <= o_1_wire; 
            o_2_reg <= o_2_wire; 
            o_3_reg <= o_3_wire; 
            o_4_reg <= o_4_wire; 
            o_5_reg <= o_5_wire; 
            o_6_reg <= o_6_wire; 
            o_7_reg <= o_7_wire; 
        end
    end

    assign o_0 = o_0_reg;
    assign o_1 = o_1_reg;
    assign o_2 = o_2_reg;
    assign o_3 = o_3_reg;
    assign o_4 = o_4_reg;
    assign o_5 = o_5_reg;
    assign o_6 = o_6_reg;
    assign o_7 = o_7_reg;
    
endmodule

// Multiplier Module Definition
module multiplier (
        i_a,
        i_b,
        o_p
    );

    input  logic signed  [7:0] i_a;
    input  logic signed  [7:0] i_b;
    output logic signed [15:0] o_p;
    
    assign o_p = $signed(i_a) * $signed(i_b);
    
endmodule

// Adder Module Definition
module adder #(parameter BITWIDTH = 8) (
        i_a,
        i_b,
        o_sum 
    );

    input  logic signed [BITWIDTH-1:0] i_a;
    input  logic signed [BITWIDTH-1:0] i_b;
    output logic signed   [BITWIDTH:0] o_sum;
    
    assign o_sum = $signed(i_a) + $signed(i_b);
    
endmodule