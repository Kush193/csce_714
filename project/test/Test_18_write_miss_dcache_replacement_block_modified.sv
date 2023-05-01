


class Test_18_write_miss_dcache_replacement_block_modified extends base_test;

    //component macro
    `uvm_component_utils(Test_18_write_miss_dcache_replacement_block_modified)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", Test_18_write_miss_dcache_replacement_block_modified_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing Test_18_write_miss_dcache_replacement_block_modified test" , UVM_LOW)
    endtask: run_phase

endclass : Test_18_write_miss_dcache_replacement_block_modified


// Sequence for a read-miss on I-cache
class Test_18_write_miss_dcache_replacement_block_modified_seq extends base_vseq;
    //object macro
    `uvm_object_utils(Test_18_write_miss_dcache_replacement_block_modified_seq)

    cpu_transaction_c trans;
	int i,set=0;
	int ok;
	rand bit [15:0] tag[10];

   	constraint different_tag{unique{tag}; foreach(tag[i])((tag[i] & 'hc000)!=0);} // only access to data cache
   
    //constructor
    function new (string name="Test_18_write_miss_dcache_replacement_block_modified_seq");
        super.new(name);
    endfunction : new

    virtual task body();
	

   repeat(100)
begin
	ok = randomize(tag); // randomize tags
	for(i=0;i<10;i++)
	begin
	$display("tag=%h",tag[i]);
	end	
	//fill up a set by WRITING To 4 different blocks to L1 cache with same index number and different tags. this will make all blocks in modified state
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {address[15:2]==0; address[31:16]==0;data=='h1234_5678;request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {address[15:2]==set; address[31:16]==tag[0];data=='hA5A5_A5A5;request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {address[15:2]==set; address[31:16]==tag[1];data=='h5A5A_5A5A;request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {address[15:2]==set; address[31:16]==tag[2];data=='hDEAD_CAFE;request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {address[15:2]==set; address[31:16]==tag[3];data=='hDEAD_BABE;request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})

	//write to  one more block in the same set -- this should lead to writemiss with block replacement of modified state block
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {address[15:2]==set; address[31:16]==tag[5];data=='ha5a5_a5a5;request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})
	//write  one more block in the same set -- this should lead to write miss with block replacement of modified state block
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {address[15:2]==set; address[31:16]==tag[6];data=='h5a5A_5a5a;request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})
	
	//send read by some other CPU to all addresses of same set to change MESI state to SHARED
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {address[15:2]==set; address[31:16]==tag[0];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {address[15:2]==set; address[31:16]==tag[1];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {address[15:2]==set; address[31:16]==tag[5];data=='ha5a5_a5a5;request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {address[15:2]==set; address[31:16]==tag[6];data=='h5a5A_5a5a;request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {address[15:2]==set; address[31:16]==tag[3];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {address[15:2]==set; address[31:16]==tag[2];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})

	// read miss with SHared block replacement
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {address[15:2]==set; address[31:16]==tag[7];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {address[15:2]==set; address[31:16]==tag[8];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {address[15:2]==set; address[31:16]==tag[9];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
	
	//read the above addresses from some other CPU
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp2], {address[15:2]==set; address[31:16]==tag[7];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp2], {address[15:2]==set; address[31:16]==tag[8];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp2], {address[15:2]==set; address[31:16]==tag[9];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp2], {address[15:2]==set; address[31:16]==tag[5];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp2], {address[15:2]==set; address[31:16]==tag[6];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp2], {address[15:2]==set; address[31:16]==tag[3];request_type == READ_REQ; access_cache_type == DCACHE_ACC;})

	set= set+1;
end
    endtask

endclass : Test_18_write_miss_dcache_replacement_block_modified_seq
