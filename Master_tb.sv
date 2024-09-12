module Master_tb ();
    
    bit           HCLK;
    logic         HRESETn;
    logic [31:0]  HRDATA;
    logic         HREADY;
    logic         HRESP;

    //Application input signals
    logic [31:0]  data_in;

    logic [31:0]  addr;
    logic         enable;
    logic         busy;

    //Protocol Output signals
    logic [31:0]  HADDR;
    logic         HWRITE;
    logic [2:0]   HSIZE;
    logic [2:0]   HBURST;
    logic [3:0]   HPROT;
    logic [1:0]   HTRANS;
    logic         HMASTLOCK;
    logic [31:0]  HWDATA;

    //Application output signals
    logic [31:0]  data_out;
    logic         data_valid;
    logic         error;
    logic         WAIT;

    logic [31:0] expected_out;

    integer error_counter=0;
    integer correct_counter=0;


    // defining the allowed functions
    /*typedef enum logic [4:0]  {
        //new single function
        new_single_load_byte =0,
        new_single_load_halfword =1,
        new_single_load_word =2,
        new_single_UART_TX =3,
        new_single_store_byte =4,
        new_single_store_halfword =5,
        new_single_store_word =6,
        new_single_UART_RX = 7,
        //new burst function
        new_burst_Load_byte =8,
        new_burst_Load_halfword =9,
        new_burst_Load_word =10,
        new_burst_UART_TX =11,
        new_burst_store_byte=12,
        new_burst_store_halfword =13,
        new_burst_store_word =14,
        new_burst_UART_RX = 15,
        //old single function (end transaction)
        old_single_load_byte = 16,
        old_single_load_halfword = 17,
        old_single_load_word = 18,
        old_single_UART_TX = 19,
        old_single_store_byte = 20,
        old_single_store_halfword = 21,
        old_single_store_word = 22,
        old_single_UART_RX = 23,
        //old burst function (complete transaction)
        old_burst_Load_byte = 24,
        old_burst_Load_halfword = 25,
        old_burst_Load_word = 26,
        old_burst_UART_TX = 27,
        old_burst_store_byte = 28,
        old_burst_store_halfword = 29,
        old_burst_store_word = 30,
        old_burst_UART_RX = 31
    } opcode_e;*/

    typedef enum logic [2:0] {
        load_byte = 0,
        load_halfword = 1,
        load_word = 2,
        UART_TX = 3,
        store_byte = 4,
        store_halfword = 5,
        store_word = 6,
        UART_RX = 7
    } function_e;

    logic [4:0] opcode;

    //instantiate the DUT
    Master DUT (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HRDATA(HRDATA),
        .HREADY(HREADY),
        .HRESP(HRESP),
        .data_in(data_in),
        .addr(addr),
        .opcode(opcode),
        .enable(enable),
        .busy(busy),
        .HADDR(HADDR),
        .HWRITE(HWRITE),
        .HSIZE(HSIZE),
        .HBURST(HBURST),
        .HPROT(HPROT),
        .HTRANS(HTRANS),
        .HMASTLOCK(HMASTLOCK),
        .HWDATA(HWDATA),
        .data_out(data_out),
        .data_valid(data_valid),
        .error(error),
        .WAIT(WAIT)
    );


    //clock gen
    initial begin
        forever begin
            #10 HCLK = ~HCLK;        
        end
    end

    // initial
    initial begin
        rst_check();
        HRESP = 0;
        HREADY = 0;
        HRDATA = 0;
        /*
        //BASIC WRITE 
        addr = 32'd1;
        init_single_transaction(store_word,addr);  
        fork
            begin
                data_in = 32'hAABB_CCDD;
                expected_out = 0;
                end_transaction(store_word,data_in,expected_out);
            end
            begin
                HREADY = 1;
            end    
        join
        */

        /*
        //Basic READ 
        addr = 32'd1;
        init_single_transaction(load_word,addr);  
        fork
            begin
                data_in = 0;
                expected_out = 32'hAABB_CCDD;
                end_transaction(load_word,data_in,expected_out);    
            end
             
            begin
                HREADY=1;
                @(posedge HCLK);
                HRDATA = expected_out;
            end
        join
        */

        /*
        // SINGLE WRITE With wait
        addr = 32'd1;
        init_single_transaction(store_word,addr);
        fork
            begin
                data_in = 32'hAABB_CCDD;
                expected_out = 0;
                end_transaction(store_word,data_in,expected_out);
            end
            begin
                @(negedge HCLK);
                HREADY=0;
                @(negedge HCLK);
                HREADY=1;
            end
        join_any
        */


        /*
        //SINGLE READ with WAIT
        addr = 32'd1;
        init_single_transaction(load_word,addr); 
        fork
            begin
                data_in = 0;
                expected_out = 32'hAABB_CCDD;
                end_transaction(load_word,data_in,expected_out);
            end
            begin
                @(posedge HCLK);
                HREADY=0;
                @(posedge HCLK);
                HREADY=1;
                HRDATA = expected_out;
            end
        join_any
        */
        
        //COnsecutive writes 
        addr = 32'd1;
        init_single_transaction(store_word,addr);  
        fork
            begin
                data_in = 32'hAABB_CCDD;
                expected_out = 0;
                addr = 32'd2;
                new_single_transaction(store_word,addr,data_in,expected_out);        
            end
            begin
                HREADY = 1;
            end
        join
        fork
            begin
                data_in = 32'hABCD_EF00;
                expected_out = 0;
                end_transaction(store_word,data_in,expected_out);        
            end
            begin
                HREADY = 1;
            end
        join
        



        repeat (5) @(negedge HCLK);
        $stop();
        
    
    end


