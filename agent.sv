class APB_agent extends uvm_agent;

`uvm_component_utils(APB_agent)

APB_sequencer seqr;
APB_driver drv;
APB_monitor mon;

function new(string name = "APB_agent", uvm_component parent);
    super.new(name, parent);
    `uvm_info("AGENT_CLASS", "In Constructor", UVM_HIGH)
endfunction: new

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("AGENT_CLASS", "In build phase", UVM_HIGH)

    seqr = APB_sequencer::type_id::create("seqr", this);
    drv = APB_driver::type_id::create("drv", this);
    mon = APB_monitor::type_id::create("mon", this);

endfunction: build_phase


function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("AGENT_CLASS", "In connect phase", UVM_HIGH)

    drv.seq_item_port.connect(seqr.seq_item_export);
endfunction: connect_phase

task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("AGENT_CLASS", "In run phase", UVM_HIGH)

endtask: run_phase

endclass: APB_agent
