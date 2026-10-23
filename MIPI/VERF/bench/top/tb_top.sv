module tb_top;

  logic pclk;
  logic dsi_rst;
  logic dsi_clk;

  // Interfaces

  mipi_ahb_inf ahb_vif (
    .hclk     (pclk),
    .hreset_n (dsi_rst)
  );

  dc_inf dc_vif (
    .pclk     (pclk),
    .reset_n  (dsi_rst)
  );

  mipi_ppi_inf ppi_vif (
    .dsi_clk  (dsi_clk),
    .reset_n  (dsi_rst)
  );

  // DUT

  dsi #(
    .FRAME_LENGTH(1280),
    .FRAME_DEPTH (720)
  ) dut (
    .haddr          (ahb_vif.haddr),
    .hwrite         (ahb_vif.hwrite),
    .hsize          (ahb_vif.hsize),
    .hburst         (ahb_vif.hburst),
    .htrans         (ahb_vif.htrans),
    .hwdata         (ahb_vif.hwdata),
    .hprot          (ahb_vif.hprot),

    .hresp          (ahb_vif.hresp),
    .hready         (ahb_vif.hready),
    .hrdata         (ahb_vif.hrdata),

    .pixel_data     (dc_vif.pixel_data),
    .data_valid     (dc_vif.data_valid),
    .hsync          (dc_vif.hsync),
    .vsync          (dc_vif.vsync),
    .pclk           (pclk),

    .dsi_rst        (dsi_rst),

    .dsi_clk        (dsi_clk),

    .ppi_data_lane0 (ppi_vif.ppi_data_lane0),
    .ppi_data_lane1 (ppi_vif.ppi_data_lane1),
    .ppi_data_lane2 (ppi_vif.ppi_data_lane2),
    .ppi_data_lane3 (ppi_vif.ppi_data_lane3),

    .ppi_lane0_en   (ppi_vif.ppi_lane0_en),
    .ppi_lane1_en   (ppi_vif.ppi_lane1_en),
    .ppi_lane2_en   (ppi_vif.ppi_lane2_en),
    .ppi_lane3_en   (ppi_vif.ppi_lane3_en)
  );

  // PCLK generation

  initial begin
    pclk = 1'b0;

    forever begin
      #5 pclk = ~pclk;
    end
  end

  // Reset
  // DUT reset is ACTIVE LOW

  initial begin
    dsi_rst = 1'b0;

    repeat(5)
      @(posedge pclk);

    dsi_rst = 1'b1;
  end
  // UVM configuration

  initial begin

    uvm_config_db#(virtual mipi_ahb_inf)::set(
      null,
      "*",
      "ahb_vif",
      ahb_vif
    );

    uvm_config_db#(virtual dc_inf)::set(
      null,
      "*",
      "dc_vif",
      dc_vif
    );

    uvm_config_db#(virtual mipi_ppi_inf)::set(
      null,
      "*",
      "ppi_vif",
      ppi_vif
    );

    run_test();

  end

endmodule