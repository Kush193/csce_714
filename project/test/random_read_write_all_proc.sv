//=====================================================================
// Project: 4 core MESI cache design
// File Name: read_miss_icache.sv
// Description: Test for back to back reads in same address in D-Cache
// Designers: Pranit, Aditya, Kushagra
//=====================================================================

class back_to_back_read_in_same_address extends base_test;

    //component macro
    `uvm_component_utils(back_to_back_read_in_same_address)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", back_to_back_read_in_same_address_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing back_to_back_read_in_same_address test" , UVM_LOW)
    endtask: run_phase

endclass : back_to_back_read_in_same_address


// Sequence for a read-miss on D-cache
class back_to_back_read_in_same_address_seq extends base_vseq;
    //object macro
    `uvm_object_utils(back_to_back_read_in_same_address_seq)
	bit [`ADDR_WID_LV1-1 : 0] addr;
    cpu_transaction_c trans;

    //constructor
    function new (string name="back_to_back_read_in_same_address_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        //trans.randomize();
        repeat(10) begin
        for(int i =0; i<4; i++)begin
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[i], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})
            addr = trans.address;
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[i], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == addr;})

        end
        end
		
	endtask

endclass : back_to_back_read_in_same_address_seq
