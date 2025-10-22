module Bram_interface_FIFO#(
    parameter RAM_WIDTH = 8,
    parameter RAM_DEPTH = 512
) (
    input iClk,
    input iRst,
    input iStart,                // Start signal to begin the write/read cycle
    input [RAM_WIDTH-1:0] iData, // Data to be written into the FIFO
    output oDone,                // Pulses high for one cycle when a block read is complete
    output [RAM_WIDTH-1:0] oData // Data read from the FIFO
);

    // --- Internal Signals ---
    localparam ADDR_WIDTH      = $clog2(RAM_DEPTH);
    localparam HALF_DEPTH      = RAM_DEPTH / 2;
    localparam HALF_ADDR_WIDTH = ADDR_WIDTH - 1;

    // State machine definition
    localparam S_IDLE  = 1'b0;
    localparam S_RUN   = 1'b1;

    reg state, next_state;

    // Ping-pong control registers
    reg [HALF_ADDR_WIDTH-1:0] addr_cnt;
    reg                       ping_reg; // Determines the current write buffer (0 or 1)
    reg                       read_buffer_valid; // Becomes true after the first buffer is filled

    // BRAM interface signals
    wire [18:0] addra;
    wire [19-1:0] addrb;
    reg                   wea;
    reg                   ena;
    reg                   enb;
    wire [RAM_WIDTH-1:0]  doutb;

    // --- State Machine Logic ---

    // Combinational logic for next state
    always @(*) begin
        next_state = state; // Default: stay in current state
        case (state)
            S_IDLE:
                if (iStart) begin
                    next_state = S_RUN;
                end
        endcase
    end

    // Sequential logic for state transition
    always @(posedge iClk or negedge iRst) begin
        if (!iRst) begin
            state <= S_IDLE;
        end else begin
            state <= next_state;
        end
    end

    // --- Address Counters and Control Signal Logic ---
    always @(posedge iClk or negedge iRst) begin
        if (!iRst) begin
            // Reset all counters and control signals
            addr_cnt          <= 0;
            ping_reg          <= 1'b0;
            read_buffer_valid <= 1'b0;
            wea               <= 1'b0;
            ena               <= 1'b0;
            enb               <= 1'b0;
        end else begin
            if (state == S_IDLE && next_state == S_RUN) begin // Start condition
                addr_cnt          <= 0;
                ping_reg          <= 1'b0;
                read_buffer_valid <= 1'b0;
                ena               <= 1'b1;
                wea               <= 1'b1;
                enb               <= 1'b0;
            end else if (state == S_RUN) begin
                // In RUN state, ports are generally active
                ena <= 1'b1;
                wea <= 1'b1;
                enb <= read_buffer_valid; // Only enable read after first block is filled

                // Increment address counter
                addr_cnt <= addr_cnt + 1;

                if (addr_cnt == HALF_DEPTH - 1) begin
                    // When a half-buffer transaction is complete, swap buffers
                    addr_cnt          <= 0;
                    ping_reg          <= ~ping_reg;
                    read_buffer_valid <= 1'b1; // Data is valid for reading from now on
                end
            end else begin
                // In IDLE, keep everything disabled
                wea <= 1'b0;
                ena <= 1'b0;
                enb <= 1'b0;
            end
        end
    end

    // --- Combinational Address and Output Logic ---

    // Write to the buffer selected by ping_reg
    assign addra = {ping_reg, addr_cnt};
    // Read from the other buffer
    assign addrb = {~ping_reg, addr_cnt};

    assign oData = doutb;
    // oDone is asserted for one clock cycle when a block read is complete.
    // This happens when the address counter wraps around in the RUN state.
    assign oDone = (state == S_RUN) && (addr_cnt == HALF_DEPTH - 1);


    // --- BRAM Instantiation ---
    Bram #(
        .RAM_WIDTH(RAM_WIDTH),
        .RAM_DEPTH(RAM_DEPTH)
    ) ram_inst (
        // Port A (Write Port)
        .clka(iClk),
        .ena(ena),
        .wea(wea),
        .addra(addra),
        .dina(iData),
        .douta(), // Port A output not used

        // Port B (Read Port)
        .clkb(iClk),
        .enb(enb),
        .web(1'b0), // Port B is read-only
        .addrb(addrb),
        .dinb(0),
        .doutb(doutb)
    );

endmodule