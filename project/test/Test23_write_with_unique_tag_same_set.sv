//=====================================================================
// Project: 4 core MESI cache design
// File Name: Test23_write_with_unique_tag_same_set
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class Test23_write_with_unique_tag_same_set extends base_test;

    //component macro
    `uvm_component_utils(Test23_write_with_unique_tag_same_set)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", Test23_write_with_unique_tag_same_set_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing Test23_write_with_unique_tag_same_set test" , UVM_LOW)
    endtask: run_phase

endclass : Test23_write_with_unique_tag_same_set


// Sequence for a read-miss on I-cache
class Test23_write_with_unique_tag_same_set_seq extends base_vseq;
    //object macro
    `uvm_object_utils(Test23_write_with_unique_tag_same_set_seq)
    bit [`ADDR_WID_LV1-1 : 0] addr[4];
    bit [15:0] tag;
    bit [15:0] discard_tag;
    rand bit [13:0] index;
    bit [1:0] offset;

    
    int ok;

    cpu_transaction_c trans;

    //constructor
    function new (string name="Test23_write_with_unique_tag_same_set_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        ok = randomize(index);
        repeat(100)
        begin    
            
           // `uvm_do_on_with(trans, p_sequencer.cpu_seqr[i], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
           // addr = trans.address;
           // {discard_tag, index, offset} = addr;
                

                
                tag = $urandom_range(16'h4000,16'hffff);
                for (int cpu_num=0; cpu_num<4; cpu_num++) begin
                
                    offset = 0;
                    for(int i =0; i<4; i++) begin
                        addr[i] = {tag + i, index, offset};
                        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[cpu_num], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == addr[i];})

                    end

                    for(int i =0; i<4; i++) begin
                        
                        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[cpu_num], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == addr[i];})

                    end

                end


            
        
        end
    endtask

endclass : Test23_write_with_unique_tag_same_set_seq
