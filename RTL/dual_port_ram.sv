module dual_port_ram (
    input bit CLK,
    input logic RST,
    input logic WRITE,
    input logic READ,
    input logic [31:0] WR_ADDR,
    input logic [31:0] WR_DATA,
    input logic [31:0] RD_ADDR,
    output logic [31:0] RD_DATA,
);
    
    reg [31:0] ram_data [0:2**10-1]; // 1024 words of 32 bits each
    
    always @(posedge clk or negedge RST) begin
        if (!RST) begin
            RD_DATA <= 0;
        end else begin
            if (WRITE) begin
                ram_data[WR_ADDR] <= WR_DATA;
            end 
            else if (READ) begin
                RD_DATA <= ram_data[RD_ADDR];
            end
        end
    end

endmodule