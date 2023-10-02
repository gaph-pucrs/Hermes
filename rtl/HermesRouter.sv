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

module HermesRouter
    import HermesPkg::*;
#(
    parameter logic [15:0] ADDRESS = 0,
    parameter              BUFFER_SIZE = 8,
    parameter              FLIT_SIZE = 32 /* Minimum: 20 */
)
(
    input  logic clk_i,
    input  logic rst_ni,

    input  logic                     rx_i     [(NPORT - 1):0],
    input  logic                     credit_i [(NPORT - 1):0],
    input  logic [(FLIT_SIZE - 1):0] data_i   [(NPORT - 1):0],

    output logic                     tx_o     [(NPORT - 1):0],
    output logic                     credit_o [(NPORT - 1):0],
    output logic [(FLIT_SIZE - 1):0] data_o   [(NPORT - 1):0]
);

    logic                     req      [(NPORT - 1):0];
    logic                     data_av  [(NPORT - 1):0];
    logic                     sending  [(NPORT - 1):0];
    logic                     req_ack  [(NPORT - 1):0];
    logic                     data_ack [(NPORT - 1):0];
    logic [(FLIT_SIZE - 1):0] data     [(NPORT - 1):0];

    genvar port;
    generate
        for (port = 0; port < NPORT; port++) begin
            HermesBuffer #(
                .BUFFER_SIZE(BUFFER_SIZE),
                .FLIT_SIZE  (FLIT_SIZE)
            )
            buffer
            (
                .clk_i      (   clk_i      ),
                .rst_ni     (  rst_ni      ),
                .rx_i       (    rx_i[port]),
                .req_ack_i  ( req_ack[port]),
                .data_ack_i (data_ack[port]),
                .data_i     (  data_i[port]),
                .req_o      (     req[port]),
                .credit_o   (credit_o[port]),
                .data_av_o  ( data_av[port]),
                .sending_o  ( sending[port]),
                .data_o     (    data[port])
            );
        end
    endgenerate;

    logic         free    [(NPORT - 1):0];
    hermes_port_t inport  [(NPORT - 1):0];
    hermes_port_t outport [(NPORT - 1):0];

    HermesCrossbar #(
        .FLIT_SIZE(FLIT_SIZE)
    )
    crossbar
    (
        .data_av_i ( data_av),
        .credit_i  (credit_i),
        .free_i    (    free),
        .inport_i  (  inport),
        .outport_i ( outport),
        .data_i    (    data),
        .tx_o      (    tx_o),
        .ack_o     (data_ack),
        .data_o    (  data_o)
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
