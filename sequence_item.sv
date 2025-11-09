class APB_sequence_item extends uvm_sequence_item;

`uvm_object_utils(APB_sequence_item)

//Inputs of Top module
rand bit PCLK;
rand bit PRESETn; 
rand bit TRANSFER;
rand bit write;
rand bit read;
rand bit [31:0]apb_write_address;
rand bit [31:0]apb_write_data;
rand bit [31:0]apb_read_address;
//Outputs of Top module
bit PSLVERR;
bit [31:0]apb_read_out;
  
constraint c_addr{
    apb_read_address inside {[32'h0000_0000 : 32'h0000_00FF]};
    apb_write_address inside {[32'h0000_0000 : 32'h0000_00FF]};
};
function new(string name = "APB_sequence_item");
    super.new(name);
endfunction

endclass: APB_sequence_item