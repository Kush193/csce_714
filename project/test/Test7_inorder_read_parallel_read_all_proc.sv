//=====================================================================
// Project: 4 core MESI cache design
// File Name: Test7_inorder_read_parallel_read_all_proc.sv
// Description: A Finite number of random read/write reqs from a randomly selected CPU (one CPU at a time) 
// Designers: Pranit, Aditya, Kushagra
//=====================================================================

class Test7_inorder_read_parallel_read_all_proc extends base_test;

    //component macro
    `uvm_component_utils(Test7_inorder_read_parallel_read_all_proc)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", Test7_inorder_read_parallel_read_all_proc_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing Test7_inorder_read_parallel_read_all_proc test" , UVM_LOW)
    endtask: run_phase

endclass : Test7_inorder_read_parallel_read_all_proc


// Sequence for a write-miss on I-cache
class Test7_inorder_read_parallel_read_all_proc_seq extends base_vseq;
    //object macro
    `uvm_object_utils(Test7_inorder_read_parallel_read_all_proc_seq)
	bit [`ADDR_WID_LV1-1 : 0] addr;
    cpu_transaction_c trans;
    cpu_transaction_c trans1[4];
    int cpu_num;

    //constructor
    function new (string name="Test7_inorder_read_parallel_read_all_proc_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        //trans.randomize(); 
        repeat(100) begin
            //Serial reads in all processors
            for(int i=0; i<4; i++) begin
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[i], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})  
            end

        repeat(100) begin
            //Parallel reads for all processors
            fork
                `uvm_do_on_with(trans1[0], p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
                `uvm_do_on_with(trans1[1], p_sequencer.cpu_seqr[1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
                `uvm_do_on_with(trans1[2], p_sequencer.cpu_seqr[2], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
                `uvm_do_on_with(trans1[3], p_sequencer.cpu_seqr[3], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
            join

        end
	  end       
            		
	endtask

endclass : Test7_inorder_read_parallel_read_all_proc_seq
