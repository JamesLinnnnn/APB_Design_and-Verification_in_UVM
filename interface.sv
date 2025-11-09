interface APB_interface(input logic PCLK);


// For sending transactions into DUT by driver
logic PRESETn;
logic TRANSFER;
logic write;
logic read;
logic [31:0]apb_write_address;
logic [31:0]apb_write_data;
logic [31:0]apb_read_address;


//For receiving transactions from DUT by monitor
logic PSLVERR;
logic [31:0]apb_read_out;
logic PENABLE;

logic psel1;
logic pready1;
logic PWRITE;
  
      modport DRIVER_MP (
        input PCLK, PRESETn, TRANSFER, write, read, apb_write_address, apb_write_data, apb_read_address
    );

    modport MONITOR_MP (
        input PCLK, PENABLE, psel1, pready1, apb_read_out
    );

endinterface: APB_interface