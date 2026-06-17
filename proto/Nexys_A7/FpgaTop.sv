/**
 * FpgaTop
 * @brief Nexys A7-100T proof-of-concept for Hermes NoC latency measurement.
 *
 * Topology: 4×4 mesh.
 *   - Node (0,0) [index  0]: TrafficGen injects 2-flit requests every PERIOD cycles.
 *                            LatencyCounter receives 18-flit responses and measures RTT.
 *   - Node (3,3) [index 15]: Responder receives the request and replies with a
 *                            cache-line-sized packet (1 header + 1 ts + 16 data flits).
 *   - All other local ports: inactive (rx tied 0, credit_i tied 1).
 *
 * UART output at 115200 baud: one "XXXXXXXX\r\n" line per measured latency.
 * LED[0] heartbeat, LED[1] inject, LED[2] measurement, LED[3] UART busy.
 */

/* All sources added via build.tcl read_verilog — no includes needed here. */

module FpgaTop #(
    parameter int X_SIZE    = 4,
    parameter int Y_SIZE    = 4,
    parameter int FLIT_SIZE = 32,
    /* ponytail: 10000 gives ~87 µs between packets; UART takes ~870 µs for 10 bytes,
       so ~1 in 10 measurements is printed. Increase to 100000 for 1-to-1. */
    parameter int PERIOD    = 10_000
) (
    input  logic       clk_i,
    input  logic       rst_ni,   /* CPU_RESETN, active low */
    output logic       uart_tx_o,
    output logic [3:0] led_o
);
    localparam int N   = X_SIZE * Y_SIZE;
    localparam int SRC = 0;      /* node (0,0) */
    localparam int DST = N - 1;  /* node (3,3) */

    /* ------------------------------------------------------------------ */
    /* NoC                                                                  */
    /* ------------------------------------------------------------------ */
    logic [N-1:0]           rx, eop_in, credit_out, tx, eop_out, credit_in;
    logic [(FLIT_SIZE-1):0] data_in  [N-1:0];
    logic [(FLIT_SIZE-1):0] data_out [N-1:0];

    HermesNoC #(
        .X_SIZE   (X_SIZE   ),
        .Y_SIZE   (Y_SIZE   ),
        .FLIT_SIZE(FLIT_SIZE)
    ) noc (
        .clk_i    (clk_i     ),
        .rst_ni   (rst_ni    ),
        .rx_i     (rx        ),
        .eop_i    (eop_in    ),
        .data_i   (data_in   ),
        .credit_o (credit_out),
        .tx_o     (tx        ),
        .eop_o    (eop_out   ),
        .data_o   (data_out  ),
        .credit_i (credit_in )
    );

    /* All downstream receivers are always ready. */
    assign credit_in = '1;

    /* Tie off unused local ports (indices 1 .. N-2). */
    genvar gi;
    generate
        for (gi = 1; gi < N-1; gi++) begin : g_tie
            assign rx[gi]      = 1'b0;
            assign eop_in[gi]  = 1'b0;
            assign data_in[gi] = '0;
        end
    endgenerate

    /* ------------------------------------------------------------------ */
    /* TrafficGen — drives port SRC send side                              */
    /* ------------------------------------------------------------------ */
    TrafficGen #(
        .FLIT_SIZE(FLIT_SIZE),
        .SRC_X    (0          ),
        .SRC_Y    (0          ),
        .DST_X    (X_SIZE - 1 ),
        .DST_Y    (Y_SIZE - 1 ),
        .PERIOD   (PERIOD     )
    ) tgen (
        .clk_i    (clk_i          ),
        .rst_ni   (rst_ni         ),
        .data_o   (data_in[SRC]   ),
        .rx_o     (rx[SRC]        ),
        .eop_o    (eop_in[SRC]    ),
        .credit_i (credit_out[SRC])
    );

    /* ------------------------------------------------------------------ */
    /* Responder — drives and reads port DST                               */
    /* ------------------------------------------------------------------ */
    Responder #(
        .FLIT_SIZE  (FLIT_SIZE),
        .MY_X       (X_SIZE - 1),
        .MY_Y       (Y_SIZE - 1),
        .RESP_X     (0         ),
        .RESP_Y     (0         ),
        .CACHE_FLITS(16        )
    ) resp (
        .clk_i      (clk_i          ),
        .rst_ni     (rst_ni         ),
        .rx_data_i  (data_out[DST]  ),
        .rx_tx_i    (tx[DST]        ),
        .rx_eop_i   (eop_out[DST]   ),
        .tx_data_o  (data_in[DST]   ),
        .tx_rx_o    (rx[DST]        ),
        .tx_eop_o   (eop_in[DST]    ),
        .tx_credit_i(credit_out[DST])
    );

    /* ------------------------------------------------------------------ */
    /* LatencyCounter — reads port SRC receive side                        */
    /* ------------------------------------------------------------------ */
    logic [31:0] latency;
    logic        latency_valid;

    LatencyCounter #(.FLIT_SIZE(FLIT_SIZE)) lc (
        .clk_i    (clk_i        ),
        .rst_ni   (rst_ni       ),
        .data_i   (data_out[SRC]),
        .tx_i     (tx[SRC]      ),
        .eop_i    (eop_out[SRC] ),
        .latency_o(latency      ),
        .valid_o  (latency_valid)
    );

    /* ------------------------------------------------------------------ */
    /* UART serializer: "XXXXXXXX\r\n" (10 bytes) per measurement          */
    /* ponytail: drops measurements when UART is busy; fine for PoC        */
    /* ------------------------------------------------------------------ */
    function automatic logic [7:0] n2h(input logic [3:0] n);
        n2h = (n < 4'd10) ? (8'h30 + {4'h0, n}) : (8'h37 + {4'h0, n});
    endfunction

    logic [7:0] uart_data;
    logic       uart_valid;
    logic       uart_ready;

    UartTx #(
        .CLK_FREQ (100_000_000),
        .BAUD_RATE(115_200    )
    ) utx (
        .clk_i  (clk_i    ),
        .rst_ni (rst_ni   ),
        .data_i (uart_data),
        .valid_i(uart_valid),
        .ready_o(uart_ready),
        .tx_o   (uart_tx_o)
    );

    logic [79:0] uart_buf;  /* 10-byte shift register */
    logic [3:0]  uart_cnt;
    logic        uart_busy;

    assign uart_data  = uart_buf[79:72];
    assign uart_valid = uart_busy & uart_ready;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            uart_busy <= 0;
            uart_cnt  <= 0;
            uart_buf  <= '0;
        end
        else if (!uart_busy) begin
            if (latency_valid) begin
                uart_buf <= {
                    n2h(latency[31:28]), n2h(latency[27:24]),
                    n2h(latency[23:20]), n2h(latency[19:16]),
                    n2h(latency[15:12]), n2h(latency[11: 8]),
                    n2h(latency[ 7: 4]), n2h(latency[ 3: 0]),
                    8'h0D, 8'h0A
                };
                uart_cnt  <= 0;
                uart_busy <= 1;
            end
        end
        else if (uart_ready) begin
            uart_buf <= {uart_buf[71:0], 8'h00};
            if (uart_cnt == 9)
                uart_busy <= 0;
            else
                uart_cnt <= uart_cnt + 1;
        end
    end

    /* ------------------------------------------------------------------ */
    /* LEDs                                                                 */
    /* ------------------------------------------------------------------ */
    logic [25:0] heartbeat;
    always_ff @(posedge clk_i or negedge rst_ni)
        if (!rst_ni) heartbeat <= 0;
        else         heartbeat <= heartbeat + 1;

    assign led_o[0] = heartbeat[25];   /* ~0.67 s toggle */
    assign led_o[1] = rx[SRC];         /* packet being injected */
    assign led_o[2] = latency_valid;   /* measurement pulse (~1 cycle) */
    assign led_o[3] = uart_busy;       /* UART transmitting */

endmodule
