module Master (
    input bit           HCLK,
    input logic         HRESETn,

    input logic [31:0]  HRDATA,

    input logic         HREADY,
    input logic         HRESP,

    //Application input signals
    input logic [31:0]  data_in,

    input logic [31:0]  addr,
    input logic         enable,
    input logic         new_trans,
    input logic         ready,
    input logic         wr,
    input logic         inc,

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




    logic rdata_phase_rem;
    logic wdata_phase_rem;
    logic wdata_rem_flag;
    logic rdata_rem_flag;
    logic data_phase_rem_done;

    logic first_addr_phase;

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
        wdata__rem_flag =0;
        rdata_rem_flag=0;
        first_addr_phase=0;
        case (current_state)
            IDLE: begin
                if (enable && new_trans) begin
                    next_state = NON_SEQ;
                    first_addr_phase = 1;
                end
                else begin
                    next_state = IDLE;
                end
            end 
            NON_SEQ: begin
                if (!enable) begin
                   next_state = IDLE;
                end
                else if (!HREADY && !first_addr_phase) begin
                    next_state = NON_SEQ;  //WAIT phase
                end
                else if (!inc && !new_trans) begin
                    next_state = IDLE;
                    wdata_rem_flag = HWRITE;
                    rdata_rem_flag = !HWRITE;
                end
                else if (inc)begin
                    next_state = SEQ;
                    wdata_rem_flag = HWRITE;
                    rdata_rem_flag = !HWRITE; 
                end
                else if (new_trans) begin
                    next_state = NON_SEQ;
                    wdata_rem_flag = HWRITE;
                    rdata_rem_flag = !HWRITE;
                end
            end
            SEQ: begin
                if (!enable) begin
                   next_state = IDLE;
                end
                else if (!HREADY) begin
                    next_state = SEQ;
                end
                else if (new_trans) begin
                    next_state = NON_SEQ;
                end
                else if (!inc) begin
                    next_state = IDLE;
                end
                else begin
                    next_state = SEQ;
                end
            end
            BUSY: begin
                
            end
            ERROR: begin
                
            end
        
            default: begin
                
            end 
        endcase
    end
    //output logic
    always @(*) begin
        HADDR = 0;
        HWRITE =0;
        HSIZE = 0;
        HBURST = 0;
        HPROT = 0;
        HTRANS =0;
        HMASTLOCK = 0;
        HWDATA = 0;
        data_out = 0;
        data_valid= 0;
        WAIT = 0;

        case (current_state)
            IDLE: begin
                HTRANS = 0;
                if (wdata_phase_rem) begin
                    HWDATA = data_in;
                end
                else if (rdata_phase_rem) begin
                    data_out = HRDATA;
                    data_valid = 1;
                end    
            end 
            NON_SEQ: begin
                HBURST = inc;
                if (first_addr_phase) begin
                    //for the next phase
                    HADDR = addr;
                    HWRITE = wr;
                end
                else if (!HREADY) begin
                    WAIT = 1;
                    //same as the cycle before application can not change them while wait is asserted
                    HADDR = addr;
                    HWRITE = wr;
                    //write data from the last phase application can not change it while wait is asserted
                    if (wdata_phase_rem) begin
                        HWDATA = data_in;  
                    end
                end
                else begin
                    //for next phase
                    HADDR = addr;
                    HWRITE = wr;
                    //for last phase
                    if (wdata_phase_rem) begin
                        HWDATA = data_in;
                    end
                    else if (rdata_phase_rem) begin
                        data_out = HRDATA;
                        data_valid = 1;
                    end
                end
            end
            SEQ: begin
                HBURST = inc;
                if (!HREADY) begin
                    WAIT = 1;
                    //same as the cycle before application can not change them while wait is asserted
                    HADDR = addr;
                    HWRITE = wr;
                    //write data from the last phase application can not change it while wait is asserted
                    if (wdata_phase_rem) begin
                        HWDATA = data_in;  
                    end
                end
                else begin
                    //for next phase
                    HADDR = addr;
                    HWRITE = wr;
                    //for last phase
                    if (wdata_phase_rem) begin
                        HWDATA = data_in;
                    end
                    else if (rdata_phase_rem) begin
                        data_out = HRDATA;
                        data_valid = 1;
                    end
                end
            end
            BUSY: begin
                
            end
            ERROR: begin
                
            end
            
            default: begin
                
            end 
        endcase
    end

    
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            rdata_phase_rem <= 0;
            wdata_phase_rem <= 0;
            data_phase_rem_done <= 0;
        end
        else if(data_phase_rem_done && HREADY)begin
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
endmodule