/////////////////TASKS/////////////////////////
    task automatic rst_check();
        HRESETn = 0;
        @(negedge HCLK);
        if (data_out != 0 || data_valid || WAIT) begin
            $display("ERROR: rst check failed");
            error_counter++;
        end 
        else correct_counter++;
        @(negedge HCLK);
        HRESETn = 1;
    endtask //automatic


    task automatic init_single_transaction(input function_e new_func, input [31:0] new_address);        
        enable = 1;
        busy = 0;
        opcode ={1'b1,1'b0,new_func};
        addr = new_address;
        @(negedge HCLK);
    endtask //automatic

    task automatic new_single_transaction(input function_e  new_func, input [31:0] new_address, input [31:0] old_d_in, input [31:0] old_expected_out);
        enable = 1;
        busy = 0;
        opcode = {1'b1,1'b0,new_func};
        addr = new_address;
        data_in = old_d_in;
        @(negedge HCLK);
        if (WAIT) begin
        @(negedge WAIT);    
        end
        if (data_out!= old_expected_out) begin
            $display("ERROR:data_out is not as expected");
            error_counter++;
        end
        else correct_counter++;
       

    endtask //automatic


    task automatic init_burst_transaction(input function_e new_func, input [31:0] new_address);
        @(negedge HCLK);
        enable = 1;
        busy = 0;
        opcode ={1'b1,1'b1,new_func};
        addr = new_address;
    endtask //automatic

    task automatic cont_burst_transaction(input function_e  new_func, input [31:0] new_address, input [31:0] old_d_in, input [31:0] old_expected_out);
        
        enable = 1;
        busy = 0;
        opcode = {1'b0,1'b1,new_func};
        addr = new_address;
        data_in = old_d_in;
        @(negedge HCLK);
        if (WAIT) begin
        @(negedge WAIT);    
        end
        if (data_out != old_expected_out) begin
            $display("ERROR:data_out is not as expected");
            error_counter++;
        end
        else correct_counter++;

    endtask //automatic
    
    task automatic new_burst_transaction(input function_e  new_func, input [31:0] new_address, input [31:0] old_d_in, input [31:0] old_expected_out);
        @(negedge HCLK);
        enable = 1;
        busy = 0;
        opcode = {1'b1,1'b1,new_func};
        addr = new_address;
        data_in = old_d_in;
        if (WAIT) begin
        @(negedge WAIT);    
        end
        else if (data_out!= old_expected_out) begin
            $display("ERROR:data_out is not as expected");
            error_counter++;
        end
        else correct_counter++;

    endtask //automatic

    task automatic end_transaction(input function_e new_func, input[31:0] old_d_in, input [31:0] old_expected_out);
        enable=1;
        busy = 0;
        opcode = {1'b0,1'b0,new_func};
        data_in = old_d_in;
        data_in = old_d_in;
        @(negedge HCLK);
        if (WAIT) begin
        @(negedge WAIT);    
        end
        if (data_out!= old_expected_out) begin
            $display("ERROR:data_out is not as expected");
            error_counter++;
        end
        else correct_counter++;
        
    endtask //automatic





endmodule

