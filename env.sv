class APB_env extends uvm_env;

`uvm_component_utils(APB_env)

APB_agent agnt;
APB_scoreboard scb;

function new(string name = "APB_env", uvm_component parent);
    super.new(name, parent);
    `uvm_info("ENV_CLASS", "In constructor", UVM_HIGH)
endfunction: new

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("ENV_CLASS", "In build phase", UVM_HIGH)

    agnt = APB_agent::type_id::create("agnt", this);
    scb = APB_scoreboard::type_id::create("scb", this);
endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("ENV_CLASS", "In connect phase", UVM_HIGH)

    agnt.mon.monitor_port.connect(scb.scoreboard_port);
    agnt.drv.drv2sb_port.connect(scb.drv2sb_port);

endfunction: connect_phase

task run_phase(uvm_phase phase);
    super.run_phase(phase);
endtask: run_phase

endclass: APB_env