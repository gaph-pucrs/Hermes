/**
 * TrafficGen
 * @brief Sends 2-flit request packets: [header][tx_timestamp EOP].
 *        Waits PERIOD cycles between packets.
 *        tx_timestamp is the cycle counter value when the header was accepted —
 *        the responder echoes it back so the receiver can compute round-trip latency.
 */
module TrafficGen #(
    parameter int FLIT_SIZE = 32,
    parameter int SRC_X     = 0,
    parameter int SRC_Y     = 0,
    parameter int DST_X     = 3,
    parameter int DST_Y     = 3,
    parameter int PERIOD    = 5000
) (
    input  logic clk_i,
    input  logic rst_ni,

    output logic [(FLIT_SIZE-1):0] data_o,
    output logic                   rx_o,
    output logic                   eop_o,
    input  logic                   credit_i   /* from NoC buffer */
);
    logic [31:0] cycle_cnt;
    always_ff @(posedge clk_i or negedge rst_ni)
        if (!rst_ni) cycle_cnt <= 0;
        else         cycle_cnt <= cycle_cnt + 1;

    typedef enum logic [1:0] { TG_IDLE, TG_HEADER, TG_TS } state_t;
    state_t      state;
    logic [31:0] wait_cnt;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state    <= TG_IDLE;
            wait_cnt <= 0;
            rx_o     <= 0;
            eop_o    <= 0;
            data_o   <= 0;
        end
        else case (state)
            TG_IDLE: begin
                rx_o  <= 0;
                eop_o <= 0;
                if (wait_cnt == PERIOD - 1) begin
                    wait_cnt <= 0;
                    data_o   <= {SRC_X[7:0], SRC_Y[7:0], DST_X[7:0], DST_Y[7:0]};
                    rx_o     <= 1;
                    state    <= TG_HEADER;
                end
                else
                    wait_cnt <= wait_cnt + 1;
            end

            /* Header flit on the bus; wait for buffer credit. */
            TG_HEADER: if (credit_i) begin
                data_o <= cycle_cnt;  /* embed tx timestamp in payload flit */
                eop_o  <= 1;
                state  <= TG_TS;
            end

            /* Timestamp flit (EOP); wait for credit, then go idle. */
            TG_TS: if (credit_i) begin
                rx_o  <= 0;
                eop_o <= 0;
                state <= TG_IDLE;
            end
        endcase
    end
endmodule
