/**
 * UartTx
 * @brief 8N1 UART transmitter, one byte at a time.
 *        ready_o high = idle, can accept. Byte latched when valid_i && ready_o.
 */
module UartTx #(
    parameter int CLK_FREQ  = 100_000_000,
    parameter int BAUD_RATE = 115_200
) (
    input  logic       clk_i,
    input  logic       rst_ni,
    input  logic [7:0] data_i,
    input  logic       valid_i,
    output logic       ready_o,
    output logic       tx_o
);
    localparam int DIVIDER = CLK_FREQ / BAUD_RATE;

    logic [$clog2(DIVIDER)-1:0] baud_cnt;
    logic [3:0]                 bit_cnt;
    logic [9:0]                 shift;   /* {stop, data[7:0], start} */
    logic                       active;

    assign ready_o = !active;
    assign tx_o    = active ? shift[0] : 1'b1;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            active   <= 0;
            baud_cnt <= 0;
            bit_cnt  <= 0;
            shift    <= '1;
        end
        else if (!active) begin
            if (valid_i) begin
                shift    <= {1'b1, data_i, 1'b0};
                active   <= 1;
                baud_cnt <= 0;
                bit_cnt  <= 0;
            end
        end
        else if (baud_cnt == DIVIDER - 1) begin
            baud_cnt <= 0;
            shift    <= {1'b1, shift[9:1]};
            if (bit_cnt == 9)
                active <= 0;
            else
                bit_cnt <= bit_cnt + 1;
        end
        else
            baud_cnt <= baud_cnt + 1;
    end
endmodule
