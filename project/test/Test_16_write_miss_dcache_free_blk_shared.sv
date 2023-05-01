


class Test_16_write_miss_dcache_free_blk_shared extends base_test;

    //component macro
    `uvm_component_utils(Test_16_write_miss_dcache_free_blk_shared)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", Test_16_write_miss_dcache_free_blk_shared_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing Test_16_write_miss_dcache_free_blk_shared test" , UVM_LOW)
    endtask: run_phase

endclass : Test_16_write_miss_dcache_free_blk_shared


// Sequence for a read-miss on I-cache
class Test_16_write_miss_dcache_free_blk_shared_seq extends base_vseq;
    //object macro
    `uvm_object_utils(Test_16_write_miss_dcache_free_blk_shared_seq)

    cpu_transaction_c trans;
	int i,set=0;
    int ok;
	rand bit [15:0] tag[10];

    set_address set_addr_handl = new();
   	constraint different_tag{unique{tag}; foreach(tag[i])((tag[i] & 'hc000)!=0);} // only access to data cache
   
    //constructor
    function new (string name="Test_16_write_miss_dcache_free_blk_shared_seq");
        super.new(name);
    endfunction : new

    virtual task body();
	
   repeat(10) // number of sets in cache
begin
	ok=randomize(tag); // randomize tags
            ok=set_addr_handl.randomize();
	for(i=0;i<10;i++)
	begin
	$display("tag=%h",tag[i]);
	end	
	//fill up a set by bringing 4 different blocks to L1 cache with same index number and different tags
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {address[15:2]==set_addr_handl.index; address[31:16]==tag[0];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {address[15:2]==set_addr_handl.index; address[31:16]==tag[0];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {address[15:2]==set_addr_handl.index; address[31:16]==tag[1];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {address[15:2]==set_addr_handl.index; address[31:16]==tag[2];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {address[15:2]==set_addr_handl.index; address[31:16]==tag[3];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})

	
	//send read by some other CPU to all addresses of same set to change MESI state to SHARED
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {address[15:2]==set_addr_handl.index; address[31:16]==tag[0];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {address[15:2]==set_addr_handl.index; address[31:16]==tag[1];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {address[15:2]==set_addr_handl.index; address[31:16]==tag[2];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {address[15:2]==set_addr_handl.index; address[31:16]==tag[3];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {address[15:2]==set_addr_handl.index; address[31:16]==tag[3];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {address[15:2]==set_addr_handl.index; address[31:16]==tag[2];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})

	
	//write the above addresses from some other CPU
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp2], {address[15:2]==set_addr_handl.index; address[31:16]==tag[0];request_type == WRITE_REQ;data==1234_5678; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp2], {address[15:2]==set_addr_handl.index; address[31:16]==tag[1];request_type == WRITE_REQ;data==5678_1234; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp2], {address[15:2]==set_addr_handl.index; address[31:16]==tag[2];request_type == WRITE_REQ;data=='ha5a5_a5a5; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp2], {address[15:2]==set_addr_handl.index; address[31:16]==tag[3];request_type == WRITE_REQ;data=='h5a5a_5a5a; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp2], {address[15:2]==set_addr_handl.index; address[31:16]==tag[6];request_type == WRITE_REQ;data=='hcafe_babe; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp2], {address[15:2]==set_addr_handl.index; address[31:16]==tag[3];request_type == WRITE_REQ; data=='hbabe_cafe;access_cache_type == DCACHE_ACC;})
        
	//read from some CPU to validate data --it will be a miss since copies invalidated in previous steps
	`uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {address[15:2]==set_addr_handl.index; address[31:16]==tag[0];request_type == READ_REQ; data==1234_5678;access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {address[15:2]==set_addr_handl.index; address[31:16]==tag[1];request_type == READ_REQ;data==5678_1234; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {address[15:2]==set_addr_handl.index; address[31:16]==tag[2];request_type == READ_REQ; data=='ha5a5_a5a5;access_cache_type == DCACHE_ACC;})

	set= set+1;
end
    endtask

endclass : Test_16_write_miss_dcache_free_blk_shared_seq
