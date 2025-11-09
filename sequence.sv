class APB_reset_sequence extends uvm_sequence;

`uvm_object_utils(APB_reset_sequence)

APB_sequence_item reset_pkg;

function new(string name="APB_reset_sequence");
    super.new(name);
    `uvm_info("Reset_Sequence", "In constructor", UVM_HIGH);
endfunction: new

task body();
    `uvm_info("Reset_Sequence", "In body", UVM_HIGH);
    reset_pkg = APB_sequence_item::type_id::create("reset_pkg");
    start_item(reset_pkg);
    reset_pkg.PRESETn=0;
    finish_item(reset_pkg);

endtask

endclass


class APB_write_sequence extends uvm_sequence;

`uvm_object_utils(APB_write_sequence)

APB_sequence_item item;

rand bit [31:0] addr;
rand bit [31:0] data;

constraint c_addr { addr inside {[32'h0000_0000 : 32'h0000_00FF]}; }

function new(string name="APB_write_sequence");
    super.new(name);
    `uvm_info("In APB write Sequence", "In constructor", UVM_HIGH);
endfunction

task body();
    `uvm_info("APB_Write_Sequence", "In body", UVM_HIGH);
    item = APB_sequence_item::type_id::create("item");
    start_item(item);
    assert(item.randomize() with {
      write == 1;
      read == 0;
      PRESETn==1;
      TRANSFER ==1;
       apb_write_address dist {
            [32'h0000_0000 : 32'h0000_0010] := 1,
            [32'h0000_0020 : 32'h0000_003F] := 1,
            [32'h0000_0040 : 32'h0000_00FF] := 1
        };
       apb_write_data dist {
            32'h0000_0000 := 1,      // all zero
            32'hFFFF_FFFF := 1,      // all ones
            [32'h0000_1000 : 32'h0000_1FFF] := 1  // special patterns
        };
    });
    addr = item.apb_write_address;
   data = item.apb_write_data;
    finish_item(item);
endtask: body
endclass: APB_write_sequence


class APB_read_sequence extends uvm_sequence;

`uvm_object_utils(APB_read_sequence)
APB_sequence_item item;

rand bit [31:0] addr;


constraint c_addr { addr inside {[32'h0000_0000 : 32'h0000_00FF]}; }

function new(string name="APB_read_sequence");
    super.new(name);
    `uvm_info("In APB read Sequence", "In constructor", UVM_HIGH);
endfunction

task body();
    `uvm_info("APB_Read_Sequence", "In body", UVM_HIGH);
    item = APB_sequence_item::type_id::create("item");
    start_item(item);

    // If addr is already assigned from test, use it
  if (item.apb_read_address != 32'hx) begin
        item.randomize() with {
            write == 0;
            read == 1;
          PRESETn==1;
            TRANSFER == 1;
        };
    item.apb_read_address = addr;
    end 
    else begin
        // Otherwise, randomize normally (if needed)
        item.randomize() with {
            write == 0;
            read == 1;
            TRANSFER == 1;
          PRESETn==1;
          apb_read_address == addr;
        };
        //item.apb_read_address = item.apb_write_address;
    end
    finish_item(item);
endtask: body

endclass:APB_read_sequence
