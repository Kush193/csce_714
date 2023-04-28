//=====================================================================
// Project: 4 core MESI cache design
// File Name: test_lib.svh
// Description: Base test class and list of tests
// Designers: Venky & Suru
//=====================================================================
//TODO: add your testcase files in here
`include "base_test.sv"
`include "read_miss_icache.sv"
`include "read_miss_dcache.sv"
`include "write_miss_icache.sv"
`include "write_miss_dcache.sv"
`include "back_to_back_read_same_adder.sv"
`include "back_to_back_write_same_adder.sv"
`include "random_read_write_all_proc.sv"
`include "invalidation_test.sv"
`include "read_followed_by_write.sv"