interface HermesInterface
#(
    parameter FLIT_SIZE = 32
);

logic                   rx_i;
logic                   eop_i;
logic                   credit_o;
logic [(FLIT_SIZE-1):0] data_i;

logic                     tx_o;
logic                     eop_o;
logic                     credit_i;
logic [(FLIT_SIZE - 1):0] data_o;

modport RX (
    input  rx_i,
    input  eop_i,
    input  data_i,
    output credit_o
);

modport TX (
    input  credit_i,
    output data_o,
    output tx_o,
    output eop_o
);

endinterface
