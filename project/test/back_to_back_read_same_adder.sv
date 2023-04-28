//=====================================================================
// Project: 4 core MESI cache design
// File Name: back_to_back_read_same_adder.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class back_to_back_read_same_adder extends base_test;

    //component macro
    `uvm_component_utils(back_to_back_read_same_adder)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", back_to_back_read_same_adder_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing back_to_back_read_same_adder test" , UVM_LOW)
    endtask: run_phase

endclass : back_to_back_read_same_adder


// Sequence for a read-miss on I-cache
class back_to_back_read_same_adder_seq extends base_vseq;
    //object macro
    `uvm_object_utils(back_to_back_read_same_adder_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="back_to_back_read_same_adder_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        //`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h7905c2ff;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h7905c2ff;})
    endtask

endclass : back_to_back_read_same_adder_seq
