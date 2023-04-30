//=====================================================================
// Project: 4 core MESI cache design
// File Name: Test8_random_parallel_read_write_all_proc.sv
// Description: A Finite number of random read/write reqs from a randomly selected CPU (one CPU at a time) 
// Designers: Pranit, Aditya, Kushagra
//=====================================================================

class Test8_random_parallel_read_write_all_proc extends base_test;

    //component macro
    `uvm_component_utils(Test8_random_parallel_read_write_all_proc)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", Test8_random_parallel_read_write_all_proc_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing Test8_random_parallel_read_write_all_proc test" , UVM_LOW)
    endtask: run_phase

endclass : Test8_random_parallel_read_write_all_proc


// Sequence for a write-miss on I-cache
class Test8_random_parallel_read_write_all_proc_seq extends base_vseq;
    //object macro
    `uvm_object_utils(Test8_random_parallel_read_write_all_proc_seq)
	bit [`ADDR_WID_LV1-1 : 0] addr;
    cpu_transaction_c trans[4];
    int cpu_num;

    bit [15:0] tag;
    bit [13:0] index, index_n;
    bit [1:0] offset;
    int ok;

    

    //constructor
    function new (string name="Test8_random_parallel_read_write_all_proc_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        //trans.randomize();
        repeat(1000) begin
            index = 1;
            ok = randomize(addr);
            {tag,index_n,offset} = addr;
            addr = {tag,index,offset};
            fork
                `uvm_do_on_with(trans[0], p_sequencer.cpu_seqr[0], { access_cache_type == DCACHE_ACC; address == addr;})
                `uvm_do_on_with(trans[1], p_sequencer.cpu_seqr[1], { access_cache_type == DCACHE_ACC; address == addr;})
                `uvm_do_on_with(trans[2], p_sequencer.cpu_seqr[2], { access_cache_type == DCACHE_ACC; address == addr;})
                `uvm_do_on_with(trans[3], p_sequencer.cpu_seqr[3], { access_cache_type == DCACHE_ACC; address == addr;})
            join 
        end
            		
	endtask

endclass : Test8_random_parallel_read_write_all_proc_seq
