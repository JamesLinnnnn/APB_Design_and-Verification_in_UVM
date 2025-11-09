`timescale 1ns/1ns

import uvm_pkg::*;
`include "uvm_macros.svh"

//Include my design module
`include "APB_master.sv"
`include "APB_slave.sv"
//The order of include files is very important
`include "interface.sv"
`include "sequence_item.sv"
`include "sequence.sv"
`include "sequencer.sv"
`include "APB_coverage.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agent.sv"
`include "scoreboard.sv"
`include "env.sv"
`include "test.sv"

module top;

logic PCLK;

APB_interface intf(.PCLK(PCLK));

apb_top uut (
.PCLK(intf.PCLK),
.PRESETn(intf.PRESETn),
.TRANSFER(intf.TRANSFER),
.read(intf.read),
.write(intf.write),
.apb_write_address(intf.apb_write_address),
.apb_write_data(intf.apb_write_data),
.apb_read_address(intf.apb_read_address),
.PSLVERR(intf.PSLVERR),
  .apb_read_out(intf.apb_read_out),
  .PENABLE(intf.PENABLE),
  .psel1(intf.psel1),
  .pready1(intf.pready1),
  .PWRITE(PWRITE)
);

//--------------------------------------
// Interface setting since interface is not dynamic, not like class
//--------------------------------------
initial begin                   
    // The first parameter(null) plus the second parameter(*, every component) specify the path wherethis handle will be available
    //so those path are able to access the interface
    //the third argument means, totlaly four arguments here
    //Driver and monitor need virtual interface
    uvm_config_db #(virtual APB_interface)::set(null, "*", "vif",intf);
end

initial begin
    run_test("APB_test");
end

initial begin
    PCLK = 0;
    forever begin
        PCLK = ~PCLK;
        #2;
    end
end

initial begin
    #1000000;
    $display("Finish due to too many clock cycles, please check design!\n");
    $finish;
end


endmodule: top