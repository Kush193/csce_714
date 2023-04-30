//=====================================================================
// Project: 4 core MESI cache design
// File Name: Test4_write_all_proc_read_all_proc_same_addr.sv
// Description: Send a write req from each CPU (0-3) for the same randomly chosen address and different data. This is followed by a read for the same address from all CPUs. (Expecting the value written in the last write to be returned by all the reads)
// Designers: Pranit, Aditya, Kushagra
//=====================================================================

class Test4_write_all_proc_read_all_proc_same_addr extends base_test;

    //component macro
    `uvm_component_utils(Test4_write_all_proc_read_all_proc_same_addr)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", Test4_write_all_proc_read_all_proc_same_addr_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing Test4_write_all_proc_read_all_proc_same_addr test" , UVM_LOW)
    endtask: run_phase

endclass : Test4_write_all_proc_read_all_proc_same_addr


// Sequence for a write-miss on I-cache
class Test4_write_all_proc_read_all_proc_same_addr_seq extends base_vseq;
    //object macro
    `uvm_object_utils(Test4_write_all_proc_read_all_proc_same_addr_seq)
	bit [`ADDR_WID_LV1-1 : 0] addr;
    cpu_transaction_c trans;

    //constructor
    function new (string name="Test4_write_all_proc_read_all_proc_same_addr_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        //trans.randomize(); 
        repeat(100) begin       
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})
            addr = trans.address;
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == addr;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == addr;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == addr;})

            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == addr;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == addr;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == addr;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == addr;})
        end

		
	endtask

endclass : Test4_write_all_proc_read_all_proc_same_addr_seq
