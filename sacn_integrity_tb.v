module scan_integrity_tb;
  reg refclk, clk2, reset, test_mode, se;
  reg si1, si2;
  reg [4:0] data_in;
  wire [4:0] data_out;
  wire so1, so2;

  // Instantiate DFT1 module
  GOLDEN_DESIGN uut (
    .refclk(refclk),
    .clk2(clk2),
    .data_in(data_in),
    .test_mode(test_mode),
    .si1(si1),
    .si2(si2),
    .se(se),
    .so1(so1),
    .so2(so2),
    .reset(reset),
    .data_out(data_out)
  );

  // Generate clocks
  initial begin
    refclk = 0;
    forever #5 refclk = ~refclk; // 10ns period
  end

  initial begin
    clk2 = 0;
    forever #6 clk2 = ~clk2; // 12ns period
  end

  // Task to shift scan data
  task scan_shift(input bit scan_val);
    integer i;
    begin
      for (i = 0; i < 10; i = i + 1) begin
        si1 = scan_val;
        si2 = scan_val;
        #10; // one clock cycle
      end
    end
  endtask

  // Test procedure
  initial begin
    $dumpfile("scan_integrity_tb.vcd");
    $dumpvars(0, scan_integrity_tb);

    // Initial values
    se = 1;           // scan enable active
    test_mode = 1;    // test mode active
    reset = 1;        // apply reset
    si1 = 0;
    si2 = 0;
    data_in = 5'b00000;
    #20;

    reset = 0;

    // Scan shift: all 0s
    $display("Shifting all 0s through scan chain");
    scan_shift(1'b0);
    #20;
    if (so1 !== 1'b0 || so2 !== 1'b0)
      $display("ERROR: Expected SO1=0, SO2=0 after shifting 0s. Got SO1=%b, SO2=%b", so1, so2);
    else
      $display("PASS: Scan out SO1=%b, SO2=%b after all 0s", so1, so2);

    // Scan shift: all 1s
    $display("Shifting all 1s through scan chain");
    scan_shift(1'b1);
    #20;
    if (so1 !== 1'b1 || so2 !== 1'b1)
      $display("ERROR: Expected SO1=1, SO2=1 after shifting 1s. Got SO1=%b, SO2=%b", so1, so2);
    else
      $display("PASS: Scan out SO1=%b, SO2=%b after all 1s", so1, so2);

    $finish;
  end
endmodule
