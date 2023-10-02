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

module HermesCrossbar
    import HermesPkg::*;
#(
    parameter FLIT_SIZE = 32
)
(
    input  logic                         data_av_i [(NPORT - 1):0],
    input  logic                         credit_i  [(NPORT - 1):0],
    input  logic                         free_i    [(NPORT - 1):0],
    input  hermes_port_t                 inport_i  [(NPORT - 1):0],
    input  hermes_port_t                 outport_i [(NPORT - 1):0],
    input  logic [(FLIT_SIZE - 1):0]     data_i    [(NPORT - 1):0],

    output logic                         tx_o      [(NPORT - 1):0],
    output logic                         ack_o     [(NPORT - 1):0],
    output logic [(FLIT_SIZE - 1):0]     data_o    [(NPORT - 1):0]
);

	always_comb begin
        for (int i = 0; i < NPORT; i++) begin
            ack_o[i] = data_av_i[i] ? credit_i[inport_i[i]] : 1'b0;
            if (!free_i[i]) begin
                tx_o[i]   = data_av_i[outport_i[i]];
                data_o[i] = data_i[outport_i[i]];
            end
            else begin
                tx_o[i]   = 1'b0;
                data_o[i] = '0;
            end
        end
	end

endmodule
