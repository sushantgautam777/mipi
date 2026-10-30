class mipi_ahb_seq extends uvm_sequence#(mipi_ahb_seq_item);

  `uvm_object_utils(mipi_ahb_seq)

  function new(string name="mipi_ahb_seq");
    super.new(name);
  endfunction


  task body();
    
    `uvm_do_with(req,{req.haddr  == BUFFER_REG_ADDR;
                      req.hwdata == BUFFER_DATA;
                      req.hwrite == WRITE;
                      req.hsize  == WORD;
                      req.hburst == SINGLE;req.htrans == NONSEQ;
                      req.hprot  == 4'b0000;})
    
    `uvm_do_with(req,{req.haddr  == PACKET_REG_ADDR;
                      req.hwdata == PACKET_DATA;
                      req.hwrite == WRITE;
                      req.hsize  == WORD;
                      req.hburst == SINGLE;
                      req.htrans == NONSEQ;
                      req.hprot  == 4'b0000;})
    
    `uvm_do_with(req,{req.haddr  == DSI_WC_REG_ADDR;
                      req.hwdata == WC_DATA;
                      req.hwrite == WRITE;
                      req.hsize  == WORD;
                      req.hburst == SINGLE;
                      req.htrans == NONSEQ;
                      req.hprot  == 4'b0000;})
    
    `uvm_do_with(req,{req.haddr  == DSI_LANE_REG_ADDR;
                      req.hwdata == LANE_CNT_DATA;
                      req.hwrite == WRITE;
                      req.hsize  == WORD;
                      req.hburst == SINGLE;
                      req.htrans == NONSEQ;
                      req.hprot  == 4'b0000;})
    
    `uvm_do_with(req,{req.haddr  == CTRL_REG_ADDR;
                      req.hwdata == CTRL_DATA;
                      req.hwrite == WRITE;
                      req.hsize  == WORD;
                      req.hburst == SINGLE;
                      req.htrans == NONSEQ;
                      req.hprot  == 4'b0000;})
  endtask
endclass
