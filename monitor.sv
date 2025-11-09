class APB_monitor extends uvm_monitor;

`uvm_component_utils(APB_monitor)

virtual APB_interface vif;
APB_sequence_item item;
APB_coverage cov;

uvm_analysis_port #(APB_sequence_item) monitor_port;

function new(string name = "APB_monitor", uvm_component parent);
    super.new(name, parent);
    `uvm_info("MONITOR CLASS", "In constructor", UVM_HIGH)
endfunction: new


function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("MONITOR CLASS", "In build phase", UVM_HIGH)

    monitor_port = new("monitor_port", this);
  cov = APB_coverage::type_id::create("cov", this);

    //Get Interface 
    if (!uvm_config_db#(virtual APB_interface)::get(this, "", "vif", vif)) begin
    `uvm_error("MONITOR_CLASS", $sformatf("Cannot get VIF for %s", get_full_name()))
    end else begin
    `uvm_info("MONITOR_CLASS", $sformatf("VIF successfully set for %s", get_full_name()), UVM_LOW)
    end

endfunction: build_phase


function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("MONITOR_CLASS", "In connect Phase", UVM_HIGH)
endfunction: connect_phase


task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("MONITOR CLASS", "In run phase", UVM_HIGH)

    forever begin
      item = APB_sequence_item::type_id::create("item");
       @(posedge vif.PCLK); 
      if (vif.PRESETn == 1 && vif.psel1 && vif.PENABLE && vif.pready1 && vif.read && !vif.write)begin 
        @(posedge vif.PCLK);
            item.PSLVERR = vif.PSLVERR;
            item.apb_read_out = vif.apb_read_out;
 
            cov.write(item);
            monitor_port.write(item);
      end
    end

endtask: run_phase


endclass: APB_monitor