module Master (
    input bit           HCLK,
    input logic         HRESETn,

    input logic [31:0]  HRDATA,

    input logic         HREADY,
    input logic         HRESP,

    //Application input signals
    input logic [31:0]  data_in,

    
    input logic [3:0]   opcode,
    input logic [31:0]  addr,
    input logic         enable,
    input logic         new_trans,
    input logic         busy,
    

    //Protocol Output signals
    output logic [31:0] HADDR,
    output logic        HWRITE,
    output logic [2:0]  HSIZE,
    output logic [2:0]  HBURST,
    output logic [3:0]  HPROT,
    output logic [1:0]  HTRANS,
    output logic        HMASTLOCK,

    output logic [31:0] HWDATA,
    
    //Application output signals
    output logic [31:0] data_out,
    output logic        data_valid,
    output logic        error,
    output logic        WAIT

);


    typedef enum  { 
        IDLE,
        NON_SEQ,
        SEQ,
        BUSY,
        ERROR
    } states_e;

    states_e current_state;
    states_e next_state;

    logic  [31:0]   data_in_reg;
    logic  [4:0]    opcode_reg;
    logic  [31:0]   addr_reg;
    logic           busy_reg;
    
    

    
    assign HBURST =  {2'b0,opcode_reg[3]};
    assign HWRITE = opcode_reg[2];
    assign HSIZE = opcode_reg[1:0]; // opcode_reg[1:0] = 2'b11 > UART opcode_reg => size = 8 bits
    /*
    opcode_reg => b4          b3      b2      b1 b0
            new_trans   INCR    HWRITE  HSIZE
    */

    assign HADDR = addr_reg;

    assign HMASTLOCK = 0; // not supported
    assign HPROT = 2'b00; //PROT not supported

    

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            data_in_reg <= 0;
            opcode_reg <= 0;
            addr_reg <= 0;
            busy_reg <= 0;
        end
        else begin
            data_in_reg <= data_in;
            opcode_reg <= opcode;
            addr_reg <= addr;
            busy_reg <= busy;
        end
    end




    logic rdata_phase_rem;
    logic wdata_phase_rem;
    logic wdata_rem_flag;
    logic rdata_rem_flag;
    logic data_phase_rem_done;

    logic first_addr_flag; 
    logic first_addr_phase;
    logic first_addr_phase_done;

    logic [4:0] wait_states;

    //state_transition
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            current_state <= IDLE;
        end
        else begin
            current_state <= next_state;
        end
    end
    
    
    //next_state_logic
    always @(*) begin
        wdata_rem_flag =0;
        rdata_rem_flag=0;
        first_addr_flag=0;
        case (current_state)
            IDLE: begin
                if (enable && new_trans) begin
                    next_state = NON_SEQ;
                    first_addr_flag = 1;
                end
                else begin
                    next_state = IDLE;
                end
            end 
            NON_SEQ: begin
                if (!enable) begin
                   next_state = IDLE;
                end
                else if (!HREADY && HRESP) begin
                    next_state = ERROR;
                end
                else if (!HREADY && !first_addr_phase) begin
                    next_state = NON_SEQ;  //WAIT phase
                end
                else if (new_trans) begin
                    next_state = NON_SEQ;
                    wdata_rem_flag = HWRITE;
                    rdata_rem_flag = !HWRITE;
                    
                end
                else if (HBURST)begin
                    next_state = SEQ;
                    wdata_rem_flag = HWRITE;
                    rdata_rem_flag = !HWRITE; 
                end
                else begin
                    next_state = IDLE;
                    wdata_rem_flag = HWRITE;
                    rdata_rem_flag = !HWRITE;
                end
            end
            SEQ: begin
                if (!enable) begin
                   next_state = IDLE;
                end
                else if (!HREADY && HRESP) begin
                    next_state = IDLE;
                end
                else if (!HREADY) begin
                    next_state = SEQ;
                end
                else if (new_trans) begin
                    next_state = NON_SEQ;
                    wdata_rem_flag = HWRITE;
                    rdata_rem_flag = !HWRITE;
                end
                else if (HBURST) begin
                    if(busy_reg) begin
                        next_state = BUSY;    
                    end
                    else begin
                        next_state = SEQ;
                        wdata_rem_flag = HWRITE;
                        rdata_rem_flag = !HWRITE;    
                    end            
                end
                else begin
                    next_state = IDLE;
                    wdata_rem_flag = HWRITE;
                    rdata_rem_flag = !HWRITE;
                end
            end
            BUSY: begin
                if(!busy_reg) begin
                    next_state = SEQ;
                end
                else if (wait_states == 15) begin
                    next_state = IDLE;
                end
                else begin
                    next_state = BUSY;
                end
            end
            ERROR: begin
                if (!enable) begin
                    next_state = IDLE;
                end
                if (HREADY && HRESP) begin
                    if (new_trans) begin
                        next_state = NON_SEQ;
                        first_addr_phase = 1;    
                    end
                    else begin
                        next_state = IDLE;
                    end
               end
               else begin 
                    next_state = ERROR;
               end
            end
        
            default: begin
                next_state = IDLE;
            end 
        endcase
    end
    //output logic
    always @(*) begin      
        HTRANS = 0;
        HWDATA  = 0;
        data_out = 0;
        data_valid = 0;
        WAIT = 0;
        error = 0;
        case (current_state)
            IDLE: begin
                HTRANS = 0;
                if (rdata_phase_rem || wdata_phase_rem ) begin
                    if (!HREADY) begin
                        WAIT = 1;
                        //same as the cycle before application can not change them while wait is asserted

                        //HWRITE data from the last phase application can not change it while wait is asserted
                        if (wdata_phase_rem) begin
                            HWDATA = data_in_reg;  
                        end    
                    end
                    else begin
                        WAIT = 0;
                        //for last phase
                        if (wdata_phase_rem) begin
                            HWDATA = data_in_reg;
                        end
                        else if (rdata_phase_rem) begin
                            data_out = HRDATA;
                            data_valid = 1;
                        end   
                    end    
                end        
            end
                
            NON_SEQ: begin
                HTRANS = 2;
                if (!HREADY) begin
                    WAIT = 1;
                    //same as the cycle before application can not change them while wait is asserted
                    //HWRITE data from the last phase application can not change it while wait is asserted
                    if (wdata_phase_rem) begin
                        HWDATA = data_in_reg;  
                    end
                end
                else begin
                    //for last phase
                    if (wdata_phase_rem) begin
                        HWDATA = data_in_reg;
                    end
                    else if (rdata_phase_rem) begin
                        data_out = HRDATA;
                        data_valid = 1;
                    end
                end
            end
            SEQ: begin
                HTRANS = 3;
                if (!HREADY) begin
                    WAIT = 1;
                    //same as the cycle before application can not change them while wait is asserted
                    
                    //HWRITE data from the last phase application can not change it while wait is asserted
                    if (wdata_phase_rem) begin
                        HWDATA = data_in_reg;  
                    end
                end
                else begin
                    WAIT = 0;
                    //for next phase
            
                    //for last phase
                    if (wdata_phase_rem) begin
                        HWDATA = data_in_reg;
                    end
                    else if (rdata_phase_rem) begin
                        data_out = HRDATA;
                        data_valid = 1;
                    end
                end
            end
            BUSY: begin
                HTRANS = 1;
                  
            end
            ERROR: begin
               HTRANS = 0;
               error = 1;
            end
                    
            default: begin
                HTRANS = 0;
                HWDATA = 0;
                data_out = 0;
                data_valid = 0;
                WAIT = 0;
            end 
        endcase
    end

    //pulse gen 
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            rdata_phase_rem <= 0;
            wdata_phase_rem <= 0;
            data_phase_rem_done <= 0;
        end
        else if(data_phase_rem_done && HREADY && !wdata_rem_flag && !rdata_rem_flag)begin
            rdata_phase_rem <= 0;
            wdata_phase_rem <= 0;
            data_phase_rem_done <= 0;
        end
        else if (wdata_rem_flag) begin
            wdata_phase_rem <=1;
            data_phase_rem_done <= 1;    
        end
        else if (rdata_rem_flag) begin
            rdata_phase_rem <= 1;
            data_phase_rem_done <= 1;
        end
    end

    
    //first address phase 
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            first_addr_phase <=0;
            first_addr_phase_done <=0;
        end
        else if (first_addr_phase_done) begin
            first_addr_phase <= 0;
            first_addr_phase_done <= 0;
        end
        else if (first_addr_flag) begin
            first_addr_phase <= 1;
            first_addr_phase_done <= 1;
        end
    end

    // BUSY_reg states counter
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            wait_states <=0;
        end
        else if (wait_states==15) begin
            wait_states <= 0;
        end
        else if (!HREADY) begin
            wait_states = wait_states + 1;
        end
        else begin
            wait_states <= 0;
        end
    end

endmodule