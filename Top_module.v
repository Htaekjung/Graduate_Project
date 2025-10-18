module Top_module (
    input iClk,
    input iRst,

);





Bram_interface #(
    .RAM_WIDTH(8),                        // 파라미터 설정
    .RAM_DEPTH(100),
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"),
    .INIT_FILE("")                        
) u_bram_interface (                      // 인스턴스 이름 (u_ 접두 추천)
    .iClk(iClk),                           // 포트 매핑
    .iRst(iRst),
    .iData(data_in),
    .done_sig(done_flag),
    .oData(data_out)
);









endmodule