`include "uvm_macros.svh"     // ensure UVM macros are visible
`uvm_analysis_imp_decl(_mon)
`uvm_analysis_imp_decl(_drv)

class APB_scoreboard extends uvm_scoreboard;

`uvm_component_utils(APB_scoreboard)


//Receive port with monitor
uvm_analysis_imp_mon #(APB_sequence_item, APB_scoreboard) scoreboard_port;
//Receive Port with Driver
uvm_analysis_imp_drv #(APB_sequence_item, APB_scoreboard) drv2sb_port;

//Queue
APB_sequence_item monitor_transactions[$];
APB_sequence_item driver_transactions[$];
  bit [31:0]read_address_q[$];
  bit [31:0] expected_addr;


// Declare a persistent memory at class scope (outside the function)
logic [31:0] memory [255:0];


//Constructor
function new(string name = "APB_scoreboard", uvm_component parent);
    super.new(name, parent);
    `uvm_info("SCOREBOARD_CLASS", "In constructor", UVM_HIGH)
endfunction: new

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("SCOREBOARD_CLASS", "In build phase", UVM_HIGH)

    scoreboard_port = new("scoreboard_port", this);
    drv2sb_port = new("drv2sb_port", this);

endfunction: build_phase

function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("SCOREBOARD_CLASS", "In connect phase", UVM_HIGH)
endfunction: connect_phase

//Write item in Queues
  function void write_mon(APB_sequence_item item);
    monitor_transactions.push_back(item);
    
endfunction: write_mon

  function void write_drv(APB_sequence_item item);
    	   if (item.write && !item.read) begin
             driver_transactions.push_back(item);
        read_address_q.push_back(item.apb_write_address); 
    end
    
    
endfunction: write_drv


task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("SCOREBOARD_CLASS", "In build phase", UVM_HIGH)
    
    forever begin
        APB_sequence_item current_trans_mon;
        APB_sequence_item current_trans_drv;
        wait(driver_transactions.size()!=0);
        current_trans_drv = driver_transactions.pop_front();
  
            update_mem(current_trans_drv.apb_write_address, current_trans_drv.apb_write_data);
    

      	wait((monitor_transactions.size()!=0));
        current_trans_mon = monitor_transactions.pop_front();
       expected_addr = read_address_q.pop_front();
      compare(current_trans_mon, expected_addr);
    
    end
endtask: run_phase


  function void compare(APB_sequence_item item, bit [31:0] expected_addr);
    
    bit [31:0]expected_read_data;
  expected_read_data = get_expected(expected_addr);
    if(expected_read_data!= item.apb_read_out)begin
      `uvm_error("Compare", $sformatf("Wrong Read Out Data!!!Actual = %0h, Expected = %0h", item.apb_read_out, expected_read_data));
    end
  else begin
    `uvm_info("Compare", $sformatf("Correct Read Out Data!!! Actual = %0h, Expected = %0h",  item.apb_read_out, expected_read_data), UVM_LOW);
  end
endfunction: compare



// Updates expected model when write occurs
function void update_mem(input logic [31:0] addr, input logic [31:0] wdata);
  memory[addr] = wdata;
endfunction

// Reads expected value for comparison
function [31:0] get_expected(input logic [31:0] addr);
  return memory[addr];
endfunction



endclass: APB_scoreboard