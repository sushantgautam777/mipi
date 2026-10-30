class mipi_dc_mon extends uvm_monitor;

  `uvm_component_utils(mipi_dc_mon)

  virtual dc_inf vif;
  uvm_analysis_port #(mipi_dc_seq_item) mon_port;

  function new(string name = "mipi_dc_mon",uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon_port = new("mon_port", this);
    if (!uvm_config_db#(virtual dc_inf)::get(this, "", "dc_inf", vif))
      `uvm_fatal("DC_MON", "dc_inf not found")
  endfunction


  task run_phase(uvm_phase phase);
    mipi_dc_seq_item item;
    int count;

    forever begin

      item = mipi_dc_seq_item::type_id::create("item");
      item.data_valid = vif.mon_cb.data_valid;
      item.pixel_data = new[`payload_cnt];
      count = 0;
      while (count < `payload_cnt) begin
        @(vif.mon_cb);
        if (vif.mon_cb.data_valid) begin
          item.pixel_data[count] = vif.mon_cb.pixel_data;
          `uvm_info("DC_MON",$sformatf("DC PIXEL[%0d] = %06h",count,
                                       vif.mon_cb.pixel_data),UVM_LOW)
          count=count+1;
        end
      end
     `uvm_info("DC_MON",$sformatf("DC transaction captured: %0d pixels",
                                  count),UVM_MEDIUM)
      
      mon_port.write(item);
    end
  endtask
endclass