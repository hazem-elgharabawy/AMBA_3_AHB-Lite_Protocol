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
    logic         new_trans;
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

    logic [3:0] opcode;

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
        .new_trans(new_trans),
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
        HREADY = 1;
        HRDATA = 0;
        data_in = 0;
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
        /*
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
        */
        /*
        //COnsecutive reads 
        addr = 32'd1;
        init_single_transaction(load_word,addr);  
        fork
            begin
                expected_out = 32'hAABB_CCDD;
                addr = 32'd2;
                new_single_transaction(load_word,addr,data_in,expected_out);        
            end
            begin
                HREADY=1;
                @(posedge HCLK);
                HRDATA = expected_out;
            end
        join
        fork
            begin
                expected_out = 32'hABCD_EF00;
                end_transaction(store_word,data_in,expected_out);        
            end
            begin
                HREADY=1;
                @(posedge HCLK);
                HRDATA = expected_out;
            end
        join
        */
        /*
        //COnsecutive writes with wait
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
                @(negedge HCLK);
                HREADY=0;
                @(negedge HCLK);
                HREADY=1;
            end
        join
        fork
            begin
                data_in = 32'hABCD_EF00;
                expected_out = 0;
                end_transaction(store_word,data_in,expected_out);        
            end
            begin
                @(negedge HCLK);
                HREADY=0;
                @(negedge HCLK);
                HREADY=1;
            end
        join
        */
        /*
        //COnsecutive reads with 
        addr = 32'd1;
        init_single_transaction(load_word,addr);  
        fork
            begin
                expected_out = 32'hAABB_CCDD;
                addr = 32'd2;
                new_single_transaction(load_word,addr,data_in,expected_out);        
            end
            begin
                @(posedge HCLK);
                HREADY=0;
                @(posedge HCLK);
                HREADY=1;
                HRDATA = expected_out;
            end
        join
        fork
            begin
                expected_out = 32'hABCD_EF00;
                end_transaction(store_word,data_in,expected_out);        
            end
            begin
                @(posedge HCLK);
                HREADY=0;
                @(posedge HCLK);
                HREADY=1;
                HRDATA = expected_out;
            end
        join
        */
        /*
        //basic burst read
        addr = 32'd1;
        init_burst_transaction(store_halfword,addr);
        data_in = 32'hABCD_EF00;
        expected_out = 32'h0000_0000;
        addr = 32'd2;
        cont_burst_transaction(store_word,addr,data_in,expected_out);
        data_in = 32'hAAAAAAAA;
        expected_out = 32'h0000_0000;
        end_transaction(store_halfword,data_in,expected_out);
        */
        /*
        // burst with busy
        addr = 32'd1;
        init_burst_transaction(store_halfword,addr);
        data_in = 32'hABCD_EF00;
        expected_out = 32'h0000_0000;
        
        addr = 32'd2;
        cont_burst_transaction(store_word,addr,data_in,expected_out);
        
        fork
            begin
                data_in = 32'hAAAAAAAA;
                expected_out = 32'h0000_0000;
                addr = 32'd3;
                cont_burst_transaction(store_word,addr,data_in,expected_out);
            end
            begin
                busy = 1'b1;
                @(negedge HCLK);
                busy = 0;        
            end
        join
        data_in = 32'hAAAAAAAA;
        expected_out = 32'h0000_0000;
        end_transaction(store_halfword,data_in,expected_out);
        */

        //error 
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
                HREADY = 0;
                HRESP =1;
                @(posedge HCLK);
                HREADY = 1;
                HRESP =1;
                @(posedge HCLK);
                HREADY = 1;
                HRESP =0;
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
        opcode ={1'b0,new_func};
        new_trans = 1;
        addr = new_address;
        @(negedge HCLK);
    endtask //automatic

    task automatic new_single_transaction(input function_e  new_func, input [31:0] new_address, input [31:0] old_d_in, input [31:0] old_expected_out);
        enable = 1;
        busy = 0;
        opcode ={1'b0,new_func};
        new_trans = 1;
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
        enable = 1;
        busy = 0;
        opcode ={1'b1,new_func};
        new_trans = 1;
        addr = new_address;
        @(negedge HCLK);
    endtask //automatic

    task automatic cont_burst_transaction(input function_e  new_func, input [31:0] new_address, input [31:0] old_d_in, input [31:0] old_expected_out);
        enable = 1;
        if (busy) begin
            @(negedge busy);
        end
        opcode = {1'b1,new_func};
        new_trans = 0;
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
        enable = 1;
        busy = 0;
        opcode = {1'b1,new_func};
        new_trans = 1;
        addr = new_address;
        data_in = old_d_in;
        @(negedge HCLK);
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
        opcode = {1'b0,new_func};
        new_trans = 0;
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

