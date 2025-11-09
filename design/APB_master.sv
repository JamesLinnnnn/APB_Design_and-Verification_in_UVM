// Code your design here
module apb_master(
    input  PCLK,
    input  PRESETn,
    input  PREADY,
    input  TRANSFER,
    input  write,
    input  read, // Write/Read enable
    input  PSLVERR,//slave error signal 
    input  [31:0]PRDATA, //data from slave during read
    input  [31:0]apb_write_data, //Write data
    input  [31:0]apb_write_address, //Write address,
    input  [31:0]apb_read_address, //Read address

    output reg [31:0]PADDR,
    output reg PWRITE,
    output reg [31:0]PWDATA, 
    output reg PSEL1, PSEL2,
    output reg PENABLE,
    output reg [31:0]apb_read_out //data output during read
);

parameter IDLE=2'b00, SETUP=2'b01, ACCESS=2'b10;

reg [1:0]state, next_state;

  always@(posedge PCLK)begin
    if(!PRESETn)begin
        state<=IDLE;
    end
    else begin
        state<=next_state;
    end
end

//State Transitions
always@(*)begin
    case(state)
        IDLE: begin 
            next_state=(TRANSFER)? SETUP: IDLE;
        end

        SETUP: begin
            next_state=ACCESS;
        end

        ACCESS: begin
            if(PREADY)begin
                next_state= (TRANSFER)? SETUP: IDLE;
            end 
            else begin
                next_state=ACCESS;
            end
        end

        default: next_state=IDLE;
    endcase
end

always@(*)begin
    case(state)
        IDLE: begin 
            PSEL1=0; PSEL2=0;
            PENABLE=0;
        end

        SETUP: begin
            PENABLE=0;
            if(read&&!write)begin//Read operation
                PADDR = apb_read_address;
                PSEL1=1;
                PSEL2=0;
                PWRITE=0;
            end
            else if(!read&&write)begin//Write operation
                PADDR=apb_write_address; //Load write address
                PSEL1=1;
                PSEL2=0;
                PWRITE=1; //Set for write operaiton
                PWDATA=apb_write_data; //Load write data
            end
            
        end

        ACCESS: begin
            PENABLE=1;
            if(PREADY)begin
                if(read && !write)//Read operation
                    apb_read_out=PRDATA;
            end
        end
    endcase
end
endmodule