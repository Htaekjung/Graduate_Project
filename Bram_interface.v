
module Bram_interface#(
  parameter RAM_WIDTH = 8,                       
  parameter RAM_DEPTH = 100,                     
  parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE", 
  parameter INIT_FILE = ""                        
) (
    input iClk,
    input iRst,
    input [7:0] iData,
    output done_sig,
    output [7:0] oData
);
    reg [18:0] addra;
    reg [18:0] addrb;
    wire [RAM_WIDTH-1:0] dina;
    wire rsta, rstb;
    wire clka, clkb;
    reg ena, enb;
    reg regceb;
    wire [7:0] doutb;

    assign clkb = iClk;
    assign clka = iClk;
    assign rsta = iRst;
    assign rstb = iRst;
    assign dina = iData;

    localparam IDLE  = 3'b000; // 초기 대기 상태
    localparam WRITE = 3'b001; // Port A로 데이터를 쓰는 상태
    localparam DELAY = 3'b010;
    localparam READ  = 3'b011; // Port B로 데이터를 읽는 상태
    localparam DONE  = 3'b100; // 모든 작업이 끝난 상태

    reg [2:0] state, next_state;
    reg delay_done;

    always @(posedge iClk or negedge iRst) begin
        if (!iRst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    always @(*) begin
        case (state) 
            IDLE:  next_state = WRITE;
            WRITE: 
                next_state = (addra == RAM_DEPTH-1) ? DELAY : WRITE;
            DELAY :
                next_state = (delay_done == 1'b1) ? READ : DELAY;
            READ: 
                next_state = (addrb == RAM_DEPTH-1) ? DONE : READ;
            DONE: 
                next_state = DONE;
            default: 
                next_state = IDLE;
        endcase
    end
    always @(posedge iClk) begin
        if (!iRst) begin
            regceb = 1'b0;
            enb = 1'b0;
        end else if (next_state == DELAY && state == DELAY) begin
            regceb = 1'b1;
            enb = 1'b1;
        end
    end

    always @(posedge iClk) begin
        if (!iRst) begin
            addra = 0;
            addrb = 0;
            ena = 1'b1;     
        end else if (state == WRITE) begin 
            ena = 1'b1;    
            addra = addra + 1; 
        end else if (state == DELAY) begin
                    ena = 1'b0;
        end else if (state == READ) begin
        addrb = addrb + 1;
        end else if (state == DONE) begin
                addrb = addrb +1;
        end else begin 
            addra = 0;
            addrb = 0;
        end
    end

    Bram #(
    .RAM_WIDTH(RAM_WIDTH),
    .RAM_DEPTH(RAM_DEPTH),
    .RAM_PERFORMANCE(RAM_PERFORMANCE),
    .INIT_FILE(INIT_FILE)
    ) DUT (
    .addra(addra),
    .addrb(addrb),
    .dina(dina),
    .dinb(),
    .clka(clka),
    .clkb(clkb),
    .wea(1'b1),
    .web(1'b0),
    .ena(ena),
    .enb(enb),
    .rsta(rsta),
    .rstb(rstb),
    .regcea(1'b0),
    .regceb(regceb),
    .douta(),
    .doutb(doutb)
    );

    always @(posedge iClk) begin
        if(!iRst) begin
            delay_done = 1'b0;
        end else if(state == DELAY) begin
            delay_done = delay_done + 1;
        
        end
    end

    assign oData = doutb;
    assign done_sig = (1 < addrb && addrb < 102 ) ? 1'b1 : 1'b0;
endmodule




// module Bram_interface#(
//   parameter RAM_WIDTH = 8,                       // Specify RAM data width
//   parameter RAM_DEPTH = 100,                     // Specify RAM depth (number of entries)
//   parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE", // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
//   parameter INIT_FILE = ""                        // Specify name/location of RAM initialization file if using one (leave blank if not)
// ) (
//     input iClk,
//     input iRst,
//     input [7:0] iData,

//     output [7:0] oData
// );


//     reg [18:0] addra;
//     reg [18:0] addrb;
//     wire [RAM_WIDTH-1:0] dina;
//     wire rsta, rstb;
//     wire clka, clkb;
//     reg ena, enb;
//     reg regceb;
//     wire [7:0] doutb;

//     assign clkb = iClk;
//     assign clka = iClk;
//     assign rsta = iRst;
//     assign rstb = iRst;
//     assign dina = iData;

// localparam IDLE  = 3'b000; // 초기 대기 상태
// localparam WRITE = 3'b001; // Port A로 데이터를 쓰는 상태
// localparam DELAY = 3'b010;
// localparam READ  = 3'b011; // Port B로 데이터를 읽는 상태
// localparam DONE  = 3'b100; // 모든 작업이 끝난 상태

// reg [2:0] state, next_state;


//     always @(posedge iClk or negedge iRst) begin
//         if (!iRst) begin
//             state <= IDLE;
//         end else begin
//             state <= next_state;
//         end
//     end
//     always @(*) begin
//         case (state) 
//             IDLE:  next_state = WRITE;
//             WRITE: 
//                 next_state = (addra == RAM_DEPTH) ? DELAY : WRITE;
//             DELAY :
//                 next_state = () ? READ : WRITE;
//             READ: 
//                 next_state = (addrb == RAM_DEPTH) ? DONE : READ;
//             DONE: 
//                 next_state = DONE;
//             default: 
//                 next_state = IDLE;
//         endcase
//     end

// always @(posedge iClk) begin
//     if (!iRst) begin
//         addra = 0;
//         addrb = 0;
//         ena = 1'b1;
//         enb = 1'b0;
//         regceb = 1'b0;
//     end else if (state == WRITE) begin 
//         ena = 1'b1;    
//         addra = addra + 1; 
//     end else if (state == READ) begin
//         ena = 1'b0;
//         regceb = 1'b1;
//         enb = 1'b1;
//         addrb = addrb + 1;
//     end else begin 
//         addra = 0;
//         addrb = 0;
//         enb = 1'b0;
//         regceb = 1'b0;
//     end
// end
//     Bram #(
//     .RAM_WIDTH(RAM_WIDTH),
//     .RAM_DEPTH(RAM_DEPTH),
//     .RAM_PERFORMANCE(RAM_PERFORMANCE),
//     .INIT_FILE(INIT_FILE)
//     ) DUT (
//     .addra(addra),
//     .addrb(addrb),
//     .dina(dina),
//     .dinb(),
//     .clka(clka),
//     .clkb(clkb),
//     .wea(1'b1),
//     .web(1'b0),
//     .ena(ena),
//     .enb(enb),
//     .rsta(rsta),
//     .rstb(rstb),
//     .regcea(1'b0),
//     .regceb(regceb),
//     .douta(),
//     .doutb(doutb)
//     );
//     // always @(posedge iClk) begin
//     //     if(!iRst) begin
//     //         write_done = 1'b0;
//     //     end else if(addra == RAM_DEPTH) begin
//     //         write_done = 1'b1;
        
//     //     end
//     // end

//     assign oData = doutb;

// endmodule