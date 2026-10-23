// Code your testbench here
// or browse Examples
`timescale 1ns/1ns



`define payload_cnt 1280
`define hsync_cnt   720
`define vsync_cnt   720

// ---------------- AHB constants ----------------
`define WRITE   1'b1
`define READ    1'b0

`define WORD    3'b010
`define SINGLE  3'b000

`define IDLE    2'b00
`define NONSEQ  2'b10

// ---------------- DSI register addresses ----------------
`define BUFFER_REG_ADDR    32'h4000_0000
`define PACKET_REG_ADDR    32'h4000_0004
`define DSI_WC_REG_ADDR    32'h4000_0008
`define DSI_LANE_REG_ADDR  32'h4000_000C
`define CTRL_REG_ADDR      32'h4000_0010

// ---------------- Test data ----------------
`define BUFFER_DATA        32'h0000_0000 // data we are putting in dut payload before dc takes over 
`define PACKET_DATA        32'h0000_0029 //command 
`define WC_DATA            32'h0000_0000 //lenght
`define LANE_CNT_DATA      32'h0000_0001//for selecting lanes 
`define CTRL_DATA          32'h0000_0001 //control unknow not specif in rtl

// INTERFACES
import uvm_pkg::*;
`include "ahb_inf.sv"
`include "mipi_dc_interface.sv"
`include "mipi_ppi_inf.sv"

// AHB UVM COMPONENTS
`include "ahb_seq_item.sv"
`include "ahb_seqr.sv"
`include "ahb_driver.sv"
`include "ahb_mon.sv"
`include "ahb_agent.sv"
`include "ahb_seq.sv"

// DC / VIDEO UVM COMPONENTS


`include "mipi_dc_seq_item.sv"
`include "mipi_dc_sequencer.sv"
`include "mipi_dc_drv.sv"
`include "mipi_dc_monitor.sv"
`include "mipi_dc_agent.sv"
`include "mipi_dc_sequence.sv"


// PPI UVM COMPONENTS

`include "mipi_ppi_seq_item.sv"
`include "mipi_ppi_seqr.sv"
`include "mipi_ppi_monitor.sv"
`include "mipi_ppi_agent.sv"

// SCOREBOARD

`include "MY_scoreboard.sv"

// COVERAGE

`include "ahb_cov.sv"
`include "dc_cov.sv"
`include "ppi_cov.sv"

// ENVIRONMENT

`include "environment.sv"

// VIRTUAL SEQUENCER / VIRTUAL SEQUENCE

`include "mipi_dsi_top_seqr.sv"
`include "mipi_dsi_top_seq.sv"

// TEST

`include "test.sv"

// TOP-LEVEL TESTBENCH

module tb_top;
  // CLOCK / RESET

  logic pclk;
  logic dsi_rst;
  logic dsi_clk;



  mipi_ahb_inf ahb_vif (
    .hclk     (pclk),
    .hreset_n (dsi_rst)
  );

  dc_inf dc_vif (
    .pclk    (pclk),
    .reset_n (dsi_rst)
  );

  mipi_ppi_inf ppi_vif (
    .dsi_clk (dsi_clk),
    .reset_n (dsi_rst)
  );


 //dut

  dsi #(
    .FRAME_LENGTH (1280),
    .FRAME_DEPTH  (720)
  ) dut (

    // ---------------- AHB ----------------
    .haddr  (ahb_vif.haddr),
    .hwrite (ahb_vif.hwrite),
    .hsize  (ahb_vif.hsize),
    .hburst (ahb_vif.hburst),
    .htrans (ahb_vif.htrans),
    .hwdata (ahb_vif.hwdata),
    .hprot  (ahb_vif.hprot),

    .hresp  (ahb_vif.hresp),
    .hready (ahb_vif.hready),
    .hrdata (ahb_vif.hrdata),

    // ---------------- DC / VIDEO ----------------
    .pixel_data (dc_vif.pixel_data),
    .data_valid (dc_vif.data_valid),
    .hsync      (dc_vif.hsync),
    .vsync      (dc_vif.vsync),

    // ---------------- CLOCK / RESET ----------------
    .pclk    (pclk),
    .dsi_rst (dsi_rst),
    .dsi_clk (dsi_clk),

    // ---------------- PPI ----------------
    .ppi_data_lane0 (ppi_vif.ppi_data_lane0),
    .ppi_data_lane1 (ppi_vif.ppi_data_lane1),
    .ppi_data_lane2 (ppi_vif.ppi_data_lane2),
    .ppi_data_lane3 (ppi_vif.ppi_data_lane3),

    .ppi_lane0_en (ppi_vif.ppi_lane0_en),
    .ppi_lane1_en (ppi_vif.ppi_lane1_en),
    .ppi_lane2_en (ppi_vif.ppi_lane2_en),
    .ppi_lane3_en (ppi_vif.ppi_lane3_en)
  );

  // PCLK GENERATION
 

  initial begin
    pclk = 1'b0;

    forever begin
      #5 pclk = ~pclk;
    end
  end

  // RESET GENERATION


  initial begin

    dsi_rst = 1'b0;

    repeat (5)
      @(posedge pclk);

    dsi_rst = 1'b1;

  end

  // UVM CONFIGURATION

  initial begin

    // AHB virtual interface
    uvm_config_db#(virtual mipi_ahb_inf)::set(
      null,
      "*",
      "mipi_ahb_inf",
      ahb_vif
    );

    // DC virtual interface
    uvm_config_db#(virtual dc_inf)::set(
      null,
      "*",
      "dc_inf",
      dc_vif
    );

    // PPI virtual interface
    uvm_config_db#(virtual mipi_ppi_inf)::set(
      null,
      "*",
      "mipi_ppi_inf",
      ppi_vif
    );

    // Start UVM
    run_test("mipi_dsi_test");

  end


 //for wave

  initial begin

    $dumpfile("dump.vcd");
    $dumpvars();

  end

endmodule