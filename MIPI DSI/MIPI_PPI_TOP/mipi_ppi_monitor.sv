class mipi_ppi_monitor extends uvm_monitor;

  `uvm_component_utils(mipi_ppi_monitor)

  virtual mipi_ppi_inf vif;
  uvm_analysis_port #(mipi_ppi_seq_item) ap_port;
  mipi_ppi_seq_item tx;


  function new(string name = "mipi_ppi_monitor",uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual mipi_ppi_inf)::get(this,"","mipi_ppi_inf",
                                                   vif))
      `uvm_fatal("PPI_MON","mipi_ppi_inf not found")
      ap_port = new("ap_port", this);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      tx = mipi_ppi_seq_item::type_id::create("tx");
      @(vif.mon_mp.mon_cb);
      
      if (vif.mon_mp.mon_cb.ppi_lane0_en) begin
        tx.ppi_data_lane0 =vif.mon_mp.mon_cb.ppi_data_lane0;
        tx.ppi_lane0_en =vif.mon_mp.mon_cb.ppi_lane0_en;
      end
      else begin
        tx.ppi_data_lane0 = 0;
        tx.ppi_lane0_en   = 0;
      end
      
      if (vif.mon_mp.mon_cb.ppi_lane1_en) begin
        tx.ppi_data_lane1 =vif.mon_mp.mon_cb.ppi_data_lane1;
        tx.ppi_lane1_en =vif.mon_mp.mon_cb.ppi_lane1_en;
      end
      else begin
        tx.ppi_data_lane1 = 0;
        tx.ppi_lane1_en   = 0;
      end
      
      if (vif.mon_mp.mon_cb.ppi_lane2_en) begin
        tx.ppi_data_lane2 =vif.mon_mp.mon_cb.ppi_data_lane2;
        tx.ppi_lane2_en =vif.mon_mp.mon_cb.ppi_lane2_en;
      end
      else begin
        tx.ppi_data_lane2 = 0;
        tx.ppi_lane2_en   = 0;
      end
      
      if (vif.mon_mp.mon_cb.ppi_lane3_en) begin
        tx.ppi_data_lane3 =
            vif.mon_mp.mon_cb.ppi_data_lane3;

        tx.ppi_lane3_en =
            vif.mon_mp.mon_cb.ppi_lane3_en;

      end
      else begin
        tx.ppi_data_lane3 = '0;
        tx.ppi_lane3_en   = 0;
      end
      
      if (tx.ppi_lane0_en ||
          tx.ppi_lane1_en ||
          tx.ppi_lane2_en ||
          tx.ppi_lane3_en) begin
        `uvm_info("PPI_MON",$sformatf("PPI lanes: L0=%02h L1=%02h L2=%02h L3=%02h | EN=%0b%0b%0b%0b",tx.ppi_data_lane0,tx.ppi_data_lane1,
                                      tx.ppi_data_lane2,tx.ppi_data_lane3,
                                      tx.ppi_lane3_en,
                                      tx.ppi_lane2_en,
                                      tx.ppi_lane1_en,
                                      tx.ppi_lane0_en),UVM_LOW)
        ap_port.write(tx);
      end
    end
  endtask
endclass