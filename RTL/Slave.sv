module Slave (
    input bit HCLK,
    input logic HRESETn,

    // Input from master
    input logic HSEL,
    input logic [31:0] HADDR,
    input logic HWRITE,
    input logic [2:0] HSIZE,
    input logic [2:0] HBURST,
    input logic [3:0] HPROT,
    input logic [1:0] HTRANS,
    input logic HMASTLOCK,
    input logic HREADY,
    input logic [31:0] HWDATA,

    // Input from memory
    input logic [31:0] read_data, 

    // output for master
    output logic HREADYOUT,
    output logic HRESP,
    output logic [31:0] HRDATA,

    //output for memory
    output logic write,
    output logic read,
    output logic [31:0] read_addr,
    output logic [31:0] write_addr,
    output logic [31:0] write_data
);


    typedef enum  {
        IDLE,
        NON_SEQ,
        SEQ,
        BUSY,
    } state_e;

    state_e current_state;
    state_e next_state;

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            current_state <= IDLE;
        end
        else begin
            current_state <= next_state;
        end
    end

    //next state logic
    always @(*) begin
        case (current_state)
            IDLE : begin
                if (HSEL && HREADY) begin
                    next_state = NON_SEQ;
                end
                else begin
                    next_state = IDLE;
                end
            end 
            NON_SEQ : begin
                if (HSEL) begin
                    if (HTRANS == SEQ) begin
                        next_state = SEQ;
                    end
                    else if (HTRANS == NON_SEQ) begin
                        next_state = NON_SEQ;
                    end
                    else if (HTRANS == BUSY) begin
                        next_state = BUSY;
                    end
                    else begin
                        next_state = IDLE;
                    end
                    end
                    else begin
                        next_state = IDLE;
                    end
            end
            SEQ : begin
                if (HSEL) begin
                    if (HTRANS == SEQ) begin
                        next_state = SEQ;
                    end
                    else if (HTRANS == NON_SEQ) begin
                        next_state = NON_SEQ;
                    end
                    else if (HTRANS == BUSY) begin
                        next_state = BUSY;
                    end
                    else begin
                        next_state = IDLE;
                    end
                    end
                    else begin
                        next_state = IDLE;
                    end
            end
            BUSY : begin
                if (HSEL) begin
                    if (HTRANS == SEQ) begin
                        next_state = SEQ;
                    end
                    else if (HTRANS == NON_SEQ) begin
                        next_state = NON_SEQ;
                    end
                    else if (HTRANS == BUSY) begin
                        next_state = BUSY;
                    end
                    else begin
                        next_state = IDLE;
                    end
                    end
                    else begin
                        next_state = IDLE;
                    end
            end
            default: 
        endcase
    end

    //output logic
    always @(*) begin
        sample_addr_write = 0;
        case (current_state)
            IDLE:begin
               if (HSEl && HREADY && HTRANS == NON_SEQ) begin
                    if (HWRITE) begin
                        sample_write_addr = 1; 
                    end
                    else begin
                        read_addr = HADDR;
                        read = !HWRITE;    
                    end
                    
                    HREADYOUT = 1;
                    HRESP = 0;
               end 
            end 
            NON_SEQ: begin
                if (HTRANS == SEQ || HTRANS == NON_SEQ) begin
                    if (HWRITE) begin
                        sample_write_addr = 1; 
                    end
                    else begin
                        read_addr = HADDR;
                        read = !HWRITE;    
                    end
                end
                else if (BUSY)begin
                    //////////
                end
                else if (write_phase) begin
                    write_data = HWDATA;
                    write_addr = addr_reg;
                    write = 1;
                end
                else begin
                    HRDATA = read_data;
                end
            end
            SEQ : begin
                if (HTRANS == SEQ || HTRANS == NON_SEQ) begin
                    if (HWRITE) begin
                        sample_write_addr = 1; 
                    end
                    else begin
                        read_addr = HADDR;
                        read = !HWRITE;    
                    end
                end
                else if (BUSY)begin
                    //////////
                end
                else if (write_phase) begin
                    write_data = HWDATA;
                    write_addr = addr_reg;
                    write = 1;
                end
                else begin
                    HRDATA = read_data;
                end
            end
            BUSY : begin
                
            end
            default: 
        endcase
    end

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            addr_reg <= 0;
            write_phase <= 0;
        end
        else if(sample_write_addr) begin
            addr_reg <= HADDR;
            write_phase <= 1;
        end
        else begin
            addr_reg <= 0;
            write_phase <= 0;
        end
    end
endmodule