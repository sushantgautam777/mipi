interface dc_inf(input logic pclk,input logic reset_n);

  logic hsync;
  logic vsync;
  logic [23:0] pixel_data;
  logic data_valid;

  clocking drv_cb @(posedge pclk);
    default input #1ns output #0ns;
    output hsync;
    output vsync;
    output pixel_data;
    output data_valid;
  endclocking

  clocking mon_cb @(posedge pclk);
    default input #1ns output #1ns;
    input hsync;
    input vsync;
    input pixel_data;
    input data_valid;
  endclocking

  modport drv_mp(clocking drv_cb,input reset_n);
  modport mon_mp(clocking mon_cb,input reset_n);
endinterface
