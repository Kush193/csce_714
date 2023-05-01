//=====================================================================
// Project     : 4 core MESI cache design
// File Name   : Test_19_l1_cache_lru.sv
// Description : Test for creating Processor Read Miss in L1 Cache with 
//               no free block and replacement block in modified state
// Designers   : Pramod KB
//=====================================================================

class Test_19_l1_cache_lru extends base_test;

    //component macro
    `uvm_component_utils(Test_19_l1_cache_lru)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", Test_19_l1_cache_lru_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        // PKB: super.run_phase(phase);
        `uvm_info(get_type_name(), "Executing Test_19_l1_cache_lru test" , UVM_LOW)
    endtask: run_phase

endclass : Test_19_l1_cache_lru



class Test_19_l1_cache_lru_seq extends base_vseq;

    //object macro
    `uvm_object_utils(Test_19_l1_cache_lru_seq)

    //constructor
    function new (string name="Test_19_l1_cache_lru_seq");
        super.new(name);
    endfunction : new

    cpu_transaction_c trans;
    int i;
    int j;
	  int ok;
    int curr_cpu;
    int num_of_tran=10;
    set_address set_addr_handl = new();

    virtual task body();

         for(i = 1; i<=num_of_tran; i++) begin

            curr_cpu = i%4;
            ok = set_addr_handl.randomize();

            // Read 4 addresses to 4 blocks in the same set in L1 cache of proc 1
           `uvm_do_on_with(trans, p_sequencer.cpu_seqr[curr_cpu], { address == set_addr_handl.set_addr[0];})
           `uvm_do_on_with(trans, p_sequencer.cpu_seqr[curr_cpu], { address == set_addr_handl.set_addr[1];})
           `uvm_do_on_with(trans, p_sequencer.cpu_seqr[curr_cpu], { address == set_addr_handl.set_addr[2];})
           `uvm_do_on_with(trans, p_sequencer.cpu_seqr[curr_cpu], { address == set_addr_handl.set_addr[3];})

            for(j = 1; j<=10; j++) begin
              `uvm_do_on_with(trans, p_sequencer.cpu_seqr[curr_cpu], { address == set_addr_handl.set_addr[j%4];})
            end

            for(j = 1; j<=10; j++) begin
              `uvm_do_on_with(trans, p_sequencer.cpu_seqr[curr_cpu], { address == set_addr_handl.set_addr[(j%15)+4];})
            end

         end

         for(i = 1; i<=num_of_tran; i++) begin

            curr_cpu = i%4;
            ok = set_addr_handl.randomize() with {foreach(tag[i]) tag[i] < 16'h4000;};

            // Read 4 addresses to 4 blocks in the same set in L1 cache of proc 1
           `uvm_do_on_with(trans, p_sequencer.cpu_seqr[curr_cpu], { address == set_addr_handl.set_addr[0];})
           `uvm_do_on_with(trans, p_sequencer.cpu_seqr[curr_cpu], { address == set_addr_handl.set_addr[1];})
           `uvm_do_on_with(trans, p_sequencer.cpu_seqr[curr_cpu], { address == set_addr_handl.set_addr[2];})
           `uvm_do_on_with(trans, p_sequencer.cpu_seqr[curr_cpu], { address == set_addr_handl.set_addr[3];})

            for(j = 1; j<=10; j++) begin
              `uvm_do_on_with(trans, p_sequencer.cpu_seqr[curr_cpu], { address == set_addr_handl.set_addr[j%4];})
            end

            for(j = 1; j<=10; j++) begin
              `uvm_do_on_with(trans, p_sequencer.cpu_seqr[curr_cpu], { address == set_addr_handl.set_addr[(j%15)+4];})
            end

         end


    endtask : body

endclass : Test_19_l1_cache_lru_seq



