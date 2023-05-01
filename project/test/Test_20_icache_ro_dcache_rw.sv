//=====================================================================
// Project: 4 core MESI cache design
// File Name: read_miss_icache.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class Test_20_icache_ro_dcache_rw extends base_test;

    //component macro
    `uvm_component_utils(Test_20_icache_ro_dcache_rw)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", Test_20_icache_ro_dcache_rw_vseq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing Test_20_icache_ro_dcache_rw test" , UVM_LOW)
    endtask: run_phase

endclass : Test_20_icache_ro_dcache_rw


// Sequence for a read-miss on I-cache
class Test_20_icache_ro_dcache_rw_vseq extends base_vseq;
    //object macro
    `uvm_object_utils(Test_20_icache_ro_dcache_rw_vseq)
	 bit [`ADDR_WID_LV1-1 : 0] ran_addr;

    cpu_transaction_c trans;
	int i,j,k,ok;
    //constructor
    function new (string name="Test_20_icache_ro_dcache_rw_vseq");
        super.new(name);
    endfunction : new

    virtual task body();

			for(i =0; i<100; i++) begin
	ok=randomize(mp);
	ok=randomize(sp2);
	ok=randomize(sp1);
	$display("mp=%d, sp1 =%d, sp2=%d",mp,sp1,sp2);
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == ICACHE_ACC;})
			`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == ICACHE_ACC;})
			for(j =0; j<4; j++) begin
			`uvm_do_on_with(trans, p_sequencer.cpu_seqr[j], {request_type == READ_REQ; access_cache_type == ICACHE_ACC;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[j], {request_type == WRITE_REQ; access_cache_type == ICACHE_ACC;})
		end	
			`uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})
			`uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp2], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})
			ran_addr = trans.address;
			for(k =0; k<4; k++) begin
				`uvm_do_on_with(trans, p_sequencer.cpu_seqr[k], {request_type == WRITE_REQ; data=='ha5a5_a5a5;access_cache_type == DCACHE_ACC; address == ran_addr;})
				`uvm_do_on_with(trans, p_sequencer.cpu_seqr[k], {request_type == WRITE_REQ; data=='h5a5a_5a5a;access_cache_type == DCACHE_ACC; address == ran_addr;})
			end
			end
	endtask

endclass : Test_20_icache_ro_dcache_rw_vseq
