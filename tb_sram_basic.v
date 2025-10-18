`timescale 1ns / 1ps

module tb_dual_port_ram;

  // Parameters
  localparam RAM_WIDTH = 8;
  localparam RAM_DEPTH = 307200; // 640 * 480
  localparam CLK_A_PERIOD = 10;
  localparam CLK_B_PERIOD = 10;

  // Testbench signals
  reg [clogb2(RAM_DEPTH-1)-1:0] addra;
  reg [clogb2(RAM_DEPTH-1)-1:0] addrb;
  reg [RAM_WIDTH-1:0] dina;
  reg [RAM_WIDTH-1:0] dinb;
  reg clka;
  reg clkb;
  reg wea;
  reg web;
  reg ena;
  reg enb;
  reg rsta;
  reg rstb;
  reg regcea;
  reg regceb;

  wire [RAM_WIDTH-1:0] douta;
  wire [RAM_WIDTH-1:0] doutb;

  // Memory to hold image data from file
  reg [RAM_WIDTH-1:0] image_memory [0:RAM_DEPTH-1];

  // Instantiate the Device Under Test (DUT)
  Bram_interface #(
    .RAM_WIDTH(RAM_WIDTH),
    .RAM_DEPTH(RAM_DEPTH),
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"),
    .INIT_FILE("")
  ) DUT (
    .iClk(),
    .iRst
  );
  
  // Clock generation
  always #((CLK_A_PERIOD)/2) clka = ~clka;
  always #((CLK_B_PERIOD)/2) clkb = ~clkb;
  
  integer i;

  initial begin
    // 1. Initialize signals
    $display("INFO: Starting Simulation...");
    clka = 0;
    clkb = 0;
    addra = 0;
    addrb = 0;
    dina = 0;
    dinb = 0;
    wea = 0;
    web = 0;
    ena = 0;
    enb = 0;
    rsta = 1;
    rstb = 1;
    regcea = 0;
    regceb = 1;

    // 2. Load image file into testbench memory
    $readmemh("image.txt", image_memory);
    $display("INFO: image.txt loaded into testbench memory.");
    
    // 3. Reset sequence
    #100;
    rsta = 0;
    rstb = 0;
    
    // 4. Write data from image_memory to BRAM via Port A
    $display("INFO: Starting to write image data to BRAM via Port A...");
    ena = 1;
    wea = 1;
    
    for (i = 0; i < RAM_DEPTH; i = i + 1) begin
      @(posedge clka);
      addra = i;
      dina = image_memory[i];
    end
    

    // De-assert write enable after writing is complete
    @(posedge clka);
    wea = 0;
    ena = 0;
    $display("INFO: Finished writing image data.");
    
    // 5. (Optional) Read back and verify data via Port B
    $display("INFO: Starting to read and verify data from BRAM via Port B...");
    enb = 1;
    web = 0; // Read mode
    
    for (i = 0; i < 10; i = i + 1) begin // Verify first 10 values
      @(posedge clkb);
      addrb = i;
      // Wait for read latency (2 cycles for HIGH_PERFORMANCE)
      @(posedge clkb);
      @(posedge clkb);
      if (doutb === image_memory[i]) begin
        $display("SUCCESS: Address %0d, Read Data: %h, Expected Data: %h", i, doutb, image_memory[i]);
      end else begin
        $display("ERROR: Address %0d, Read Data: %h, Expected Data: %h", i, doutb, image_memory[i]);
      end
    end

    enb = 0;
    
    // 6. Finish simulation
    $display("INFO: Simulation Finished.");
    $finish;
  end

  // Helper function from the DUT to calculate address width
  function integer clogb2;
    input integer depth;
    for (clogb2=0; depth>0; clogb2=clogb2+1)
      depth = depth >> 1;
  endfunction

endmodule

