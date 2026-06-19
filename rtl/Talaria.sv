module Talaria 
    import HermesPkg::*;
#(
    parameter logic [15:0] ADDRESS     = 0,
    parameter              BUFFER_SIZE = 8, /* Power of 2  */
    parameter              FLIT_SIZE   = 32 /* Minimum: 20 */
)(
    input logic clk,
    input logic rst_n,
    // FIX 1: Array dimensions go after the name
    HermesInterface.RX rx_intf [HERMES_NPORT-1:0],
    HermesInterface.TX tx_intf [HERMES_NPORT-1:0]
);

// FIX 2: Create intermediate packed arrays to connect the interface to the router
// RX Vectors
logic                 rx_i_vec     [HERMES_NPORT-1:0];
logic                 eop_i_vec    [HERMES_NPORT-1:0];
logic                 credit_o_vec [HERMES_NPORT-1:0];
logic [FLIT_SIZE-1:0] data_i_vec   [HERMES_NPORT-1:0];

// TX Vectors
logic                 tx_o_vec     [HERMES_NPORT-1:0];
logic                 eop_o_vec    [HERMES_NPORT-1:0];
logic                 credit_i_vec [HERMES_NPORT-1:0];
logic [FLIT_SIZE-1:0] data_o_vec   [HERMES_NPORT-1:0];

// Unpack the interfaces into the vectors
generate
    for (genvar i = 0; i < HERMES_NPORT; i++) begin : gen_intf_map
        // RX assignments
        assign rx_i_vec[i]       = rx_intf[i].rx_i;
        assign eop_i_vec[i]      = rx_intf[i].eop_i;
        assign rx_intf[i].credit_o = credit_o_vec[i];
        assign data_i_vec[i]     = rx_intf[i].data_i;

        // TX assignments
        assign tx_intf[i].tx_o   = tx_o_vec[i] ;
        assign tx_intf[i].eop_o  = eop_o_vec[i] ;
        assign tx_intf[i].data_o = data_o_vec[i] ;
        assign credit_i_vec[i]   = tx_intf[i].credit_i;
    end
endgenerate

HermesRouter #(
    .ADDRESS    (ADDRESS),
    .BUFFER_SIZE(BUFFER_SIZE),
    .FLIT_SIZE  (FLIT_SIZE)
) u_router (
    .clk_i      (clk),
    .rst_ni     (rst_n),
    .rx_i       (rx_i_vec),
    .eop_i      (eop_i_vec),
    .credit_o   (credit_o_vec),
    .data_i     (data_i_vec),

    .tx_o       (tx_o_vec),
    .eop_o      (eop_o_vec),
    .credit_i   (credit_i_vec),
    .data_o     (data_o_vec)
);

endmodule
