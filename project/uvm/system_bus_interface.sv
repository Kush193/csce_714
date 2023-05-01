//=====================================================================
// Project: 4 core MESI cache design
// File Name: system_bus_interface.sv
// Description: Basic system bus interface including arbiter
// Designers: Venky & Suru
//=====================================================================

interface system_bus_interface(input clk);

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    parameter DATA_WID_LV1        = `DATA_WID_LV1       ;
    parameter ADDR_WID_LV1        = `ADDR_WID_LV1       ;
    parameter NO_OF_CORE            = 4;

    wire [DATA_WID_LV1 - 1 : 0] data_bus_lv1_lv2     ;
    wire [ADDR_WID_LV1 - 1 : 0] addr_bus_lv1_lv2     ;
    wire                        bus_rd               ;
    wire                        bus_rdx              ;
    wire                        lv2_rd               ;
    wire                        lv2_wr               ;
    wire                        lv2_wr_done          ;
    wire                        cp_in_cache          ;
    wire                        data_in_bus_lv1_lv2  ;

    wire                        shared               ;
    wire                        all_invalidation_done;
    wire                        invalidate           ;

    logic [NO_OF_CORE - 1  : 0]   bus_lv1_lv2_gnt_proc ;
    logic [NO_OF_CORE - 1  : 0]   bus_lv1_lv2_req_proc ;
    logic [NO_OF_CORE - 1  : 0]   bus_lv1_lv2_gnt_snoop;
    logic [NO_OF_CORE - 1  : 0]   bus_lv1_lv2_req_snoop;
    logic                       bus_lv1_lv2_gnt_lv2  ;
    logic                       bus_lv1_lv2_req_lv2  ;

//Assertions
//property that checks that signal_1 is asserted in the previous cycle of signal_2 assertion
    property prop_sig1_before_sig2(signal_1,signal_2);
    @(posedge clk)
        signal_2 |-> $past(signal_1);
    endproperty

    property prop_sig2_deassert_before_sig1(signal_1,signal_2);
    @(posedge clk)
        $fell(signal_2) |-> $past(signal_1);
    endproperty

    property is_one_hot(signal);
    @(posedge clk)
        signal |-> $onehot(signal);
    endproperty    

    property prop_sig1_same_cycle_sig2(signal_1,signal_2);
    @(posedge clk)
        $rose(signal_1) |-> $rose(signal_2);
    endproperty

    property prop_sig1_assert_eventually_assert_sig2(signal_1,signal_2);
    @(posedge clk)
        //signal_1 |-> s_eventually (signal_2);
        signal_1 |-> ##[0:$] (signal_2);
        
    endproperty

    property prop_sig1_assert_eventually_in_next_cycle_assert_sig2(signal_1,signal_2);
    @(posedge clk)
        signal_1 |=> s_eventually (signal_2);
    endproperty

    property prop_sig2_deassert_eventually_after_sig1(signal_1,signal_2);
    @(posedge clk)
        $fell(signal_1) |-> s_eventually $fell(signal_2);
    endproperty

     property prop_sig1_assert_eventually_deassert_sig2(signal_1,signal_2);
    @(posedge clk)
        signal_1 |-> s_eventually (!signal_2);
    endproperty

       property deassert_sig1_after_sig2_assert(signal_1,signal_2);
      @(posedge clk)
         $rose(signal_2) |=> $fell(signal_1);
       endproperty

    property no_assert_sig1_and_sig2(signal_1,signal_2);
      @(posedge clk)
         not(signal_1 && signal_2);
    endproperty


//ASSERTION1: lv2_wr_done should not be asserted without lv2_wr being asserted in previous cycle
    assert_lv2_wr_done: assert property (prop_sig1_before_sig2(lv2_wr,lv2_wr_done))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_lv2_wr_done Failed: lv2_wr not asserted before lv2_wr_done goes high"))


//TODO: Add assertions at this interface
//There are atleast 20 such assertions. Add as many as you can!!

