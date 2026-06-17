/**
 * Responder
 * @brief Sits at the destination node. Receives a 2-flit request (header +
 *        tx_timestamp), then sends back an 18-flit response:
 *            [header][echoed_tx_timestamp][16 × cache-line dummy flits (last EOP)]
 *        The receiver computes latency = arrival_cycle - echoed_tx_timestamp.
 */
module Responder #(
    parameter int FLIT_SIZE   = 32,
    parameter int MY_X        = 3,
    parameter int MY_Y        = 3,
    parameter int RESP_X      = 0,
    parameter int RESP_Y      = 0,
    parameter int CACHE_FLITS = 16
) (
    input  logic clk_i,
    input  logic rst_ni,

    /* Receive side: NoC local port output → us */
    input  logic [(FLIT_SIZE-1):0] rx_data_i,
    input  logic                   rx_tx_i,
    input  logic                   rx_eop_i,   /* unused but kept for clarity */

    /* Send side: us → NoC local port input */
    output logic [(FLIT_SIZE-1):0] tx_data_o,
    output logic                   tx_rx_o,
    output logic                   tx_eop_o,
    input  logic                   tx_credit_i  /* from NoC buffer */
);
    /* ponytail: credit always 1 — NoC drives local output; credit_i[port]=1 in FpgaTop */

    typedef enum logic [2:0] {
        R_IDLE, R_GRAB_TS, R_SEND_HDR, R_SEND_TS, R_SEND_DATA
    } state_t;
    state_t state;

    logic [31:0]                    ts;
    logic [$clog2(CACHE_FLITS):0]   dcnt;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state     <= R_IDLE;
            ts        <= 0;
            dcnt      <= 0;
            tx_rx_o   <= 0;
            tx_eop_o  <= 0;
            tx_data_o <= 0;
        end
        else case (state)
            /* Flit 0 of request = header; skip, go wait for timestamp. */
            R_IDLE: if (rx_tx_i) state <= R_GRAB_TS;

            /* Flit 1 of request = tx_timestamp (EOP). Capture and start response. */
            R_GRAB_TS: if (rx_tx_i) begin
                ts        <= rx_data_i;
                tx_data_o <= {MY_X[7:0], MY_Y[7:0], RESP_X[7:0], RESP_Y[7:0]};
                tx_rx_o   <= 1;
                tx_eop_o  <= 0;
                state     <= R_SEND_HDR;
            end

            /* Response flit 0 = header. */
            R_SEND_HDR: if (tx_credit_i) begin
                tx_data_o <= ts;   /* echo timestamp */
                tx_eop_o  <= 0;
                dcnt      <= 0;
                state     <= R_SEND_TS;
            end

            /* Response flit 1 = echoed timestamp. */
            R_SEND_TS: if (tx_credit_i) begin
                tx_data_o <= 32'hCA7E_0000;
                tx_eop_o  <= (CACHE_FLITS == 1);
                dcnt      <= 1;
                state     <= R_SEND_DATA;
            end

            /* Response flits 2..17 = 16 cache-line dummy words. */
            R_SEND_DATA: if (tx_credit_i) begin
                if (tx_eop_o) begin            /* last flit accepted */
                    tx_rx_o  <= 0;
                    tx_eop_o <= 0;
                    state    <= R_IDLE;
                end
                else begin
                    tx_data_o <= 32'hCA7E_0000 | {27'h0, dcnt[4:0]};
                    tx_eop_o  <= (dcnt == CACHE_FLITS - 1);
                    dcnt      <= dcnt + 1;
                end
            end
        endcase
    end

    /* Suppress unused-signal warning */
    /* verilator lint_off UNUSEDSIGNAL */
    logic _unused;
    assign _unused = rx_eop_i;
    /* verilator lint_on UNUSEDSIGNAL */

endmodule
