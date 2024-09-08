module Master (
    input HCLK,
    input HRESETn,

    input [31:0] HRDATA,

    input HREADY,
    input HRESP,

    input [31:0] DATA,
    input [31:0] ADDR,
    input enable,

    output [31:0] HADDR,
    output HWRITE,
    output [2:0] HSIZE,
    output [2:0] HBURST,
    output [3:0] HPROT,
    output [1:0] HTRANS,
    output HMASTLOCK,

    output [31:0] WRDATA,
    
);


    typedef enum  { 
        IDLE,
        ADDR_PHASE,
        WDATA_PHASE,
        RDATA_PHASE,
        WAIT,
    } states_e;

    states_e current_state;
    states_e next_state;

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
        case (current_state)
            IDLE: begin
                if (enable) begin
                    next_state <= ADDR_PHASE;
                end
                else begin
                    next_state <= IDLE;
                end
            end 
            ADDR_PHASE: begin
                if 
            end
            WDATA_PHASE: begin
                
            end
            RDATA_PHASE: begin
                
            end
            WAIT: begin
                
            end
            default: begin
                
            end 
        endcase
    end
    //output logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                
            end 
            ADDR_PHASE: begin
            
            end
            WDATA_PHASE: begin
                
            end
            RDATA_PHASE: begin
                
            end
            WAIT: begin
                
            end
            default: begin
                
            end 
        endcase
    end

    
endmodule