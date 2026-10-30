interface mipi_ahb_inf(input logic hclk,input logic hreset_n);

  logic [31:0] haddr;
  logic hwrite;
  logic [2:0] hsize;
  logic [2:0] hburst;
  logic [1:0] htrans;
  logic [3:0] hprot;
  logic [31:0]hwdata;
  logic [31:0] hrdata;
  logic hready;
  logic [1:0] hresp;
  
  clocking drv_cb @(posedge hclk);
    default input #1ns output #0ns;
    output haddr;
    output hwrite;
    output hsize;
    output hburst;
    output htrans;
    output hprot;
    output hwdata;
    input hrdata;
    input hready;
    input hresp;
  endclocking
  
  clocking mon_cb @(posedge hclk);
    input haddr;
    input hwrite;
    input hsize;
    input hburst;
    input htrans;
    input hprot;
    input hwdata;
    input hrdata;
    input hready;
    input hresp;
  endclocking
  
  modport drv_mp(clocking drv_cb,input hreset_n);
  modport mon_mp(clocking mon_cb,input hreset_n);
endinterface
