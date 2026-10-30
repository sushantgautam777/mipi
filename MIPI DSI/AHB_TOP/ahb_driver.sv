class mipi_ahb_drv extends uvm_driver#(mipi_ahb_seq_item);

  `uvm_component_utils(mipi_ahb_drv)
  
  virtual mipi_ahb_inf vif;
  mipi_ahb_seq_item item;
  
  function new(string name="mipi_ahb_drv",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual mipi_ahb_inf)::get(this,"","mipi_ahb_inf",vif))
      `uvm_fatal("AHB_DRV","mipi_ahb_inf not found");
  endfunction
  
  task reset_bus();
    vif.drv_cb.haddr  <= 32'h0;
    vif.drv_cb.hwdata <= 32'h0;
    vif.drv_cb.hwrite <= 1'b0;
    vif.drv_cb.hsize  <= 3'b000;
    vif.drv_cb.hburst <= 3'b000;
    vif.drv_cb.htrans <= IDLE;
    vif.drv_cb.hprot  <= 4'b0000;
  endtask
  
  task run_phase(uvm_phase phase);
    reset_bus();
    forever begin
      
      wait(vif.hreset_n === 1'b1);
      seq_item_port.get_next_item(item);
      @(vif.drv_cb);
      vif.drv_cb.haddr  <= item.haddr;
      vif.drv_cb.hwrite <= item.hwrite;
      vif.drv_cb.hsize  <= item.hsize;
      vif.drv_cb.hburst <= item.hburst;
      vif.drv_cb.htrans <= NONSEQ;
      vif.drv_cb.hprot  <= item.hprot;
      vif.drv_cb.hwdata <= 32'h0;
      @(vif.drv_cb);

      vif.drv_cb.hwdata <= item.hwdata;
      vif.drv_cb.htrans <= IDLE;
      
      while(vif.drv_cb.hready !== 1'b1)
        @(vif.drv_cb);
      
      @(vif.drv_cb);
      reset_bus();
      seq_item_port.item_done();
    end
  endtask
endclass
