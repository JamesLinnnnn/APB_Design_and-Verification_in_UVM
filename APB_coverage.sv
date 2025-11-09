class APB_coverage extends uvm_subscriber #(APB_sequence_item);

`uvm_component_utils(APB_coverage)

APB_sequence_item item;

covergroup cg;
    option.per_instance = 1;

    //Cover write address
    write_address: coverpoint item.apb_write_address{
        bins low_range  = {[32'h0000_0000 : 32'h0000_0010]};
        bins mid_range  = {[32'h0000_0020 : 32'h0000_003F]};
        bins high_range = {[32'h0000_0040 : 32'h0000_00FF]};
    }

    //Cover read address
    read_address: coverpoint item.apb_read_address{
        bins low_range  = {[32'h0000_0000 : 32'h0000_0010]};
        bins mid_range  = {[32'h0000_0020 : 32'h0000_003F]};
        bins high_range = {[32'h0000_0040 : 32'h0000_00FF]};
    }

    //Cover data values
    write_data: coverpoint item.apb_write_data{
        bins zero    = {32'h0000_0000};
        bins ones    = {32'hFFFF_FFFF};
        bins pattern = {[32'h0000_1000:32'h0000_1FFF]};
    }

    //Cover operation type
    operation_type: coverpoint {item.read, item.write} {
        bins read_op  = {2'b10}; // read=1, write=0
        bins write_op = {2'b01}; // read=0, write=1
    }
endgroup: cg

function new(string name = "APB_coverage", uvm_component parent = null);
    super.new(name, parent);
    cg = new();
endfunction: new

function void write(APB_sequence_item t);
    item = t;
    cg.sample();
endfunction: write
  
function void final_phase(uvm_phase phase);
  super.final_phase(phase);
  `uvm_info("COVERAGE", $sformatf("Final Functional Coverage = %0.2f%%", real'(cg.get_coverage())), UVM_LOW)
endfunction



endclass: APB_coverage