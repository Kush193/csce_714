//=====================================================================
// Project: 4 core MESI cache design
// File Name: Test5_random_read_write_all_proc.sv
// Description: A Finite number of random read/write reqs from a randomly selected CPU (one CPU at a time) 
// Designers: Pranit, Aditya, Kushagra
//=====================================================================

class Test5_random_read_write_all_proc extends base_test;

    //component macro
    `uvm_component_utils(Test5_random_read_write_all_proc)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", Test5_random_read_write_all_proc_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing Test5_random_read_write_all_proc test" , UVM_LOW)
    endtask: run_phase

endclass : Test5_random_read_write_all_proc


// Sequence for a write-miss on I-cache
class Test5_random_read_write_all_proc_seq extends base_vseq;
    //object macro
    `uvm_object_utils(Test5_random_read_write_all_proc_seq)
	bit [`ADDR_WID_LV1-1 : 0] addr;
    cpu_transaction_c trans;
    int cpu_num;

    //constructor
    function new (string name="Test5_random_read_write_all_proc_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        //trans.randomize(); 
        repeat(1000) begin
            cpu_num = $urandom_range(0,3);
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[cpu_num], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})
            cpu_num = $urandom_range(0,3);
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[cpu_num], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})            


        end       
            		
	endtask

endclass : Test5_random_read_write_all_proc_seq
