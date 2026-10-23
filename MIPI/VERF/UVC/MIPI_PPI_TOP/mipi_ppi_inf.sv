interface mipi_ppi_inf(input logic dsi_clk, input logic reset_n);
  logic [7:0] ppi_data_lane0;
  logic [7:0] ppi_data_lane1;
  logic [7:0] ppi_data_lane2;
  logic [7:0] ppi_data_lane3;
  logic ppi_lane0_en;
  logic ppi_lane1_en;
  logic ppi_lane2_en;
  logic ppi_lane3_en;
  
  clocking mon_cb @(posedge dsi_clk);
    default input #1ns output #0ns;
    
    input ppi_data_lane0;
    input ppi_data_lane1;
    input ppi_data_lane2;
    input ppi_data_lane3;
    input ppi_lane0_en;
    input ppi_lane1_en;
    input ppi_lane2_en;
    input ppi_lane3_en;
  endclocking
  
  modport mon_mp(clocking mon_cb);
endinterface