//LAB5: TO DO: Add 4 assertions at this interface
//ASSERTION2: data_in_bus_lv1_lv2 and cp_in_cache should not be asserted without lv2_rd being asserted in previous cycle
    assert_lvl2_rd_cp_in_cache: assert property (prop_sig1_before_sig2(lv2_rd, cp_in_cache)) 
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_lvl2_rd_&_cp_in_cache Failed: lvl2_rd not asserted before cp_in_cache goes high"))

    assert_lvl2_rd_data_in_bus_lv1_lv2: assert property (prop_sig1_before_sig2(lv2_rd, data_in_bus_lv1_lv2)) 
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_lvl2_rd_&_data_bus_lv1_lv2 Failed: lv2_rd not asserted before data_bus_lv1_lv2 goes high"))

////ASSERTION3: bus_lv1_lv2_gnt_proc is one hot
    assert_one_hot_bus_lv1_lv2_gnt_proc: assert property (is_one_hot(bus_lv1_lv2_gnt_proc))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_one_hot_bus_lv1_lv2_gnt_proc Failed: bus_lv1_lv2_gnt_proc is not one hot"))

////ASSERTION4: bus_lv1_lv2_gnt_snoop is one hot
    assert_one_hot_bus_lv1_lv2_gnt_snoop: assert property (is_one_hot(bus_lv1_lv2_gnt_snoop))  
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_one_hot_bus_lv1_lv2_gnt_snoop Failed: one_hot_bus_lv1_lv2_gnt_snoop is not one hot"))

////ASSERTION5: shared is asserted when data_bus_lv1_lv2 is also asserted in the same cycle
   // assert_shared_data_in_bus_lv1_lv2: assert property(prop_sig1_same_cycle_sig2(shared, data_in_bus_lv1_lv2))
   // else
      //  `uvm_error("system_bus_interface",$sformatf("Assertion assert_shared_data_in_bus_lv1_lv2 Failed: shared and data_in_bus_lv1_lv2 not asserted in the same cycle"))

////ASSERTION6: if bus_lv1_lv2_req_proc asserted then bus_lv1_lv2_gnt_proc should be also asserted 
//\    assert_bus_lv1_lv2_req_proc[0]_bus_lv1_lv2_gnt_proc[0]: assert property(prop_sig1_assert_eventually_assert_sig2(bus_lv1_lv2_req_proc[0], bus_lv1_lv2_gnt_proc[0]))
//    else 
//        `uvm_error("system_bus_interface",$sformatf("Assertion bus_lv1_lv2_req_proc[0]_bus_lv1_lv2_gnt_proc[0] Failed: bus_lv1_lv2_req_proc[0] and bus_lv1_lv2_gnt_proc[0] not asserted eventually"))

////ASSERTION6: if bus_lv1_lv2_gnt_proc is asserted then bus_rd and lv2_rd should be also asserted 
    assert_bus_lv1_lv2_gnt_proc_bus_rd: assert property(prop_sig1_assert_eventually_assert_sig2((|bus_lv1_lv2_gnt_proc), (bus_rd && lv2_rd)))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_bus_lv1_lv2_gnt_proc_bus_rd Failed: bus_lv1_lv2_gnt_proc is asserted and bus_rd is not asserted eventually"))

    assert_bus_lv1_lv2_gnt_proc_lv2_rd_or_lv2_wr: assert property(prop_sig1_assert_eventually_assert_sig2((|bus_lv1_lv2_gnt_proc), (lv2_rd || lv2_wr)))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_bus_lv1_lv2_gnt_proc_lv2_rd_or_lv2_wr Failed: bus_lv1_lv2_gnt_proc is asserted and lv2_rd or lv2_wr is not asserted eventually"))

////ASSERTION7: if bus_rd or bus_rdx is asserted then and lv2_rd should be also asserted  
    assert_bus_rd_and_lv2_rd: assert property(prop_sig1_same_cycle_sig2((bus_rd || bus_rdx),lv2_rd))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_bus_rd_and_lv2_rd Failed: Neither bus_rd nor bus_rdx is asserted in same cylce when lv2_rd is asserted"))

