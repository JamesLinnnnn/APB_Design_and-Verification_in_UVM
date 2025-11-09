module apb_top(
    input PCLK,
    input PRESETn,
    input TRANSFER,
    input write,
    input read,
    input [31:0]apb_write_address,
    input [31:0]apb_write_data,
    input [31:0]apb_read_address,
    output PSLVERR,
  output [31:0]apb_read_out,
    output PENABLE,
  output psel1,
  output pready1,
  output PWRITE
);

//Internal Signals to connect master and slaves
//wire PENABLE; //Enable signal
wire PWRITE; //Write Contriol Signal
wire [31:0]PADDR;/// Address Bus
wire [31:0]PWDATA; //Write data bus
wire [31:0]prdata1, prdata2; //Read data from slaves
//wire pready1, pready2, pready;
//wire psel1, psel2;

apb_master master_uut(
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .TRANSFER(TRANSFER),
    .read(read),
    .write(write),
    .apb_write_address(apb_write_address),
    .apb_read_address(apb_read_address),
    .apb_write_data(apb_write_data),
    .PREADY(pready),
    .PSLVERR(PSLVERR),
    .PRDATA(prdata1),
    .PSEL1(psel1),
    .PSEL2(psel2),
    .PENABLE(PENABLE),
    .PADDR(PADDR),
    .PWRITE(PWRITE),
    .PWDATA(PWDATA),
    .apb_read_out(apb_read_out)
);


apb_slave slave_one(
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PSEL(psel1),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR[31:0]),
    .PWDATA(PWDATA),
    .PRDATA(prdata1),
    .PREADY(pready1),
    .PSLVERR(PSLVERR)
);

// apb_slave slave_two(
//     .PCLK(PCLK),
//     .PRESETn(PRESETn),
//     .PSEL(psel2),
//     .PENABLE(PENABLE),
//     .PWRITE(PWRITE),
//     .PADDR(PADDR[31:0]),
//     .PWDATA(PWDATA),
//     .PRDATA(prdata2),
//     .PREADY(pready2),
//     .PSLVERR(PSLVERR)
// );

assign pready = (psel1 && pready1);
endmodule// Code your design here
