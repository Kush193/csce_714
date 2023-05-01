//=====================================================================
// Project: 4 core MESI cache design
// File Name: read_miss_icache.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class Test_13_write_hit_L1cache_shar_excl_cache extends base_test;

    //component macro
    `uvm_component_utils(Test_13_write_hit_L1cache_shar_excl_cache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", Test_13_write_hit_L1cache_shar_excl_cache_vseq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing Test_13_write_hit_L1cache_shar_excl_cache test" , UVM_LOW)
    endtask: run_phase

endclass : Test_13_write_hit_L1cache_shar_excl_cache


// Sequence for a read-miss on I-cache
class Test_13_write_hit_L1cache_shar_excl_cache_vseq extends base_vseq;
    //object macro
    `uvm_object_utils(Test_13_write_hit_L1cache_shar_excl_cache_vseq)
    cpu_transaction_c trans;

    //constructor
    function new (string name="Test_13_write_hit_L1cache_shar_excl_cache_vseq");
        super.new(name);
    endfunction : new
    set_address set_addr_handl = new();
    
    virtual task body();    
        repeat(10) begin
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_1;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_2;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_3;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_4;})
            
             //blocks in exclusive
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_1;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_2;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_3;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_4;})  
                    
             // blocks in modified
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_1;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_2;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_3;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_4;})  
        end
    endtask

endclass : Test_13_write_hit_L1cache_shar_excl_cache_vseq
