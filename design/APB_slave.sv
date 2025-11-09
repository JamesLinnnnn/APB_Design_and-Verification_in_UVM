module apb_slave(
    input PCLK,
    input PRESETn,
    input PSEL,
    input PENABLE,
    input PWRITE,
    input [31:0]PADDR,
    input [31:0]PWDATA,
    
    output reg [31:0]PRDATA,
    output reg PREADY,
    output reg PSLVERR
);

reg [31:0]memory [255:0];
reg [31:0]addr_reg;

assign PRDATA=memory[addr_reg];
always@(*)begin
    if(!PRESETn)begin
        PREADY=1'b0;
        PSLVERR=1'b0;
        addr_reg=32'b0;
    end
    else begin

        if(PSEL)begin
            if(!PWRITE&&!PENABLE) PREADY=0;
            //Handle Read Operation
            else begin 
                if(!PWRITE&&PENABLE)begin
                    
                    if(PADDR<32'd256)begin
                        addr_reg=PADDR;
                        PREADY=1'b1;
                    end
                    else begin
                        PSLVERR=1'b1;
                        PREADY=1'b1;
                    end
                end
                else if(PWRITE&&!PENABLE) PREADY=0;
                //Handle Write Operation
                else if(PWRITE&&PENABLE)begin
                    
                    if(PADDR<32'd256)begin
                        memory[PADDR]=PWDATA;
                        PREADY=1'b1;
                    end

                    else begin 
                        PSLVERR=1'b1;
                        PREADY=1'b1;
                    end
                end
            end
        end
    end 
end
endmodule