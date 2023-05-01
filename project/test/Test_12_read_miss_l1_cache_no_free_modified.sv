//=====================================================================
// Project     : 4 core MESI cache design
// File Name   : Test_12_read_miss_l1_cache_no_free_modified.sv
// Description : Test for creating Processor Read Miss in L1 Cache with 
//               no free block and replacement block in modified state
// Designers   : Pramod KB
//=====================================================================

class Test_12_read_miss_l1_cache_no_free_modified extends base_test;

    //component macro
    `uvm_component_utils(Test_12_read_miss_l1_cache_no_free_modified)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", Test_12_read_miss_l1_cache_no_free_modified_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        // PKB: super.run_phase(phase);
        `uvm_info(get_type_name(), "Executing Test_12_read_miss_l1_cache_no_free_modified test" , UVM_LOW)
    endtask: run_phase

endclass : Test_12_read_miss_l1_cache_no_free_modified


class Test_12_read_miss_l1_cache_no_free_modified_seq extends base_vseq;

    //object macro
    `uvm_object_utils(Test_12_read_miss_l1_cache_no_free_modified_seq)

    //constructor
    function new (string name="Test_12_read_miss_l1_cache_no_free_modified_seq");
        super.new(name);
    endfunction : new

    cpu_transaction_c trans;
    int i;
    int num_of_tran=10;
    int ok;
    set_address set_addr_handl = new();

    virtual task body();

        `uvm_info(get_type_name(),"Executing read hit transactions on random caches", UVM_NONE)

         for(i = 1; i<=num_of_tran; i++) begin

            ok=set_addr_handl.randomize();

         // // Read 4 addresses to 4 blocks in the same set
           `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; address == set_addr_handl.set_addr_1;})
           `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; address == set_addr_handl.set_addr_2;})
           `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; address == set_addr_handl.set_addr_3;})
           `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; address == set_addr_handl.set_addr_4;})


         // // Write to each of the 4 addresses in the different blocks
           `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; address == set_addr_handl.set_addr_1;})// data = set_data_1;})
           `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; address == set_addr_handl.set_addr_2;})// data = set_data_2;})
           `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; address == set_addr_handl.set_addr_3;})// data = set_data_3;})
           `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; address == set_addr_handl.set_addr_4;})// data = set_data_4;})


            // read another new address to replace one of the modified blocks
           `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; address == set_addr_handl.set_addr_5;})


         end

    endtask : body

endclass : Test_12_read_miss_l1_cache_no_free_modified_seq

