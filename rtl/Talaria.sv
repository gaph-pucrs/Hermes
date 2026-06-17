module Talaria 
    import HermesPkg::*;
#(
    parameter logic [15:0] ADDRESS     = 0,
    parameter              BUFFER_SIZE = 8, /* Power of 2  */
    parameter              FLIT_SIZE   = 32 /* Minimum: 20 */
)(
    input logic clk,
    input logic rst_n,
    HermesInterface.RX [HERMES_NPORT]rx_intf,
    HermesInterface.TX [HERMES_NPORT]tx_intf
);

HermesRouter #(
    .ADDRESS    (ADDRESS),
    .BUFFER_SIZE(BUFFER_SIZE),
    .FLIT_SIZE  (FLIT_SIZE)
) u_router (
    .rx_i       (rx_intf.rx_i),
    .eop_i      (rx_intf.eop_i),
    .credit_o   (rx_intf.credit_o),
    .data_i     (rx_intf.data_i),

    .tx_o       (tx_intf.tx_o),
    .eop_o      (tx_intf.eop_o),
    .credit_i   (tx_intf.credit_i),
    .data_o     (tx_intf.data_o)
);

endmodule