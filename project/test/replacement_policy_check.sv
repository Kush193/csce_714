//=====================================================================
// Project: 4 core MESI cache design
// File Name: replacement_policy_check.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class replacement_policy_check extends base_test;

    //component macro
    `uvm_component_utils(replacement_policy_check)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", replacement_policy_check_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing replacement_policy_check test" , UVM_LOW)
    endtask: run_phase

endclass : replacement_policy_check


// Sequence for a read-miss on I-cache
class replacement_policy_check_seq extends base_vseq;
    //object macro
    `uvm_object_utils(replacement_policy_check_seq)
    bit [`ADDR_WID_LV1-1 : 0] addr1;
    cpu_transaction_c trans;

    //constructor
    function new (string name="replacement_policy_check_seq");
        super.new(name);
    endfunction : new

    virtual task body();
    
        addr1 = 32'h41115555; 
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == addr1;})

        addr1 = 32'h41125555; 
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == addr1;})

        addr1 = 32'h41135555; 
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == addr1;})

        addr1 = 32'h41145555; 
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == addr1;})                        
    
        addr1 = 32'h41115555; 
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == addr1;})

        addr1 = 32'h41155555; 
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == addr1;})

    endtask

endclass : replacement_policy_check_seq
