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

    /* Buffer input */
    input  logic                     rx_i,
    input  logic                     eop_i,
    output logic                     credit_o,
    input  logic [(FLIT_SIZE - 1):0] data_i,

    /* Buffer output */
    output logic                     data_av_o,
    output logic                     eop_o,
    input  logic                     data_ack_i,
    output logic [(FLIT_SIZE - 1):0] data_o,
    
    /* Routing request control */
    output logic req_o,
    input  logic req_ack_i,
    output logic sending_o
);

    logic               tx;
    logic               eop;
    logic [FLIT_SIZE:0] data; /* 1 bit extra for EOP */

    assign data_o = data[(FLIT_SIZE-1):0];
    assign eop    = data[FLIT_SIZE];
    assign eop_o  = eop;

    RingBuffer #(
        .DATA_SIZE  (FLIT_SIZE + 1), /* 1 bit extra for EOP */
        .BUFFER_SIZE(BUFFER_SIZE  )
    ) ringbuffer (
        .clk_i    (clk_i          ),
        .rst_ni   (rst_ni         ),
        .buf_rst_i(1'b0           ),
        .rx_i     (rx_i           ),
        .rx_ack_o (credit_o       ),
        .data_i   ({eop_i, data_i}),
        .tx_o     (tx             ),
        .tx_ack_i (data_ack_i     ),
        .data_o   (data           )
    );

    /* FSM Control */
    typedef enum logic [2:0] {
        SEND_INIT    = 3'b001,
        SEND_REQ     = 3'b010,
        SEND_PAYLOAD = 3'b100
    } fsm_t;

    fsm_t state;
    fsm_t next_state;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            state <= SEND_INIT;
        else
            state <= next_state;
    end

    always_comb begin
        case (state)
            SEND_INIT:    next_state = tx         ? SEND_REQ     : SEND_INIT;
            SEND_REQ:     next_state = req_ack_i  ? SEND_PAYLOAD : SEND_REQ;
            SEND_PAYLOAD: next_state = (data_ack_i && tx && eop)
                                                                 ? SEND_INIT
                                                                 : SEND_PAYLOAD;
            default:      next_state = SEND_INIT;
        endcase
    end

    /* FSM behavior */
    /* Routing request control*/
    assign req_o = (state == SEND_REQ);

    /* Active */
    assign sending_o = (state == SEND_PAYLOAD);

    /* Data request control */
    assign data_av_o = (state == SEND_PAYLOAD && tx);

endmodule
