//=====================================================================
// Project: 4 core MESI cache design
// File Name: read_followed_by_write.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class read_followed_by_write extends base_test;

    //component macro
    `uvm_component_utils(read_followed_by_write)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", read_followed_by_write_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing read_followed_by_write test" , UVM_LOW)
    endtask: run_phase

endclass : read_followed_by_write


// Sequence for a read-miss on I-cache
class read_followed_by_write_seq extends base_vseq;
    //object macro
    `uvm_object_utils(read_followed_by_write_seq)

    cpu_transaction_c trans[4];
    cpu_transaction_c trans_1;
    bit [31:0] addr[2];

    bit [31:0]   test_data = 32'hdeadbeef;
    bit [31:0]   test_data_1 = 32'hdeadbeed;
    bit [31:0]   test_data_2 = 32'hdeadbeec;
    int index;

    //constructor
    function new (string name="read_followed_by_write_seq");
        super.new(name);
    endfunction : new

            task cpu_transaction(int cpuID);
                
                addr[0] = 32'h7905c2ff;
                addr[1] = 32'h8016d5d0;
                repeat(1000)begin
                    index = $urandom_range(0,1);
                    if(cpuID == 0 || cpuID == 1) 
                        `uvm_do_on_with(trans[cpuID], p_sequencer.cpu_seqr[cpuID], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == addr[index];})
                    else 
                        `uvm_do_on_with(trans[cpuID], p_sequencer.cpu_seqr[cpuID], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == addr[index];})
                    end
            endtask

    virtual task body();
        //`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        //`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h7905c2ff;})

        //`uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h7905c2ff;})
        fork
            cpu_transaction(0);
            cpu_transaction(1);
            cpu_transaction(2);
            cpu_transaction(3);
        join
/*         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h7905c2ff; data == test_data;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h7905c2ff; data == test_data_1;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h7905c2ff;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h7905c2ff;})

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h7905c2ff; data == test_data_2;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h7905c2ff; data == test_data_2;})

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h7905c2ff;})

        repeat(10) begin
        for(int i =0; i<4; i++)begin
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[i], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})
            addr = trans.address;
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[i], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == addr;})

        end
        end */

    endtask

endclass : read_followed_by_write_seq
