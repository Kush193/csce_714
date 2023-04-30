//=====================================================================
// Project: 4 core MESI cache design
// File Name: cpu_lv1_interface.sv
// Description: Basic CPU-LV1 interface with assertions
// Designers: Venky & Suru
//=====================================================================


interface cpu_lv1_interface(input clk);

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    parameter DATA_WID_LV1           = `DATA_WID_LV1       ;
    parameter ADDR_WID_LV1           = `ADDR_WID_LV1       ;

    reg   [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1_reg    ;

    wire  [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1        ;
    logic [ADDR_WID_LV1 - 1   : 0] addr_bus_cpu_lv1        ;
    logic                          cpu_rd                  ;
    logic                          cpu_wr                  ;
    logic                          cpu_wr_done             ;
    logic                          data_in_bus_cpu_lv1     ;

    assign data_bus_cpu_lv1 = data_bus_cpu_lv1_reg ;

//Properties
    property prop_signal2_before_signal1(signal1,signal2);
        @(posedge clk)
          $rose(signal2) |=> $fell(signal1);
    endproperty

     property prop_sig2_deassert_before_sig1(signal_1,signal_2);
    @(posedge clk)
        ($past(signal_2) && (!signal_2))  |-> $past(signal_1);
    endproperty 

/*     property prop_sig2_deassert_before_sig1(signal_1,signal_2);
    @(posedge clk)
        $fell(signal_2) |-> $past(signal_1);
    endproperty */

    property prop_signal2_deassert_after_signal1_deassert(signal1,signal2);
        @(posedge clk)
          $fell(signal1) |-> $fell(signal1) ##[1:$] $fell(signal2);
    endproperty

    property prop_signal2_assert_after_signal1_assert(signal1,signal2);
        @(posedge clk)
          $rose(signal1) |-> $rose(signal1) ##[1:$] $rose(signal2);
    endproperty  

//Assertions
//ASSERTION1: cpu_wr and cpu_rd should not be asserted at the same clock cycle 
    property prop_simult_cpu_wr_rd;
        @(posedge clk)
          not(cpu_rd && cpu_wr);
    endproperty

    assert_simult_cpu_wr_rd: assert property (prop_simult_cpu_wr_rd)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_simult_cpu_wr_rd Failed: cpu_wr and cpu_rd asserted simultaneously"))

//TODO: Add assertions at this interface

//ASSERTION2: cpu_wr_done is asserted 1 cycle before cpu_wr is deasserted
    assert_cpu_wr_done_before_cpu_wr: assert property (prop_signal2_before_signal1(cpu_wr, cpu_wr_done))
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_cpu_wr_done_before_cpu_wr Failed: cpu_wr_done is not asserted one cycle before cpu_wr is deasserted"))

//ASSERTION3: cpu_wr_done is deasserted after cpu_wr is deasserted
    assert_cpu_wr_done_deassert_cpu_wr_deassert: assert property (prop_signal2_deassert_after_signal1_deassert(cpu_wr, cpu_wr_done))
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_cpu_wr_done_deassert_cpu_wr_deassert Failed: cpu_wr_done is not deasserted after cpu_wr is deasserted"))

//ASSERTION4: cpu_wr_done is asserted after cpu_wr is asserted
    assert_cpu_wr_done_assert_cpu_wr_assert: assert property (prop_signal2_assert_after_signal1_assert(cpu_wr, cpu_wr_done))
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_cpu_wr_done_assert_cpu_wr_assert Failed: cpu_wr_done is not asserted after cpu_wr is asserted"))

//ASSERTION5: data_in_bus_cpu_lv1 is asserted after cpu_rd is asserted
    assert_data_in_bus_cpu_lv1_cpu_rd_assert: assert property (prop_signal2_assert_after_signal1_assert(cpu_rd, data_in_bus_cpu_lv1))
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_data_in_bus_cpu_lv1_cpu_rd_assert Failed: data_in_bus_cpu_lv1 is not asserted after cpu_rd is asserted"))

////ASSERTION6: if cpu_wr deasserted then in previous cyle cpu_wr_done should be high
assert_cpu_wr_cpu_wr_done: assert property (prop_sig2_deassert_before_sig1(cpu_wr_done,cpu_wr))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_cpu_wr_cpu_wr_done Failed: when cpu_wr deasserted then in previous cyle cpu_wr_done is not high"))  

endinterface
