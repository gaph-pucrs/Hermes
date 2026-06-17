/**
 * LatencyCounter
 * @brief Receives the 18-flit response at node (0,0).
 *        Flit 0 = response header (skip).
 *        Flit 1 = echoed tx_timestamp → latency = cycle_cnt - echoed_timestamp.
 *        Flits 2..17 = cache-line data (drain until EOP).
 *        Pulses valid_o for one cycle with the measured latency.
 */
module LatencyCounter #(
    parameter int FLIT_SIZE = 32
) (
    input  logic clk_i,
    input  logic rst_ni,

    /* Receive side: NoC local port output → us (credit tied 1 in FpgaTop) */
    input  logic [(FLIT_SIZE-1):0] data_i,
    input  logic                   tx_i,
    input  logic                   eop_i,

    /* Measurement output */
    output logic [31:0] latency_o,
    output logic        valid_o
);
    logic [31:0] cycle_cnt;
    always_ff @(posedge clk_i or negedge rst_ni)
        if (!rst_ni) cycle_cnt <= 0;
        else         cycle_cnt <= cycle_cnt + 1;

    typedef enum logic [1:0] { LC_WAIT, LC_GRAB_TS, LC_DRAIN } state_t;
    state_t state;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state     <= LC_WAIT;
            latency_o <= 0;
            valid_o   <= 0;
        end
        else begin
            valid_o <= 0;
            case (state)
                /* Wait for response header flit, then skip it. */
                LC_WAIT:    if (tx_i) state <= LC_GRAB_TS;

                /* Flit 1 = echoed tx_timestamp; compute round-trip latency. */
                LC_GRAB_TS: if (tx_i) begin
                    latency_o <= cycle_cnt - data_i;
                    valid_o   <= 1;
                    state     <= LC_DRAIN;
                end

                /* Drain remaining cache-line flits until EOP. */
                LC_DRAIN:   if (tx_i && eop_i) state <= LC_WAIT;
            endcase
        end
    end
endmodule
