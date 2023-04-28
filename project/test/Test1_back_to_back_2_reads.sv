//=====================================================================
// Project: 4 core MESI cache design
// File Name: Test1_back_to_back_2_reads
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class Test1_back_to_back_2_reads extends base_test;

    //component macro
    `uvm_component_utils(Test1_back_to_back_2_reads)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", Test1_back_to_back_2_reads_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing Test1_back_to_back_2_reads test" , UVM_LOW)
    endtask: run_phase

endclass : Test1_back_to_back_2_reads


// Sequence for a read-miss on I-cache
class Test1_back_to_back_2_reads_seq extends base_vseq;
    //object macro
    `uvm_object_utils(Test1_back_to_back_2_reads_seq)
    bit [`ADDR_WID_LV1-1 : 0] addr;

    cpu_transaction_c trans;

    //constructor
    function new (string name="Test1_back_to_back_2_reads_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        
        repeat(1)
        begin    
            for(int i =0; i<4; i++)begin
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[i], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
                addr = trans.address;
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[i], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == addr;})
            end
        
        end
    endtask

endclass : Test1_back_to_back_2_reads_seq
