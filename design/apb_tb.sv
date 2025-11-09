`timescale  1ns/1ns
module tb;
reg PCLK;
reg PRESETn;
reg TRANSFER;
reg read;
reg write;
reg [31:0]apb_write_address;
reg [31:0]apb_write_data;
reg [31:0]apb_read_address;
wire PSLVERR;
wire [31:0]apb_read_out;

apb_top uut (
.PCLK(PCLK),
.PRESETn(PRESETn),
.TRANSFER(TRANSFER),
.read(read),
.write(write),
.apb_write_address(apb_write_address),
.apb_write_data(apb_write_data),
.apb_read_address(apb_read_address),
.PSLVERR(PSLVERR),
.apb_read_out(apb_read_out)
);

initial begin
PCLK=0;
forever begin
    #5 PCLK=~PCLK;
end
end

//Task WE wanna test

//Reset & Initialization
task reset_and_init;
begin
    PRESETn=0;
    TRANSFER=0;
    read=0;
    write=0;
    apb_write_address=32'd0;
    apb_write_data=32'd0;
    apb_read_address=32'd0;
    #20;
    PRESETn=1;
    #10;
end
endtask: reset_and_init


//Test case 1: Basic Write Operation
task test_write;
input [31:0]address;
input [31:0]data;
begin
    $display("Start Basic Write Operation Test!!!");
    TRANSFER=1;
    read=0; write=1;
    apb_write_address=address;
    apb_write_data=data;
    #10;//Setup phase
    #10;//Access Phase
    TRANSFER=0;
    write=0;
    $display("Time %0t, Write operation Completed!! Address = %0h, Data is %0h", $time, address, data);
    #10;
end

endtask: test_write

//Test case 2: Basic Read Operation
task test_read;
input [31:0]address;
begin 
    $display("Start Basic Read Operation Test!!!!!");
    TRANSFER=1;
    write=0;
    read=1;
    apb_read_address=address;
    #10;//Setup Phase
    #10;//Access Phase
    TRANSFER=0;
    read=0;
    $display("Time %0t, Read operation Completed!! Address = %0h, Data Read is %0h", $time, address, apb_read_out);
    #10;
end

endtask: test_read


//Test Case 3: Address Decoding(Slave Detection)
task test_address_decoding;
begin
    $display("Start Address Decoding Test!!!");
    test_write(32'h005, 32'hA5);//Target Slave 1
    test_write(32'h085, 32'h5A); //Target Slave 2
end
endtask: test_address_decoding

//Test Case 4: Write with Wait States
task test_write_with_wait_states;
input [31:0]address;
input [31:0]data;
begin
    $display("Start Write Operation with Wait States Test!!");
    TRANSFER=1;
    write=1;
    read=0;
    apb_write_address=address;
    apb_write_data=data;
    #10; //Setup Phase
    //Simulate a wait by delaying slave response
    @(posedge PCLK);
    $display("Slave ready signal delayed!!");
    #20;//Access Phase
    TRANSFER=0;
    write=0;
    $display("Write Completed with Wait States: Address = %0h, Data = %0h", address, data);
end
endtask: test_write_with_wait_states

//Test Case 5: Read With Wait Sates
task test_read_with_wait_states;
input [31:0]address;
begin
    $display("Start Read Operation with Wait States Test!!");
    TRANSFER=1;
    write=0;
    read=1;
    apb_read_address=address;
    #10; //Setup Phase
    //Simulate a wait by delaying slave response
    @(posedge PCLK);
    $display("Slave ready signal delayed!!");
    #20;//Access Phase
    TRANSFER=0;
    read=0;
    $display("Read Completed with Wait States: Address = %0h, Data = %0h", address, apb_read_out);
    #10;
end
endtask: test_read_with_wait_states

//Test Case 6: Error Handling (PSLVERR)
task test_error_handling;
input [31:0]invalid_address;
begin
    $display("Start Error Handling Test!!!");
    TRANSFER=1;
    write=1;
    read=0;
    apb_write_address=invalid_address;
    apb_write_data=32'hFF;
    #10;//Setup Phase
    #10;//Access Phase
    TRANSFER=0;
    write=0;
    $display("Time %0t, Error Condtion PSLVERR = %0b, Invalid Address = %0h", $time, PSLVERR, invalid_address);
    #10;
end
endtask: test_error_handling

//Test Cae 7: Burst Transfers
task test_burst_transfers;
begin
    $display("Start Burst Transfers Test!!!");
    test_write(32'h001, 32'h11);
    test_read(32'h001);
    test_write(32'h002, 8'h22);
    test_read(32'h002);
    test_write(32'h003, 8'h33);
    test_read(32'h003);
    $display("Burst Transfer Completed!!");
end
endtask: test_burst_transfers

// Test Case 8: Out of Range Address Handling
task test_out_of_range_address;
input [31:0]invalid_address;
begin
    $display("Start Out of Range Address Handling Test!!!");
    TRANSFER=1;
    write=1;
    read=0;
    apb_write_address=invalid_address;
    apb_write_data=32'hFF;
    #10;//Setup Phase
    #10;//Access Phase
    TRANSFER=0;
    write=0;
    if(PSLVERR) $display("ERROR detectd for invalid address %0h, PSLVERR = %0b,", invalid_address, PSLVERR);
    else $display("No ERROR detected for invalid address %0h, PSLVERR = %0b", invalid_address, PSLVERR);
    #10;
end
endtask: test_out_of_range_address


//Case 9: Test Reset Behavior
task test_reset_behavior;
begin
    $display("Test Reset Behavior!!!");
    PRESETn=0;
    #20;
    if(!PRESETn)$display("System Reset Asserted!!");
    PRESETn=1;
    #10;
    if(PRESETn) $display("System Reset Released. Register and signalsshould return to default states. State is %0b",uut.master_uut.state
);
    #10;
end
endtask: test_reset_behavior

//Case 10 Test Randomized Transactions
task test_randomized_transactions;
integer i;
begin
    $display("Start Randomized Transactions Test!!!");
    for(i=0;i<20;i=i+1)begin
        TRANSFER=1;
        if($random%2)begin
            write=1;
            read=0;
            apb_write_address=$random % 32'h100;
            apb_write_data=$random % 32'hFF;
            $display("Write Transaction: Address = %0h, Data = %0h", apb_write_address, apb_write_data);
        end
        else begin
            write=0;
            read=1;
            apb_read_address=$random % 32'h100;
            $display("Read Transaction: Address = %0h", apb_read_address);
        end
        #10;//Setup Phase
        #10;//Access Phase
        TRANSFER=0;
        write=0;
        read=0;
        #10;
    end
end

endtask: test_randomized_transactions




initial begin
$display("APB Testbench starts!!!!");
$display("");
reset_and_init;
    $display("");
test_write(32'h005, 32'hAA);
    $display("");
test_read(32'h005);
    $display("");
test_address_decoding;
    $display("");
test_write_with_wait_states(32'h10, 32'hBB);
    $display("");
test_read_with_wait_states(32'h10);
    $display("");
test_error_handling(32'h1FF);
    $display("");
test_burst_transfers;
    $display("");
test_out_of_range_address(32'h1FF);
    $display("");
test_reset_behavior;
    $display("");
test_randomized_transactions;
    $display("");
$display("APB System Tesbench Completed!!!!");
$finish;
end



endmodule