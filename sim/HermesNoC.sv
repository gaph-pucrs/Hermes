`include "../rtl/HermesPkg.sv"

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

    logic                     rx            [X_SIZE * Y_SIZE - 1:0][(HERMES_NPORT - 1):0];
    logic                     credit_i_sig  [X_SIZE * Y_SIZE - 1:0][(HERMES_NPORT - 1):0];
    logic [(FLIT_SIZE - 1):0] data_i_sig    [X_SIZE * Y_SIZE - 1:0][(HERMES_NPORT - 1):0];

    logic                     tx            [X_SIZE * Y_SIZE - 1:0][(HERMES_NPORT - 1):0];
    logic                     credit_o_sig  [X_SIZE * Y_SIZE - 1:0][(HERMES_NPORT - 1):0];
    logic [(FLIT_SIZE - 1):0] data_o_sig    [X_SIZE * Y_SIZE - 1:0][(HERMES_NPORT - 1):0];


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
            end
        end
    endgenerate

    always_comb begin
        for (int x = 0; x < X_SIZE; x++) begin
            for (int y = 0; y < Y_SIZE; y++) begin
                automatic int index = y*X_SIZE + x;

                rx[index][HERMES_LOCAL]           = rx_i[index];
                credit_i_sig[index][HERMES_LOCAL] = credit_i[index];
                data_i_sig[index][HERMES_LOCAL]   = data_i[index];
                tx_o[index]                       = tx[index][HERMES_LOCAL];
                credit_o[index]                   = credit_o_sig[index][HERMES_LOCAL];
                data_o[index]                     = data_o_sig[index][HERMES_LOCAL];
                
                if (x != X_SIZE - 1) begin
                    rx[index][HERMES_EAST]           = tx[index + 1][HERMES_WEST];
                    credit_i_sig[index][HERMES_EAST] = credit_o_sig[index + 1][HERMES_WEST];
                    data_i_sig[index][HERMES_EAST]   = data_o_sig[index + 1][HERMES_WEST];
                end
                else begin
                    rx[index][HERMES_EAST]           = 1'b0;
                    credit_i_sig[index][HERMES_EAST] = 1'b0;
                    data_i_sig[index][HERMES_EAST]   = '0;
                end

                if (x != 0) begin
                    rx[index][HERMES_WEST]           = tx[index - 1][HERMES_EAST];
                    credit_i_sig[index][HERMES_WEST] = credit_o_sig[index - 1][HERMES_EAST];
                    data_i_sig[index][HERMES_WEST]   = data_o_sig[index - 1][HERMES_EAST];
                end
                else begin
                    rx[index][HERMES_WEST]           = 1'b0;
                    credit_i_sig[index][HERMES_WEST] = 1'b0;
                    data_i_sig[index][HERMES_WEST]   = '0;
                end

                if (y != Y_SIZE - 1) begin
                    rx[index][HERMES_NORTH]           = tx[index + X_SIZE][HERMES_SOUTH];
                    credit_i_sig[index][HERMES_NORTH] = credit_o_sig[index + X_SIZE][HERMES_SOUTH];
                    data_i_sig[index][HERMES_NORTH]   = data_o_sig[index + X_SIZE][HERMES_SOUTH];
                end
                else begin
                    rx[index][HERMES_NORTH]           = 1'b0;
                    credit_i_sig[index][HERMES_NORTH] = 1'b0;
                    data_i_sig[index][HERMES_NORTH]   = '0;
                end

                if (y != 0) begin
                    rx[index][HERMES_SOUTH]           = tx[index - X_SIZE][HERMES_NORTH];
                    credit_i_sig[index][HERMES_SOUTH] = credit_o_sig[index - X_SIZE][HERMES_NORTH];
                    data_i_sig[index][HERMES_SOUTH]   = data_o_sig[index - X_SIZE][HERMES_NORTH];
                end
                else begin
                    rx[index][HERMES_SOUTH]           = 1'b0;
                    credit_i_sig[index][HERMES_SOUTH] = 1'b0;
                    data_i_sig[index][HERMES_SOUTH]   = '0;
                end
            end
        end
    end

endmodule
