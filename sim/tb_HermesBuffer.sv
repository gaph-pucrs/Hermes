module tb_HermesBuffer;
    timeunit 1ns; timeprecision 1ns;

    logic clk;
    logic rst_n;

    localparam CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) clk=~clk;

    logic tx;
    logic req_ack;
    logic data_ack;
    logic [31:0] data_write;

    logic req;
    logic credit;
    logic data_av;
    logic [31:0] data_read;

    HermesBuffer #(32, 8) buffer
    (
        .clk_i(clk),
        .rst_ni(rst_n),
        .rx_i(tx),
        .req_ack_i(req_ack),
        .data_ack_i(data_ack),
        .data_i(data_write),
        .req_o(req),
        .credit_o(credit),
        .data_av_o(data_av),
        .data_o(data_read)
    );

    initial begin
        clk <= 1'b0;
        rst_n <= 1'b0;
        req_ack <= 1'b0;
        data_ack <= 1'b0;
        #(CLK_PERIOD*3) rst_n <= 1'b1;

        @(negedge clk);
        tx <= 1'b1;
        data_write <= 8'h00;
        @(negedge clk);
        tx <= 1'b1;
        data_write <= 8'h10;
        @(negedge clk);
        for (int i = 0; i < 16; i++) begin
            wait(credit == 1'b1);
            data_write <= i;
            @(posedge clk);
        end
        tx <= 1'b0;
    end

endmodule
