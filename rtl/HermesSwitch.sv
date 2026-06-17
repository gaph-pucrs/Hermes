/**
 * Hermes
 * @file HermesSwitch.sv
 * 
 * @author Angelo Elias Dal Zotto (angelo.dalzotto@edu.pucrs.br)
 * GAPH - Hardware Design Support Group (https://corfu.pucrs.br/)
 * PUCRS - Pontifical Catholic University of Rio Grande do Sul (http://pucrs.br/)
 * 
 * @date September 2023
 * 
 * @brief SystemVerilog Hermes switch module.
 */

`include "HermesPkg.sv"

module HermesSwitch
    import HermesPkg::*;
#(
    parameter logic [15:0] ADDRESS   = 0,
    parameter              FLIT_SIZE = 32 /* Minimum: 20 */
)
(
    input  logic clk_i,
    input  logic rst_ni,

    input  logic                     req_i     [(HERMES_NPORT - 1):0],
    input  logic                     sending_i [(HERMES_NPORT - 1):0],
    input  logic [(FLIT_SIZE - 1):0] data_i    [(HERMES_NPORT - 1):0],

    output logic                     ack_o     [(HERMES_NPORT - 1):0],
    output logic                     free_o    [(HERMES_NPORT - 1):0],
    output hermes_port_t             inport_o  [(HERMES_NPORT - 1):0],
    output hermes_port_t             outport_o [(HERMES_NPORT - 1):0]
);

    localparam NDIM = 3;

    /* FSM Control */
    typedef enum logic [1:0] {
        RT_ROUTE  = 2'b01,
        RT_SWITCH = 2'b10
    } fsm_t;

    fsm_t state;
    fsm_t next_state;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            state <= RT_ROUTE;
        else
            state <= next_state;
    end

    logic has_req;
    always_comb begin
        has_req = 1'b0;
        for (int i = 0; i < HERMES_NPORT; i++)
            has_req |= req_i[i];
    end

    hermes_port_t sel_dir;
    logic [($clog2(NDIM - 1)):0] dim;
    hermes_port_t dirs [2:0];

    /* FSM transitions */
    always_comb begin
        case (state)
            RT_ROUTE:  next_state = has_req && free_o[dirs[dim]] ? RT_SWITCH  : RT_ROUTE;
            RT_SWITCH: next_state = RT_ROUTE;
            default:   next_state = RT_ROUTE;
        endcase
    end

    /* Arbitration signals */
    hermes_port_t sel_port;
    hermes_port_t next_port;

    /* Round-robin */
    always_comb begin
        /* From sel_port until the last port */
        next_port = sel_port;
        for(int i = 0; i < HERMES_NPORT; i++) begin
            if (i <= sel_port) 
                continue;

            if (req_i[i]) begin
                next_port = hermes_port_t'(i);
                break;
            end
        end
        
        /* If not found, start again from 0 until sel_port */
        if (next_port == sel_port) begin
            for(int i = 0; i < HERMES_NPORT; i++) begin
                if (req_i[i]) begin
                    next_port = hermes_port_t'(i);
                    break;
                end
            end
        end
    end

    /* Arbitration control */
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            sel_port <= hermes_port_t'('0);
        else if (state == RT_ROUTE)
            sel_port <= next_port;
    end

    /* Routing control */
    localparam logic [7:0] ADDRS [1:0] = {ADDRESS[7:0], ADDRESS[15:8]};

    logic [15:0] target;
    assign target = data_i[next_port][15:0];

    logic [7:0] tgts [1:0];
    assign tgts[0] = target[15:8];
    assign tgts[1] = target[7:0];

    logic force_io;
    assign force_io = data_i[next_port][FLIT_SIZE - 1];

    hermes_port_t force_port;
    assign force_port = hermes_port_t'({1'b0, data_i[next_port][(FLIT_SIZE - 2):(FLIT_SIZE - $clog2(HERMES_NPORT))]});   

    /* Decide which dimension (x,y, or local) routing will take */
    always_comb begin
        dim = $clog2(NDIM)'(NDIM - 1);
        for (int i = 0; i < NDIM - 1; i++) begin
            if (ADDRS[i] != tgts[i]) begin
                dim = $clog2(NDIM)'(i);
                break;
            end
        end
    end

    assign dirs[0] = (tgts[0] > ADDRS[0]) ? HERMES_EAST  : HERMES_WEST;
    assign dirs[1] = (tgts[1] > ADDRS[1]) ? HERMES_NORTH : HERMES_SOUTH;
    assign dirs[2] = force_io ? force_port : HERMES_LOCAL;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            sel_dir <= HERMES_LOCAL;
        else if (state == RT_ROUTE)
            sel_dir <= dirs[dim];
    end

    /* Active port control */
    logic sending_r [(HERMES_NPORT - 1):0];
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            for (int i = 0; i < HERMES_NPORT; i++)
                sending_r[i] <= '0;
        else
            sending_r <= sending_i;
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            for (int i = 0; i < HERMES_NPORT; i++)
                free_o[i] <= 1'b1;
        end
        else begin
            if (state == RT_SWITCH)
                free_o[sel_dir] <= 1'b0;

            for (int i = 0; i < HERMES_NPORT; i++) begin
                if (sending_r[i] && !sending_i[i])
                    free_o[outport_o[i]] <= 1'b1;
            end
        end
    end

    /* Mux control */
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            for (int i = 0; i < HERMES_NPORT; i++) begin
                outport_o[i] <= HERMES_EAST;
                inport_o[i]  <= HERMES_EAST;
            end
        end
        else if (state == RT_SWITCH) begin
            outport_o[sel_port] <= sel_dir;
            inport_o[sel_dir]   <= sel_port;
        end
    end

    /* Acknowledge control */
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            for (int i = 0; i < HERMES_NPORT; i++)
                ack_o[i] <= 1'b0;
        end
        else begin
            unique case (state)
                RT_SWITCH: ack_o[sel_port] <= 1'b1;
                default:   ack_o[sel_port] <= 1'b0;
            endcase
        end
    end

endmodule
