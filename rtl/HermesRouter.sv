/**
 * Hermes
 * @file HermesRouter.sv
 * 
 * @author Angelo Elias Dal Zotto (angelo.dalzotto@edu.pucrs.br)
 * GAPH - Hardware Design Support Group (https://corfu.pucrs.br/)
 * PUCRS - Pontifical Catholic University of Rio Grande do Sul (http://pucrs.br/)
 * 
 * @date September 2023
 * 
 * @brief SystemVerilog Hermes router module (router top).
 */

`include "HermesPkg.sv"

module HermesRouter
    import HermesPkg::*;
#(
    parameter logic [15:0] ADDRESS     = 0,
    parameter              BUFFER_SIZE = 8, /* Power of 2  */
    parameter              FLIT_SIZE   = 32 /* Minimum: 20 */
)
(
    input  logic clk_i,
    input  logic rst_ni,

    input  logic                     rx_i     [(HERMES_NPORT - 1):0],
    input  logic                     eop_i    [(HERMES_NPORT - 1):0],
    output logic                     credit_o [(HERMES_NPORT - 1):0],
    input  logic [(FLIT_SIZE - 1):0] data_i   [(HERMES_NPORT - 1):0],

    output logic                     tx_o     [(HERMES_NPORT - 1):0],
    output logic                     eop_o    [(HERMES_NPORT - 1):0],
    input  logic                     credit_i [(HERMES_NPORT - 1):0],
    output logic [(FLIT_SIZE - 1):0] data_o   [(HERMES_NPORT - 1):0]
);

    
    logic                     data_av  [(HERMES_NPORT - 1):0];
    logic                     eop      [(HERMES_NPORT - 1):0];
    logic                     data_ack [(HERMES_NPORT - 1):0];
    logic [(FLIT_SIZE - 1):0] data     [(HERMES_NPORT - 1):0];
    
    logic                     req      [(HERMES_NPORT - 1):0];
    logic                     req_ack  [(HERMES_NPORT - 1):0];
    logic                     sending  [(HERMES_NPORT - 1):0];

    genvar port;
    generate
        for (port = 0; port < HERMES_NPORT; port++) begin
            HermesBuffer #(
                .BUFFER_SIZE(BUFFER_SIZE),
                .FLIT_SIZE  (FLIT_SIZE  )
            )
            buffer
            (
                .clk_i      (   clk_i      ),
                .rst_ni     (  rst_ni      ),
                .rx_i       (    rx_i[port]),
                .eop_i      (   eop_i[port]),
                .credit_o   (credit_o[port]),
                .data_i     (  data_i[port]),
                .data_av_o  ( data_av[port]),
                .eop_o      (     eop[port]),
                .data_ack_i (data_ack[port]),
                .data_o     (    data[port]),
                .req_o      (     req[port]),
                .req_ack_i  ( req_ack[port]),
                .sending_o  ( sending[port])
            );
        end
    endgenerate;

    logic         free    [(HERMES_NPORT - 1):0];
    hermes_port_t inport  [(HERMES_NPORT - 1):0];
    hermes_port_t outport [(HERMES_NPORT - 1):0];

    HermesCrossbar #(
        .FLIT_SIZE(FLIT_SIZE)
    )
    crossbar
    (
        .data_av_i ( data_av),
        .eop_i     (     eop),
        .ack_o     (data_ack),
        .data_i    (    data),
        .tx_o      (    tx_o),
        .eop_o     (   eop_o),
        .credit_i  (credit_i),
        .data_o    (  data_o),
        .free_i    (    free),
        .inport_i  (  inport),
        .outport_i ( outport)        
    );

    HermesSwitch #(
        .ADDRESS(ADDRESS),
        .FLIT_SIZE(FLIT_SIZE)
    )
    switch
    (
        .clk_i     (  clk_i),
        .rst_ni    ( rst_ni),
        .req_i     (    req),
        .sending_i (sending),
        .data_i    (   data),
        .ack_o     (req_ack),
        .free_o    (   free),
        .inport_o  ( inport),
        .outport_o (outport)
    );

endmodule
