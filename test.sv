class APB_test extends uvm_test;

`uvm_component_utils(APB_test)

APB_env env;

APB_reset_sequence reset_seq;
APB_write_sequence write_seq;
APB_read_sequence read_seq;

bit [31:0] written_addresses[$];

function new(string name = "APB_test", uvm_component parent);
    super.new(name, parent);
    `uvm_info("TEST_CLASS", "In constructor", UVM_HIGH)
endfunction: new

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("TEST_CLASS", "In build phase", UVM_HIGH)

    env = APB_env::type_id::create("env", this);
endfunction: build_phase

function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("TEST_CLASS", "In cconnect phase", UVM_HIGH)

endfunction: connect_phase

task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("TEST_CLASS", "In run phase", UVM_HIGH)

    phase.raise_objection(this);
	//Reset Sequence
    reset_seq = APB_reset_sequence::type_id::create("reset_seq");
    reset_seq.start(env.agnt.seqr);
    #4;
	
    //Write Operation

        // Let write complete
  repeat (500) @(posedge env.agnt.drv.vif.PCLK)begin
			
        write_seq = APB_write_sequence::type_id::create("write_seq");
        write_seq.start(env.agnt.seqr);
   written_addresses.push_back(write_seq.addr);
	repeat(2) @(posedge  env.agnt.drv.vif.PCLK); 
        // Reuse the same address
        read_seq = APB_read_sequence::type_id::create("read_seq");
        read_seq.addr = write_seq.addr;  // pass write addr to read
        read_seq.start(env.agnt.seqr);
    end
    phase.drop_objection(this);
endtask: run_phase
  

endclass: APB_test


