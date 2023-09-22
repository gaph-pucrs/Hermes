module HermesCrossbar
#(
    parameter FLIT_SIZE = 32,
    parameter NPORT     = 5
)
(
    input  logic                         req_i     [(NPORT - 1):0],
    input  logic                         credit_i  [(NPORT - 1):0],
    input  logic                         free_i    [(NPORT - 1):0],
    input  logic [($clog2(NPORT) - 1):0] inport_i  [(NPORT - 1):0],
    input  logic [($clog2(NPORT) - 1):0] outport_i [(NPORT - 1):0],
    input  logic [(FLIT_SIZE - 1):0]     data_i    [(NPORT - 1):0],

    output logic                         tx_o      [(NPORT - 1):0],
    output logic                         ack_o     [(NPORT - 1):0],
    output logic [(FLIT_SIZE - 1):0]     data_o    [(NPORT - 1):0]
);

	always_comb begin
        for (int i = 0; i < NPORT; i++) begin
            ack_o[i] = req_i[i] ? credit_i[inport_i[i]] : 1'b0;
            if (!free_i[i]) begin
                tx_o[i]   = req_i[outport_i[i]];
                data_o[i] = data_i[outport_i[i]];
            end
            else begin
                tx_o[i]   = 1'b0;
                data_o[i] = '0;
            end
        end
	end

endmodule
