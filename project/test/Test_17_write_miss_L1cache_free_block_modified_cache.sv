//=====================================================================
// Project: 4 core MESI cache design
// File Name: read_miss_icache.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class Test_17_write_miss_L1cache_free_block_modified_cache extends base_test;

    //component macro
    `uvm_component_utils(Test_17_write_miss_L1cache_free_block_modified_cache )

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", Test_17_write_miss_L1cache_free_block_modified_cache_vseq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing Test_17_write_miss_L1cache_free_block_modified_cache test" , UVM_LOW)
    endtask: run_phase

endclass : Test_17_write_miss_L1cache_free_block_modified_cache


// Sequence for a read-miss on I-cache
class Test_17_write_miss_L1cache_free_block_modified_cache_vseq extends base_vseq;
    //object macro
    `uvm_object_utils(Test_17_write_miss_L1cache_free_block_modified_cache_vseq)
	 bit [`ADDR_WID_LV1-1 : 0] ran_addr;

    cpu_transaction_c trans;
	int i;
    int ok;
    set_address set_addr_handl = new();
    //constructor
    function new (string name="Test_17_write_miss_L1cache_free_block_modified_cache_vseq");
        super.new(name);
    endfunction : new

    virtual task body();
          for(i = 1; i<=10; i++) begin
            ok = set_addr_handl.randomize();
	//modified state block
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; data == set_addr_handl.set_data_1; address == set_addr_handl.set_addr_1;})
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; data == set_addr_handl.set_data_1; address == set_addr_handl.set_addr_2;})
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; data == set_addr_handl.set_data_1; address == set_addr_handl.set_addr_3;})
/// write miss from some other processor- this will invalidate other copies in cache       
  `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; data == set_addr_handl.set_data_1; address == set_addr_handl.set_addr_1;})
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; data == set_addr_handl.set_data_1; address == set_addr_handl.set_addr_2;})
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp2], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; data == set_addr_handl.set_data_1; address == set_addr_handl.set_addr_2;})
         `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; data == set_addr_handl.set_data_1; address == set_addr_handl.set_addr_2;})
			`uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})
			ran_addr = trans.address;
			`uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == ran_addr;})   
end	
endtask

endclass : Test_17_write_miss_L1cache_free_block_modified_cache_vseq
