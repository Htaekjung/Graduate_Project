module Top_module (
    input iClk,
    input iRst,

    output 
);





Bram_interface #(
    .RAM_WIDTH(8),
    .RAM_DEPTH(10240),
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"),
    .INIT_FILE(""),   // 초기화 파일이 있다면 여기에 입력
    .IMG_WIDTH(640),
    .IMG_HEIGHT(480),
    .TILE_WIDTH(16),
    .TILE_HEIGHT(16)
) m1 (
    .iClk(iClk),
    .iRst(iRst),
    .iData(iData),

    .oDone_sig(done_sig),
    .oData(oData)
);









endmodule