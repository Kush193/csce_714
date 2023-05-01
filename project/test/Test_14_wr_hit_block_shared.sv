//=====================================================================
// Project: 4 core MESI cache design
// File Name: read_miss_icache.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class Test_14_wr_hit_block_shared extends base_test;

    //component macro
    `uvm_component_utils(Test_14_wr_hit_block_shared)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", Test_14_wr_hit_block_shared_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing Test_14_wr_hit_block_shared test" , UVM_LOW)
    endtask: run_phase

endclass : Test_14_wr_hit_block_shared


// Sequence for Test_14_wr_hit_block_shared
class Test_14_wr_hit_block_shared_seq extends base_vseq;
    //object macro
    `uvm_object_utils(Test_14_wr_hit_block_shared_seq)

    cpu_transaction_c trans;
    bit [`ADDR_WID_LV1-1 : 0]   rand_addr_1, rand_addr_2;

    int wp, tp1,tp2 ;
       int i,ok;
    int num_of_tran=10;
    set_address set_addr_handl = new();


    //constructor
    function new (string name="Test_14_wr_hit_block_shared_seq");
        super.new(name);
    endfunction : new	

    virtual task body();

         for(i = 1; i<=num_of_tran; i++) begin
	  
           ok=set_addr_handl.randomize(); 
         //read a random address from different cpus to place it in shared state
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_1;})
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_1;})
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp2], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_1;})

         //write the same address from one of the cpu , should trigger invalidation
          ok=randomize(wp) with {wp inside {mp,sp1,sp2};};
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[wp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;data == set_addr_handl.set_data_1; address == set_addr_handl.set_addr_1;})

           //read the address from other cpus to verify invalidation. should result in read miss --> verified in scoreboard
          ok=randomize(tp1) with {tp1 inside {mp,sp1,sp2}; tp1 != wp;};
          ok=randomize(tp2) with {tp2 inside {mp,sp1,sp2}; tp2 != wp ; tp2 != tp1;};
          `uvm_do_on_with(trans, p_sequencer.cpu_seqr[tp1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_1;})
          `uvm_do_on_with(trans, p_sequencer.cpu_seqr[tp2], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr_handl.set_addr_1;})



          end      
         
         
    endtask

endclass : Test_14_wr_hit_block_shared_seq
