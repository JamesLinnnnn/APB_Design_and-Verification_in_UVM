class APB_driver extends uvm_driver #(APB_sequence_item);

`uvm_component_utils(APB_driver)

virtual APB_interface vif;
APB_sequence_item item;
APB_coverage cov;
  
 uvm_analysis_port #(APB_sequence_item) drv2sb_port;

function new(string name="APB_driver", uvm_component parent);
    super.new(name, parent);
    `uvm_info("DRIVER_CLASS", "In constructor", UVM_HIGH)
endfunction: new

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("In Driver Class", "In build phase", UVM_HIGH);
    //Port connected to Driver and scoreboard
    drv2sb_port = new("drv2sb_port", this);
    //Get Interface
    if (!uvm_config_db#(virtual APB_interface)::get(this, "", "vif", vif)) begin
    `uvm_error("DRIVER_CLASS", $sformatf("Cannot get VIF for %s", get_full_name()))
    end else begin
    `uvm_info("DRIVER_CLASS", $sformatf("VIF successfully set for %s", get_full_name()), UVM_LOW)
    end
	cov = APB_coverage::type_id::create("cov", this);
endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
     `uvm_info("DRIVER_CLASS", "In connect phase", UVM_HIGH);
endfunction: connect_phase

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("DRIVER_CLASS", "In run phase", UVM_HIGH);

    forever begin
   
      @(posedge vif.PCLK);
        item = APB_sequence_item::type_id::create("item");
        //Get item from sequencer
        seq_item_port.get_next_item(item);
        drive(item);
      cov.write(item);
        seq_item_port.item_done();
    end
endtask: run_phase

task drive(APB_sequence_item item);

  // Setup phase
  vif.PRESETn          = item.PRESETn;
  vif.TRANSFER         = item.TRANSFER;
  vif.write            = item.write;
  vif.read             = item.read;
  vif.apb_write_address = item.apb_write_address;
  vif.apb_write_data    = item.apb_write_data;
  vif.apb_read_address  = item.apb_read_address;

  // Wait for clock
  @(posedge vif.PCLK);

  // Drive control signals
  if (item.write) begin

    // Setup Phase
    vif.write   = 1;
    vif.read    = 0;
    vif.TRANSFER = 1;

    @(posedge vif.PCLK);

    // Enable Phase


    wait(vif.pready1);  // wait for slave ready
    @(posedge vif.PCLK);

    // Deassert
    vif.TRANSFER = 0;
    drv2sb_port.write(item); // only write to scoreboard after a successful transfer

  end 
  
  else if (item.read) begin

    // Setup Phase
    vif.write   = 0;
    vif.read    = 1;
    vif.TRANSFER = 1;

    @(posedge vif.PCLK);


    wait(vif.pready1);  // wait for slave ready
    @(posedge vif.PCLK);

    // Deassert
    vif.TRANSFER = 0;
  end

endtask:drive
endclass: APB_driver
