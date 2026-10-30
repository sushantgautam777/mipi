class mipi_ahb_mon extends uvm_monitor;

  `uvm_component_utils(mipi_ahb_mon)
  
  virtual mipi_ahb_inf vif;
  uvm_analysis_port #(mipi_ahb_seq_item) mon_port;
  
  function new(string name="mipi_ahb_mon",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon_port = new("mon_port",this);
    if(!uvm_config_db#(virtual mipi_ahb_inf)::get(this,"","mipi_ahb_inf",vif))
      `uvm_fatal("AHB_MON","mipi_ahb_inf not found");
  endfunction
  
  task run_phase(uvm_phase phase);
    mipi_ahb_seq_item item;
    forever begin
      @(vif.mon_cb);
      
      if(vif.mon_cb.hready && vif.mon_cb.hwrite) begin
        item =mipi_ahb_seq_item::type_id::create("item");
        item.haddr  = vif.mon_cb.haddr;
        item.hwdata = vif.mon_cb.hwdata;
        item.hwrite = vif.mon_cb.hwrite;
        item.hsize  = vif.mon_cb.hsize;
        item.hburst = vif.mon_cb.hburst;
        item.htrans = vif.mon_cb.htrans;
        item.hprot  = vif.mon_cb.hprot;
        
        mon_port.write(item);
        `uvm_info("AHB_MON",$sformatf("WRITE ADDR=%08h DATA=%08h",item.haddr,item.hwdata),UVM_MEDIUM);
      end
    end
  endtask
endclass