//=====================================================================
// Project: 4 core MESI cache design
// File Name: read_miss_icache.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class Test_22_wr_miss_nofree_block_shrd_or_excl extends base_test;

    //component macro
    `uvm_component_utils(Test_22_wr_miss_nofree_block_shrd_or_excl)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", Test_22_wr_miss_nofree_block_shrd_or_excl_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing Test_22_wr_miss_nofree_block_shrd_or_excl test" , UVM_LOW)
    endtask: run_phase

endclass : Test_22_wr_miss_nofree_block_shrd_or_excl


// Sequence for test_7_wr_hit_block_shared
class Test_22_wr_miss_nofree_block_shrd_or_excl_seq extends base_vseq;
    //object macro
    `uvm_object_utils(Test_22_wr_miss_nofree_block_shrd_or_excl_seq)

    cpu_transaction_c trans;
    bit [`ADDR_WID_LV1-1 : 0]   rand_addr_1 = 'b0, rand_addr_2;
    int i,ok;
    int num_of_tran=10;
    set_address set_addr_handl = new();

    int wp;


    //constructor
    function new (string name="Test_22_wr_miss_nofree_block_shrd_or_excl_seq");
        super.new(name);
    endfunction : new	

    virtual task body();

          for(i = 1; i<=num_of_tran; i++) begin

            ok=set_addr_handl.randomize();

         //read random addresses but with same set index to fill up a particular set	
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_1;})
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_2;})
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_3;})
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_4;})

         //write to random address but with same set, it will cause a write miss replacement should be in exclusive state
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; data == set_addr_handl.set_data_1; address == set_addr_handl.set_addr_5;})
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; data == set_addr_handl.set_data_2; address == set_addr_handl.set_addr_6;})

         //read all the prev addresses from a different cpu to change the states to shared
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_1;})
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_2;})
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_3;})
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_4;})
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_5;})
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_6;})

          //write to random address but with same set, it will cause a write miss, replacement should be in shared state
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; data == set_addr_handl.set_data_3; address == set_addr_handl.set_addr_7;})
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; data == set_addr_handl.set_data_4; address == set_addr_handl.set_addr_8;})

	//no bus activity expected for replacement. shared/exclusive block should be replaced directly

          end
	
         

         
         
    endtask

endclass : Test_22_wr_miss_nofree_block_shrd_or_excl_seq
