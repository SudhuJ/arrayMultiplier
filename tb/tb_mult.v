// Exhaustive self-checking testbench for the 4-bit array multiplier.
// Applies all 256 (a, b) pairs, waits the 2-cycle latency, compares p with a * b.
`timescale 1ns / 1ps

module tb_mult;

    reg        clk;
    reg        rst_n;
    reg  [3:0] a;
    reg  [3:0] b;
    wire [7:0] p;

    reg  [7:0] expected;
    integer    i, j;
    integer    errors;
    integer    vectors;

    mult_array dut (
        .clk   (clk),
        .rst_n (rst_n),
        .a     (a),
        .b     (b),
        .p     (p)
    );

    // 10 ns clock period
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Waveform dump
    initial begin
        $dumpfile("mult.vcd");
        $dumpvars(0, tb_mult);
    end

    initial begin
        errors  = 0;
        vectors = 0;
        a       = 4'd0;
        b       = 4'd0;

        // Hold reset low for the first 2 clock cycles
        rst_n = 1'b0;
        repeat (2) @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;

        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                // Change inputs on the falling edge so they are stable at the rising edge
                a = i[3:0];
                b = j[3:0];
                expected = {4'b0000, a} * {4'b0000, b};

                // Edge 1 captures a, b into the input registers;
                // edge 2 captures the product into p
                repeat (2) @(posedge clk);
                // Compare half a cycle later, after p has settled
                @(negedge clk);

                vectors = vectors + 1;
                if (p !== expected) begin
                    errors = errors + 1;
                    $display("MISMATCH at t=%0t: a=%0d b=%0d p=%0d expected=%0d",
                             $time, a, b, p, expected);
                end
            end
        end

        if (errors == 0)
            $display("PASS: %0d vectors checked, %0d errors", vectors, errors);
        else
            $display("FAIL: %0d vectors checked, %0d errors", vectors, errors);

        $finish;
    end

endmodule
