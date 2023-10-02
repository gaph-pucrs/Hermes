module tb #(parameter int X_SIZE = 4,
            parameter int Y_SIZE = 4) ();

    parameter int NUM_ROUTERS = X_SIZE * Y_SIZE;

    function string RouterAddress(int router);
        int pos_x, pos_y;
        string addr;
    
        pos_x = router % X_SIZE;
        pos_y = router / X_SIZE;
        $sformat(addr, "%0d%0d", pos_x, pos_y);
    
        return addr;
    endfunction

    logic                   rst_n;
    logic                   clk = '0;
    logic [NUM_ROUTERS-1:0] rx = '0;
    logic [NUM_ROUTERS-1:0] credit_o;
    logic [NUM_ROUTERS-1:0] tx;
    logic [NUM_ROUTERS-1:0] credit_i;
    logic [31:0]            data_in  [NUM_ROUTERS-1:0];
    logic [31:0]            data_out [NUM_ROUTERS-1:0];

    always #5 clk = !clk;

    initial begin
        rst_n <= 0;
        #100
        rst_n <= 1;
    end
    
    // local ports to consume data --> always available
    assign credit_i = {NUM_ROUTERS{1'b1}};

    HermesNoC #(
            .X_SIZE(X_SIZE), 
            .Y_SIZE(Y_SIZE)
        ) noc1 (
            .clk_i          (clk),
            .rst_ni         (rst_n),
            .rx_i           (rx),
            .data_i         (data_in),
            .credit_i       (credit_i),
            .tx_o           (tx),
            .data_o         (data_out),
            .credit_o       (credit_o)
    );

    // Declare file handle and line buffer for each router
    string  line_buffer [NUM_ROUTERS-1:0];
    int     file_handle [NUM_ROUTERS-1:0];
    int     log_handle  [NUM_ROUTERS-1:0];

    // Create an initial block to open the files and start the clock
    initial begin
        // Open the files and check for errors
        for (int i = 0; i < NUM_ROUTERS; i++) begin
            automatic string file_name = $sformatf("inputs/%s.txt", RouterAddress(i));
            automatic string log_name  = $sformatf("outputs/%s.txt", RouterAddress(i));

            if ($fopen(file_name, "r") != 0) begin
                file_handle[i] = $fopen(file_name, "r");
                $display("Router %2d: File %s opened successfully.", i, file_name);
            end
            else begin
                $display("Router %2d: File %s does not exist or could not be opened.", i, file_name);
            end

            if ($fopen(log_name, "w") != 0) begin
                log_handle[i] = $fopen(log_name, "w");
                $display("Router %2d: log %s opened successfully.", i, file_name);
            end
        end
    end

    // Declare variables to hold the values from the file
    int time_injection  [NUM_ROUTERS-1:0];
    int target_x        [NUM_ROUTERS-1:0];
    int target_y        [NUM_ROUTERS-1:0];
    int packet_size     [NUM_ROUTERS-1:0];

    logic [NUM_ROUTERS-1:0] printed_rx = '1;
    logic [NUM_ROUTERS-1:0] processed_rx = '1;
    int                     index_rx [NUM_ROUTERS-1:0];

    genvar j;
    for (j = 0; j < NUM_ROUTERS; j++) begin
        always @(posedge clk) begin
            if (rst_n == 1'b0) begin
                data_in[j]  <= '0;
                rx[j]       <= '0;
            end 
            // Wait for the specified time
            else if (int'($time) <= time_injection[j]) begin
                if (printed_rx[j] == 1'b0) begin
                    $display("[%0d] - Router %2d: waiting for injection time (%0d)", $time, j, time_injection[j]);
                    printed_rx[j] <= 1'b1;
                end
            end 
            else if (credit_o[j] == 1'b1) begin
                if (processed_rx[j] == 1'b0) begin
                    if (index_rx[j] == 0) begin
                        automatic int pos_x = j % X_SIZE;
                        automatic int pos_y = j / X_SIZE;

                        data_in[j]  <= {pos_x[7:0], pos_y[7:0], target_x[j][7:0], target_y[j][7:0]};
                        rx[j]       <= 1;
                        $display("[%0d] - Router %2d: SENDING PACKET %d -> Size %0d -> from (%0d, %0d) to (%0d, %0d)", $time, j, (j * 100_000) + time_injection[j], packet_size[j], pos_x, pos_y, target_x[j], target_y[j]);
                    end
                    else if (index_rx[j] == 1) begin
                        data_in[j]  <= {packet_size[j]};
                    end
                    else if (index_rx[j] == 2) begin
                        data_in[j]  <= {int'($time)};
                    end
                    else if (index_rx[j] == 3) begin
                        automatic logic[31:0] packetNumber = {(j * 100_000) + time_injection[j]};
                        data_in[j]  <= packetNumber;
                    end
                    else if (index_rx[j] < packet_size[j] + 2) begin
                        data_in[j]  <= {index_rx[j] - 1};
                    end
                    else begin
                        processed_rx[j] <= 1;
                        rx[j]           <= 0;
                    end

                    index_rx[j] <= index_rx[j] + 1;
                end
                // Read a line from the file and assign values to variables
                else if (file_handle[j] != 0 && !$feof(file_handle[j])) begin
                    $fgets(line_buffer[j], file_handle[j]);
                    $sscanf(line_buffer[j], "%d %d %d %d", time_injection[j], target_x[j], target_y[j], packet_size[j]);
                    $display("[%0d] - Router %2d: time_injection = %0d, target_x = %0d, target_y = %0d, packet_size = %0d", $time, j, time_injection[j], target_x[j], target_y[j], packet_size[j]);
                    
                    index_rx[j]     <= 0;
                    processed_rx[j] <= 0;
                    printed_rx[j]   <= 0;
                end
            end
        end
    end

    int          index_tx   [NUM_ROUTERS-1:0];
    int          size_tx    [NUM_ROUTERS-1:0];
    logic [15:0] source_tx  [NUM_ROUTERS-1:0];

    genvar k;
    for (k = 0; k < NUM_ROUTERS; k++) begin
        always @(posedge clk) begin
            if (tx[k] == 1'b1 && credit_i[k] == 1'b1) begin
                if (index_tx[k] == 0) begin
                    source_tx[k] <= data_out[k][31:16];
                end
                else if (index_tx[k] == 1) begin
                    size_tx[k] <= int'(data_out[k]);
                end
                else if (index_tx[k] == 2) begin
                    $display("[%0d] - Router %2d - Received Package: source = %4h packet_size = %0d latency = %0d", $time, k, source_tx[k], size_tx[k], int'($time) - int'(data_out[k]));
                    $fwrite(log_handle[k],"%4h %0d %0d\n", source_tx[k], size_tx[k], int'($time) - int'(data_out[k]));
                end

                index_tx[k] <= index_tx[k] + 1;
            end
            else begin
                index_tx[k] <= 0;
            end
        end
    end

    // Create a final block to close the files
    final begin
        for (int i = 0; i < NUM_ROUTERS; i++) begin
            if (file_handle[i] != 0) begin
                $fclose(file_handle[i]);
            end

            if (log_handle[i] != 0) begin
                $fclose(log_handle[i]);
            end
        end
    end
endmodule