////ASSERTION8: if cp_in_cache is asserted then and bus_lv1_lv2_req_snoop should be also asserted  
    assert_lv2_wr_done_data_in_bus: assert property(prop_sig1_assert_eventually_assert_sig2(lv2_wr_done, data_in_bus_lv1_lv2))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_lv2_wr_done_data_in_bus Failed: lv2_wr_done is asserted and data_in_bus_lv1_lv2 is not asserted eventually"))

//ASSERTION9 - bus_lv1_lv2_gnt_proc sometime before invaldiate - done

////ASSERTION10: If invalidate is asserted eventually assert all_invalidation_done
assert_invalidate_and_all_invalidation: assert property(prop_sig1_assert_eventually_assert_sig2(invalidate, all_invalidation_done))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_invalidate_and_all_invalidation Failed: invalidate is asserted and all_invalidation_done is not asserted eventually"))


////ASSERTION11: If lv2_rd is asserted eventually assert bus_lv1_lv2_req_lv2
assert_lv_rd_bus_lv1_lv2_req_lv2: assert property(prop_sig1_assert_eventually_assert_sig2(lv2_rd, bus_lv1_lv2_req_lv2))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_lv_rd_bus_lv1_lv2_req_lv2 Failed: lv2_rd is asserted and bus_lv1_lv2_req_lv2 is not asserted eventually"))

////ASSERTION12: If is bus_lv1_lv2_gnt_lv2 asserted eventually assert data_in_bus_lv1_lv2 
assert_bus_lv1_lv2_gnt_lv2_data_in_bus_lv1_lv2: assert property(prop_sig1_assert_eventually_assert_sig2(bus_lv1_lv2_gnt_lv2, data_in_bus_lv1_lv2))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_bus_lv1_lv2_gnt_lv2_data_in_bus_lv1_lv2 Failed: bus_lv1_lv2_gnt_lv2 is asserted and data_in_bus_lv1_lv2 is not asserted eventually"))

////ASSERTION13: data_in_bus_lv1_lv2 is deasserted after lv2_rd is deaaserted 
//assert_data_in_bus_lv1_lv2_deassert_after_lv2_rd: assert property(prop_sig2_deassert_eventually_after_sig1(lv2_rd, data_in_bus_lv1_lv2))
//    else
//        `uvm_error("system_bus_interface",$sformatf("Assertion assert_bus_lv1_lv2_gnt_lv2_data_in_bus_lv1_lv2 Failed: bus_lv1_lv2_gnt_lv2 is asserted and data_in_bus_lv1_lv2 is not asserted eventually"))

////ASSERTION14: If cp_in_cache is asserted bus_lv1_lv2_req_lv2 is deasserted 
assert_cp_in_cache_deassert_bus_lv1_lv2_req_lv2: assert property(prop_sig1_assert_eventually_deassert_sig2(cp_in_cache, bus_lv1_lv2_req_lv2))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_cp_in_cache_deassert_bus_lv1_lv2_req_lv2 Failed: bus_lv1_lv2_gnt_lv2 is not deasserted after cp_in_cache is asserted"))

////ASSERTION15: data_in_bus_lv1_lv2 is deasserted after lv2_rd is deaaserted 
assert_lv2_wr_done_deassert_after_lv2_wr_deassert: assert property(prop_sig2_deassert_eventually_after_sig1(lv2_wr, lv2_wr_done))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_bus_lv1_lv2_gnt_lv2_data_in_bus_lv1_lv2 Failed: bus_lv1_lv2_gnt_lv2 is asserted and data_in_bus_lv1_lv2 is not asserted eventually"))

////ASSERTION16: When lv2_wr_done is asserted, lv2_wr should be deasserted in next clock cycle.
assert_lv2_wr: assert property(deassert_sig1_after_sig2_assert(lv2_wr,lv2_wr_done))
    else
       `uvm_error("system_bus_interface",$sformatf("Assertion deassert_sig1_after_sig2_assert Failed: lv2_wr not deasserted after lv2_wr_done goes high"))

////ASSERTION17: bus_rd and bus_rdx cannot be asserted simultaneously.
assert_no_bus_rd_and_bus_rdx: assert property (no_assert_sig1_and_sig2(bus_rd,bus_rdx))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_no_bus_rd_and_bus_rdx Failed: bus_rd and bus_rdx asserted simultaneously"))        



endinterface
