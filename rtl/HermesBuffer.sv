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

    logic full;
    logic empty;

    logic [($clog2(BUFFER_SIZE) - 1):0] head;
    logic [($clog2(BUFFER_SIZE) - 1):0] tail;

    logic [($clog2(BUFFER_SIZE) - 1):0] next_head;
    logic [($clog2(BUFFER_SIZE) - 1):0] next_tail;

    logic [(FLIT_SIZE - 1):0] buffer [(BUFFER_SIZE - 1):0];

    assign credit_o = !full;
    assign data_o   = buffer[tail];

    assign next_head = head + 1'b1;
    assign next_tail = tail + 1'b1;

    logic can_receive;
    assign can_receive = rx_i && !full;

    logic can_send;
    assign can_send = sending_o && data_ack_i && !empty;

    /* Buffer write control */
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (rst_ni)
            if (can_receive)
                buffer[head] <= data_i;
    end

    /* Head control */
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            head <= '0;
        else
            if (can_receive)
                head <= next_head;
    end

    /* Tail control */
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            tail <= '0;
        else
            if (can_send)
                tail <= next_tail;
    end

    /* Input control: sets full when next_head == tail on an insertion */
    /* Output control: sets empty when next_tail == head on a removal */
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            full  <= 1'b0;
            empty <= 1'b1;
        end
        else begin
            if (can_receive) begin
                if (!can_send)
                    full <= next_head == tail;

                empty <= 1'b0;
            end

            if (can_send) begin
                if (!can_receive)
                    empty <= next_tail == head;

                full <= 1'b0;
            end
        end
    end

    /* FSM Control */
    typedef enum logic [6:0] {
        SEND_INIT    = 7'b0000001,
        SEND_REQ     = 7'b0000010,
        SEND_HEADER  = 7'b0000100,
        SEND_SIZE    = 7'b0001000,
        SEND_PAYLOAD = 7'b0010000,
        SEND_END     = 7'b0100000,
        SEND_END2    = 7'b1000000
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
                SEND_SIZE:    flit_cntr <= buffer[tail];
                SEND_PAYLOAD: begin
                    if (data_ack_i && !empty)
                        flit_cntr <= flit_cntr - 1'b1;
                end
                default:      flit_cntr <= '0;
            endcase
        end
    end


    always_comb begin
        case (state)
            SEND_INIT:    next_state = !empty     ? SEND_REQ     : SEND_INIT;
            SEND_REQ:     next_state = req_ack_i  ? SEND_HEADER  : SEND_REQ;
            SEND_HEADER:  next_state = data_ack_i ? SEND_SIZE    : SEND_HEADER;
            SEND_SIZE:    next_state = data_ack_i ? SEND_PAYLOAD : SEND_SIZE;
            SEND_PAYLOAD: next_state = (data_ack_i && !empty && flit_cntr == 1'b1)
                                                                ? SEND_END
                                                                : SEND_PAYLOAD;
            SEND_END:     next_state = SEND_END2;
            SEND_END2:    next_state = SEND_INIT;
            default:      next_state = SEND_INIT;
        endcase
    end

    /* FSM behavior */
    /* Routing request control*/
    assign req_o = (state == SEND_REQ);

    /* Active */
    assign sending_o = (state inside {SEND_HEADER, SEND_SIZE, SEND_PAYLOAD});

    /* Data request control */
    assign data_av_o = (state inside {SEND_HEADER, SEND_SIZE, SEND_PAYLOAD} && !empty);

endmodule
