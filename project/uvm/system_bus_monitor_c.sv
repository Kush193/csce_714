//=====================================================================
// Project: 4 core MESI cache design
// File Name: system_bus_monitor_c.sv
// Description: system bus monitor component
// Designers: Venky & Suru
//=====================================================================

`include "sbus_packet_c.sv"

class system_bus_monitor_c extends uvm_monitor;
    //component macro
    `uvm_component_utils(system_bus_monitor_c)

    uvm_analysis_port #(sbus_packet_c) sbus_out;
    sbus_packet_c       s_packet;

    //Covergroup to monitor all the points within sbus_packet
    covergroup cover_sbus_packet;
        option.per_instance = 1;
        option.name = "cover_system_bus";
        REQUEST_TYPE: coverpoint  s_packet.bus_req_type;
        REQUEST_PROCESSOR: coverpoint s_packet.bus_req_proc_num;
        REQUEST_ADDRESS: coverpoint s_packet.req_address{
            option.auto_bin_max = 20;
        }
        READ_DATA: coverpoint s_packet.rd_data{
            option.auto_bin_max = 20;
        }
        //TODO: Add coverage for other fields of sbus_mon_packet
        //LAB6: TO DO: Add coverage for other fields of sbus_mon_packet
        REQ_SNOOP: coverpoint s_packet.bus_req_snoop{
                               bins simul_1_request = {
                                                  4'b0001,
                                                  4'b0010,
                                                  4'b0100,
                                                  4'b1000
                                                };
                               bins simul_2_request = {
                                                  4'b0011,
                                                  4'b0101,
                                                  4'b0110,
                                                  4'b1001,
                                                  4'b1010,
                                                  4'b1100
                                                };
                               bins simul_3_request = {
                                                  4'b0111,
                                                  4'b1011,
                                                  4'b1101,
                                                  4'b1110
                                                };}

        REQ_SERVICED_BY: coverpoint s_packet.req_serviced_by;
        WR_DATA_SNOOP: coverpoint s_packet.wr_data_snoop{
                                bins zero_snoopdata ={0};
                               bins non_zero_snoopdata[10] = {[1:'hFFFFFFFF]};
        }
        SNOOP_WR_REQ_FLAG: coverpoint s_packet.snoop_wr_req_flag;
        CP_IN_CACHE: coverpoint s_packet.cp_in_cache;
        IS_SHARED: coverpoint s_packet.shared;


        EVICT_DIRTY_BLK_ADDR: coverpoint s_packet.proc_evict_dirty_blk_addr{
                               
                               bins zero={0};
                               bins non_zero[10] = {[1:32'hFFFFFFFF]};
                            }

        EVICT_DIRTY_BLK_DATA: coverpoint s_packet.proc_evict_dirty_blk_data{
                                bins zero_data ={0};
                               bins non_zero_data[10] = {[1:'hFFFFFFFF]};
        } 

        EVICT_DIRTY_BLK_FLAG: coverpoint s_packet.proc_evict_dirty_blk_flag;       


        //cross coverage
        //ensure each processor has read miss, write miss, invalidate, etc.
        X_PROC__REQ_TYPE: cross REQUEST_TYPE, REQUEST_PROCESSOR;
        X_PROC__ADDRESS: cross REQUEST_PROCESSOR, REQUEST_ADDRESS;
        X_PROC__DATA: cross REQUEST_PROCESSOR, READ_DATA;
        //TODO: Add relevant cross coverage (examples shown above)
        //LAB6: TO DO: Add relevant cross coverage (examples shown above)
        X_PROC__EVICT_ADDR: cross REQUEST_PROCESSOR, EVICT_DIRTY_BLK_ADDR;
        X_PROC__EVICT_DATA: cross REQUEST_PROCESSOR, EVICT_DIRTY_BLK_DATA;
        X_PROC__SNOOP_WR_REQ_FLAG:cross REQUEST_PROCESSOR, SNOOP_WR_REQ_FLAG;
        X_PROC__CP_IN_CACHE:      cross REQUEST_PROCESSOR, CP_IN_CACHE;
        X_PROC__SHARED:           cross REQUEST_PROCESSOR, IS_SHARED;
   
    endgroup

    // Virtual interface of used to observe system bus interface signals
    virtual interface system_bus_interface vi_sbus_if;

    //constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
        sbus_out = new("sbus_out", this);
        this.cover_sbus_packet = new();
    endfunction : new

    //UVM build phase ()
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // throw error if virtual interface is not set
        if (!uvm_config_db#(virtual system_bus_interface)::get(this, "","v_sbus_if", vi_sbus_if))
            `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vi_sbus_if"})
    endfunction: build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "RUN Phase", UVM_LOW)
        forever begin
        //TODO: Code for the system bus monitor is minimal!
        //Add code to observe other cases
        //Add code for dirty block eviction
        //Snoop requests, service time, etc
        
        //Added code //FIX
            
           // if (vi_sbus_if.ica === 1'b1) //no idea about icache
           //     s_packet.bus_req_type = INVALIDATE; bus_req_snoop 

	
            // trigger point for creating the packet
            @(posedge (|vi_sbus_if.bus_lv1_lv2_gnt_proc));
            `uvm_info(get_type_name(), "Packet creation triggered", UVM_LOW)
            s_packet = sbus_packet_c::type_id::create("s_packet", this);



            // wait for assertion of either bus_rd, bus_rdx or invalidate before monitoring other bus activities
            // lv2_rd for I-cache cases
            @(posedge(vi_sbus_if.bus_rd | vi_sbus_if.bus_rdx | vi_sbus_if.invalidate | vi_sbus_if.lv2_rd |vi_sbus_if.lv2_wr));
            if(vi_sbus_if.lv2_wr)
            begin
            s_packet.proc_evict_dirty_blk_flag = 1'b1;
            s_packet.proc_evict_dirty_blk_addr = vi_sbus_if.addr_bus_lv1_lv2;
            s_packet.proc_evict_dirty_blk_data = vi_sbus_if.data_bus_lv1_lv2;
             @(posedge(vi_sbus_if.bus_rd | vi_sbus_if.bus_rdx | vi_sbus_if.lv2_rd)); //wait for the actual bus rd/wr operation after dirty block is freed
            end
            fork
                begin: cp_in_cache_check
                    // check for cp_in_cache assertion
                    @(posedge vi_sbus_if.cp_in_cache) s_packet.cp_in_cache = 1;
                end : cp_in_cache_check
                begin: shared_check
                    // check for shared signal assertion when data_in_bus_lv1_lv2 is also high
                    wait(vi_sbus_if.shared & vi_sbus_if.data_in_bus_lv1_lv2) s_packet.shared = 1;
                end : shared_check
            join_none

            // bus request type 
            if (vi_sbus_if.bus_rd === 1'b1)
                s_packet.bus_req_type = BUS_RD;
            
            if (vi_sbus_if.bus_rdx === 1'b1)
                s_packet.bus_req_type = BUS_RDX; 
            
            if (vi_sbus_if.invalidate === 1'b1)
                s_packet.bus_req_type = INVALIDATE;

            else if (vi_sbus_if.lv2_rd === 1'b1)
                s_packet.bus_req_type = ICACHE_RD; 




            `uvm_info(get_type_name(), $sformatf("Received SBUS Packet: %d, gen:%d", vi_sbus_if.bus_lv1_lv2_req_snoop, s_packet.bus_req_snoop),UVM_LOW)

            // proc which requested the bus access
            case (1'b1)
                vi_sbus_if.bus_lv1_lv2_gnt_proc[0]: s_packet.bus_req_proc_num = REQ_PROC0;
                vi_sbus_if.bus_lv1_lv2_gnt_proc[1]: s_packet.bus_req_proc_num = REQ_PROC1;
                vi_sbus_if.bus_lv1_lv2_gnt_proc[2]: s_packet.bus_req_proc_num = REQ_PROC2;
                vi_sbus_if.bus_lv1_lv2_gnt_proc[3]: s_packet.bus_req_proc_num = REQ_PROC3;
            endcase

            // address requested
            s_packet.req_address = vi_sbus_if.addr_bus_lv1_lv2;

		    
            // fork and call tasks
            fork: update_info
    begin: snoop0_req_check
                    // check for cp_in_cache assertion
                    @(posedge vi_sbus_if.bus_lv1_lv2_req_snoop[0]) s_packet.bus_req_snoop[0] = 1'b1;
                end : snoop0_req_check
                begin:snoop1_req_check 
                    // check for cp_in_cache assertion
                    @(posedge vi_sbus_if.bus_lv1_lv2_req_snoop[1]) s_packet.bus_req_snoop[1] = 1'b1;
                end : snoop1_req_check
                begin: snoop2_req_check
                    // check for cp_in_cache assertion
                    @(posedge vi_sbus_if.bus_lv1_lv2_req_snoop[2]) s_packet.bus_req_snoop[2] = 1'b1;
                end : snoop2_req_check
                begin: snoop3_req_check
                    // check for cp_in_cache assertion
                    @(posedge vi_sbus_if.bus_lv1_lv2_req_snoop[3]) s_packet.bus_req_snoop[3] = 1'b1;
                end : snoop3_req_check

                begin: snoop_wr_check //check for any snoop side write request to lv2
                     @(posedge vi_sbus_if.lv2_wr)
                     if(|vi_sbus_if.bus_lv1_lv2_gnt_snoop)
                     begin
                     s_packet.snoop_wr_req_flag = 1'b1;
                     s_packet.wr_data_snoop = vi_sbus_if.data_bus_lv1_lv2;
                     end
                end
                               



                // to determine which of snoops or L2 serviced read miss
                begin: req_service_check
                    if ((s_packet.bus_req_type == BUS_RD) || (s_packet.bus_req_type == BUS_RDX))
                    begin
                        @(posedge vi_sbus_if.data_in_bus_lv1_lv2);
                        `uvm_info(get_type_name(), "Bus read or bus readX successful", UVM_LOW)
                        s_packet.rd_data = vi_sbus_if.data_bus_lv1_lv2;
                        // check which had grant asserted
                        case (1'b1)
                            vi_sbus_if.bus_lv1_lv2_gnt_snoop[0]: s_packet.req_serviced_by = SERV_SNOOP0;
                            vi_sbus_if.bus_lv1_lv2_gnt_snoop[1]: s_packet.req_serviced_by = SERV_SNOOP1;
                            vi_sbus_if.bus_lv1_lv2_gnt_snoop[2]: s_packet.req_serviced_by = SERV_SNOOP2;
                            vi_sbus_if.bus_lv1_lv2_gnt_snoop[3]: s_packet.req_serviced_by = SERV_SNOOP3;
                            vi_sbus_if.bus_lv1_lv2_gnt_lv2     : s_packet.req_serviced_by = SERV_L2;
                        endcase

						// Check for the snooping reqs:	
            			//@(posedge (|vi_sbus_if.bus_lv1_lv2_gnt_snoop));
            			s_packet.bus_req_snoop = vi_sbus_if.bus_lv1_lv2_req_snoop; 

						/*
            			if (vi_sbus_if.bus_lv1_lv2_req_snoop[0] === 1'b1)
           					s_packet.bus_req_snoop[0] = 1'b1; 
							
            			if (vi_sbus_if.bus_lv1_lv2_req_snoop[1] === 1'b1)
           					s_packet.bus_req_snoop[1] = 1'b1; 

            			if (vi_sbus_if.bus_lv1_lv2_req_snoop[2] === 1'b1)
           					s_packet.bus_req_snoop[2] = 1'b1; 

            			if (vi_sbus_if.bus_lv1_lv2_req_snoop[3] === 1'b1)
           					s_packet.bus_req_snoop[3] = 1'b1; 
						*/


                    end
					
                end: req_service_check

            join_none : update_info

            // wait until request is processed and send data
            @(negedge vi_sbus_if.bus_lv1_lv2_req_proc[0] or negedge vi_sbus_if.bus_lv1_lv2_req_proc[1] or negedge vi_sbus_if.bus_lv1_lv2_req_proc[2] or negedge vi_sbus_if.bus_lv1_lv2_req_proc[3]);

            `uvm_info(get_type_name(), "Packet to be written", UVM_LOW)

            // disable all spawned child processes from fork
            disable fork;

            // write into scoreboard after population of the packet fields
            sbus_out.write(s_packet);
            cover_sbus_packet.sample();
        end
    endtask : run_phase

endclass : system_bus_monitor_c
