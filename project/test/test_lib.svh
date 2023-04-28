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
`include "back_to_back_read_in_same_address.sv"
`include "back_to_back_write_in_same_address.sv"
`include "write_from_all_proc_read_from_all_proc_same_addr.sv"
`include "random_read_write_all_proc.sv"
`include "invalidation_test.sv"