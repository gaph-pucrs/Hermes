module HermesNoC 
#(
    parameter X_SIZE = 8,
    parameter Y_SIZE = 8
)
(
    input logic clk_i,
    input logic rst_ni,

    input logic [X_SIZE * Y_SIZE - 1 : 0] rx_i,
    input logic [X_SIZE * Y_SIZE - 1 : 0] credit_i,
    input logic [FLIT_SIZE - 1:0] data_i [X_SIZE * Y_SIZE - 1:0],
    output logic [X_SIZE * Y_SIZE - 1 : 0] tx_o,
    output logic [X_SIZE * Y_SIZE - 1 : 0] credit_o,
    output logic [FLIT_SIZE - 1:0] data_o [X_SIZE * Y_SIZE - 1:0]
);
    logic                     rx     [(NPORT - 1):0][X_SIZE * Y_SIZE - 1:0];
    logic                     credit_i_sig [(NPORT - 1):0][X_SIZE * Y_SIZE - 1:0];
    logic [(FLIT_SIZE - 1):0] data_i_sig   [(NPORT - 1):0][X_SIZE * Y_SIZE - 1:0];

    logic                     tx     [(NPORT - 1):0][X_SIZE * Y_SIZE - 1:0];
    logic                     credit_o_sig [(NPORT - 1):0][X_SIZE * Y_SIZE - 1:0];
    logic [(FLIT_SIZE - 1):0] data_o_sig   [(NPORT - 1):0][X_SIZE * Y_SIZE - 1:0];


    genvar gen_x, gen_y;
    generate
        for (gen_x = 0; x < X_SIZE; x++) begin
            for (gen_y = 0; y < Y_SIZE; y++) begin
                HermesRouter #(
                    .ADDRESS( (gen_x << 8) | gen_y )
                )
                router
                (
                    .clk_i    (       clk_i  ),
                    .rst_ni   (      rst_ni  ),
                    .rx_i     (          rx[]),
                    .credit_i (credit_i_sig[]),
                    .data_i   (  data_i_sig[]),
                    .tx_o     (          tx[]),
                    .credit_o (credit_o_sig[]),
                    .data_o   (  data_o_sig[])
                );

                assign rx[HERMES_LOCAL][]           = rx_i[];
                assign credit_i_sig[HERMES_LOCAL][] = credit_i[];
                assign data_i_sig[HERMES_LOCAL][]   = data_i[];
                assign tx_o[] = tx[HERMES_LOCAL][];
            end
        end
    endgenerate

endmodule
