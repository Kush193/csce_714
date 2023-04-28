//=====================================================================
// Project: 4 core MESI cache design
// File Name: read_miss_icache.sv
// Description: Test for back to back reads in same address in D-Cache
// Designers: Pranit, Aditya, Kushagra
//=====================================================================

class invalidation_test extends base_test;

    //component macro
    `uvm_component_utils(invalidation_test)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", invalidation_test_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing invalidation_test test" , UVM_LOW)
    endtask: run_phase

endclass : invalidation_test


// Sequence for a read-miss on D-cache
class invalidation_test_seq extends base_vseq;
    //object macro
    `uvm_object_utils(invalidation_test_seq)
	bit [`ADDR_WID_LV1-1 : 0] addr;
    cpu_transaction_c trans;

    //constructor
    function new (string name="invalidation_test_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        //trans.randomize();

        //Initial write
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h7905c2ff;})

        //Read the same address on all 4 CPU - gets all CPU in Shared State
        for(int i =0; i<4; i++)begin
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[i], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h7905c2ff;})
        end

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h7905c2ff;})
        
	endtask

endclass : invalidation_test_seq
