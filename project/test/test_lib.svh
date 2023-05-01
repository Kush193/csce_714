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
`include "Test1_back_to_back_2_reads.sv"
`include "Test2_back_to_back_2_writes.sv"
`include "Test3_reads_with_unique_tag_same_set.sv"
`include "replacement_policy_check.sv"
`include "Test4_write_all_proc_read_all_proc_same_addr.sv"
`include "Test5_random_read_write_all_proc.sv"
`include "Test6_random_parallel_read_write_all_proc.sv"
`include "Test7_inorder_read_parallel_read_all_proc.sv"
`include "Test8_random_parallel_read_write_all_proc.sv"
`include "Test_12_read_miss_l1_cache_no_free_modified.sv"
`include "Test_13_write_hit_L1cache_shar_excl_cache.sv"
`include "Test_14_wr_hit_block_shared.sv"
`include "Test_15_write_miss_l1_cache_no_free_exclusive.sv"
`include "Test_16_write_miss_dcache_free_blk_shared.sv"
`include "Test_17_write_miss_L1cache_free_block_modified_cache.sv"
`include "Test_18_write_miss_dcache_replacement_block_modified.sv"
`include "Test_19_l1_cache_lru.sv"
`include "Test_20_icache_ro_dcache_rw.sv"
`include "Test_21_random_parallel_4_cpu_rd_wr.sv"
`include "Test_22_wr_miss_nofree_block_shrd_or_excl.sv"
`include "Test23_write_with_unique_tag_same_set.sv"


