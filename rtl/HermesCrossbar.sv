/**
 * Hermes
 * @file HermesCrossbar.sv
 * 
 * @author Angelo Elias Dal Zotto (angelo.dalzotto@edu.pucrs.br)
 * GAPH - Hardware Design Support Group (https://corfu.pucrs.br/)
 * PUCRS - Pontifical Catholic University of Rio Grande do Sul (http://pucrs.br/)
 * 
 * @date September 2023
 * 
 * @brief SystemVerilog Hermes crossbar module.
 */

`include "HermesPkg.sv"

module HermesCrossbar
    import HermesPkg::*;
#(
    parameter FLIT_SIZE = 32
)
(
    input  logic                         data_av_i [(HERMES_NPORT - 1):0],
    input  logic                         credit_i  [(HERMES_NPORT - 1):0],
    input  logic                         free_i    [(HERMES_NPORT - 1):0],
    input  hermes_port_t                 inport_i  [(HERMES_NPORT - 1):0],
    input  hermes_port_t                 outport_i [(HERMES_NPORT - 1):0],
    input  logic [(FLIT_SIZE - 1):0]     data_i    [(HERMES_NPORT - 1):0],

    output logic                         tx_o      [(HERMES_NPORT - 1):0],
    output logic                         ack_o     [(HERMES_NPORT - 1):0],
    output logic [(FLIT_SIZE - 1):0]     data_o    [(HERMES_NPORT - 1):0]
);

	always_comb begin
        for (int i = 0; i < HERMES_NPORT; i++) begin
            ack_o[i] = data_av_i[i] ? credit_i[outport_i[i]] : 1'b0;
            if (!free_i[i]) begin
                tx_o[i]   = data_av_i[inport_i[i]];
                data_o[i] = data_i[inport_i[i]];
            end
            else begin
                tx_o[i]   = 1'b0;
                data_o[i] = '0;
            end
        end
	end

endmodule
