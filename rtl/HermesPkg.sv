/**
 * Hermes
 * @file HermesPkg.sv
 * 
 * @author Angelo Elias Dal Zotto (angelo.dalzotto@edu.pucrs.br)
 * GAPH - Hardware Design Support Group (https://corfu.pucrs.br/)
 * PUCRS - Pontifical Catholic University of Rio Grande do Sul (http://pucrs.br/)
 * 
 * @date September 2023
 * 
 * @brief SystemVerilog Hermes package.
 */

`ifndef HERMES_PKG
`define HERMES_PKG

package HermesPkg;

    parameter HERMES_NPORT = 5;
    typedef enum logic [$clog2(HERMES_NPORT) - 1 : 0] {
		HERMES_EAST,
		HERMES_WEST,
		HERMES_NORTH,
		HERMES_SOUTH,
		HERMES_LOCAL
    } hermes_port_t;

endpackage

`endif
