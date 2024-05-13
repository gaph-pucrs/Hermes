/**
 * Hermes
 * @file HermesBuffer.sv
 * 
 * @author Angelo Elias Dal Zotto (angelo.dalzotto@edu.pucrs.br)
 * GAPH - Hardware Design Support Group (https://corfu.pucrs.br/)
 * PUCRS - Pontifical Catholic University of Rio Grande do Sul (http://pucrs.br/)
 * 
 * @date September 2023
 * 
 * @brief SystemVerilog Hermes buffer module.
 *
 * @detail 
 * When the switching algorithm blocks a packet flit, there is performance
 * loss across the entire network because flits are blocked in all intermediary
 * interconnections. 
 * Adding a queue to input ports decreases flit blocking. 
 * The bigger the queue, less switches are affected by a block. 
 * Its functioning is based on circular FIFO.
 */

module HermesBuffer
#(
    parameter BUFFER_SIZE = 8,  /* Power of 2  */
    parameter FLIT_SIZE   = 32  /* Minimum: 20 */
)
(
    input  logic clk_i,
    input  logic rst_ni,

    input  logic rx_i,
    input  logic req_ack_i,
    input  logic data_ack_i,
    input  logic [(FLIT_SIZE - 1):0] data_i,

    output logic req_o,
    output logic credit_o,
    output logic data_av_o,
    output logic sending_o,
    output logic [(FLIT_SIZE - 1):0] data_o
);

    logic tx;

    RingBuffer #(
        .DATA_SIZE(32),
        .BUFFER_SIZE(BUFFER_SIZE)
    ) ringbuffer (
        .clk_i      (clk_i),
        .rst_ni     (rst_ni),
        .rx_i       (rx_i),
        .rx_ack_o   (credit_o),
        .data_i     (data_i),
        .tx_o       (tx),
        .tx_ack_i   (data_ack_i),
        .data_o     (data_o)
    );

    /* FSM Control */
    typedef enum logic [4:0] {
        SEND_INIT    = 5'b00001,
        SEND_REQ     = 5'b00010,
        SEND_HEADER  = 5'b00100,
        SEND_SIZE    = 5'b01000,
        SEND_PAYLOAD = 5'b10000
    } fsm_t;

    fsm_t state;
    fsm_t next_state;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            state <= SEND_INIT;
        else
            state <= next_state;
    end

    /* Flit counter control */
    logic [(FLIT_SIZE - 1):0] flit_cntr;
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            flit_cntr <= '0; 
        end
        else begin
            case (state)
                SEND_SIZE:    flit_cntr <= data_o;
                SEND_PAYLOAD: begin
                    if (data_ack_i && tx)
                        flit_cntr <= flit_cntr - 1'b1;
                end
                default:      flit_cntr <= '0;
            endcase
        end
    end

    always_comb begin
        case (state)
            SEND_INIT:    next_state = tx         ? SEND_REQ     : SEND_INIT;
            SEND_REQ:     next_state = req_ack_i  ? SEND_HEADER  : SEND_REQ;
            SEND_HEADER:  next_state = data_ack_i ? SEND_SIZE    : SEND_HEADER;
            SEND_SIZE:    next_state = data_ack_i ? SEND_PAYLOAD : SEND_SIZE;
            SEND_PAYLOAD: next_state = (data_ack_i && tx && flit_cntr == 32'b1)
                                                                 ? SEND_INIT
                                                                 : SEND_PAYLOAD;
            default:      next_state =                             SEND_INIT;
        endcase
    end

    /* FSM behavior */
    /* Routing request control*/
    assign req_o = (state == SEND_REQ);

    /* Active */
    assign sending_o = (state inside {SEND_HEADER, SEND_SIZE, SEND_PAYLOAD});

    /* Data request control */
    assign data_av_o = (state inside {SEND_HEADER, SEND_SIZE, SEND_PAYLOAD} && tx);

endmodule
