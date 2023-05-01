//=====================================================================
// Project: 4 core MESI cache design
// File Name: Test_21_random_parallel_4_cpu_rd_wr.sv
// Description: Test_21_random_parallel_4_cpu_rd_wr
// Designers: Venky & Suru
//=====================================================================

class Test_21_random_parallel_4_cpu_rd_wr extends base_test;

    //component macro
    `uvm_component_utils(Test_21_random_parallel_4_cpu_rd_wr)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", Test_21_random_parallel_4_cpu_rd_wr_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing Test_21_random_parallel_4_cpu_rd_wr test" , UVM_LOW)
    endtask: run_phase

endclass : Test_21_random_parallel_4_cpu_rd_wr


// Sequence for Test_21_random_parallel_4_cpu_rd_wr
class Test_21_random_parallel_4_cpu_rd_wr_seq extends base_vseq;
    //object macro
    `uvm_object_utils(Test_21_random_parallel_4_cpu_rd_wr_seq)

    cpu_transaction_c trans,trans1,trans2,trans3;
    bit [`ADDR_WID_LV1-1 : 0]   rand_addr_1, rand_addr_2;
    int i =0;
    int num_of_tran=10;
    int ok;
    set_address set_addr_handl = new();
    rand access_cache_t ctype1, ctype2, ctype3, ctype4;



    //constructor
    function new (string name="Test_21_random_parallel_4_cpu_rd_wr_seq");
        super.new(name);
    endfunction : new	

    virtual task body();

            ok=set_addr_handl.randomize();
	//randomize read and write requests from all 4 cpus parallely with addresses with in a set 

	fork
	begin
	for(int i= 0; i<num_of_tran;i++)
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {address inside {set_addr_handl.set_addr};})
	end
	begin
	for(int i= 0; i<num_of_tran;i++)
		`uvm_do_on_with(trans1, p_sequencer.cpu_seqr[sp1], {address inside {set_addr_handl.set_addr};})
	end
	begin
	for(int i= 0; i<num_of_tran;i++)
		`uvm_do_on_with(trans2, p_sequencer.cpu_seqr[sp2], {address inside {set_addr_handl.set_addr};})
	end
	begin
	for(int i= 0; i<num_of_tran;i++)
		`uvm_do_on_with(trans3, p_sequencer.cpu_seqr[3], {address inside {set_addr_handl.set_addr};})
	end

	 
      	join
         
    endtask

endclass : Test_21_random_parallel_4_cpu_rd_wr_seq
