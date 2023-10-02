module HermesNoC
    import HermesPkg::*;
#(
    parameter X_SIZE    = 8,
    parameter Y_SIZE    = 8,
    parameter FLIT_SIZE = 32  /* Minimum: 20 */
)
(
    input   logic clk_i,
    input   logic rst_ni,

    input   logic [X_SIZE * Y_SIZE - 1 : 0] rx_i,
    input   logic [X_SIZE * Y_SIZE - 1 : 0] credit_i,
    input   logic [      FLIT_SIZE - 1 : 0] data_i [X_SIZE * Y_SIZE - 1:0],
    output  logic [X_SIZE * Y_SIZE - 1 : 0] tx_o,
    output  logic [X_SIZE * Y_SIZE - 1 : 0] credit_o,
    output  logic [      FLIT_SIZE - 1 : 0] data_o [X_SIZE * Y_SIZE - 1:0]
);

    logic                     rx            [(NPORT - 1):0][X_SIZE * Y_SIZE - 1:0];
    logic                     credit_i_sig  [(NPORT - 1):0][X_SIZE * Y_SIZE - 1:0];
    logic [(FLIT_SIZE - 1):0] data_i_sig    [(NPORT - 1):0][X_SIZE * Y_SIZE - 1:0];

    logic                     tx            [(NPORT - 1):0][X_SIZE * Y_SIZE - 1:0];
    logic                     credit_o_sig  [(NPORT - 1):0][X_SIZE * Y_SIZE - 1:0];
    logic [(FLIT_SIZE - 1):0] data_o_sig    [(NPORT - 1):0][X_SIZE * Y_SIZE - 1:0];


    genvar gen_x, gen_y;
    generate
        for (gen_x = 0; gen_x < X_SIZE; gen_x++) begin
            for (gen_y = 0; gen_y < Y_SIZE; gen_y++) begin
                localparam index = gen_y*X_SIZE + gen_x;
                HermesRouter #(
                    .ADDRESS    ( (gen_x << 8) | gen_y ),
                    .FLIT_SIZE  (FLIT_SIZE)
                )
                router
                (
                    .clk_i    (       clk_i  ),
                    .rst_ni   (      rst_ni  ),
                    .rx_i     (          rx[index]),
                    .credit_i (credit_i_sig[index]),
                    .data_i   (  data_i_sig[index]),
                    .tx_o     (          tx[index]),
                    .credit_o (credit_o_sig[index]),
                    .data_o   (  data_o_sig[index])
                );

                assign rx[HERMES_LOCAL][index]           = rx_i[index];
                assign credit_i_sig[HERMES_LOCAL][index] = credit_i[index];
                assign data_i_sig[HERMES_LOCAL][index]   = data_i[index];
                assign tx_o[index]                       = tx[HERMES_LOCAL][index];
            end
        end
    endgenerate

endmodule
