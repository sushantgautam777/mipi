class mipi_dc_drv extends uvm_driver#(mipi_dc_seq_item);

  `uvm_component_utils(mipi_dc_drv)

  virtual dc_inf vif;
  mipi_dc_seq_item item;
  int line_count;


  function new(string name="mipi_dc_drv",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual dc_inf)::get(this,"","dc_inf",vif))
      `uvm_fatal("DC_DRV","dc_inf not found");
  endfunction


  task reset_dc();
    vif.drv_cb.vsync      <= 1'b0;
    vif.drv_cb.hsync      <= 1'b0;
    vif.drv_cb.data_valid <= 1'b0;
    vif.drv_cb.pixel_data <= 24'h0;
  endtask


  task run_phase(uvm_phase phase);
    line_count = 0;
    reset_dc();
    forever begin
      wait(vif.reset_n === 1'b1);
      
      seq_item_port.get_next_item(item);
      
      if(line_count == 0) begin //start of frame
        vif.drv_cb.vsync <= 1'b1;
        vif.drv_cb.hsync <= 1'b0;
        vif.drv_cb.data_valid <= 1'b0;
        vif.drv_cb.pixel_data <= 24'h0;
        
        repeat(item.vsa)
          @(vif.drv_cb);
        
        vif.drv_cb.vsync <= 1'b0;
        
        repeat(item.vbp) //vbp
          @(vif.drv_cb);
      end
      
      vif.drv_cb.hsync <= 1'b1; //HSYNC
      vif.drv_cb.data_valid <= 1'b0;
      
      repeat(item.hsa)
        @(vif.drv_cb);
      
      vif.drv_cb.hsync <= 1'b0;
      
      repeat(item.hbp)
        @(vif.drv_cb);
      
      foreach(item.pixel_data[i]) begin
        vif.drv_cb.pixel_data <=item.pixel_data[i];
        vif.drv_cb.data_valid <= 1'b1;
        @(vif.drv_cb);
      end
      
      vif.drv_cb.data_valid <= 1'b0;
      vif.drv_cb.pixel_data <= 24'h0;
      
      repeat(item.hfp)
        @(vif.drv_cb);
      
      line_count++;
      
      if(line_count == `hsync_cnt) begin //endof frame

        line_count = 0;
        repeat(item.vfp)
          @(vif.drv_cb);
      end
      seq_item_port.item_done();
    end
  endtask
endclass
