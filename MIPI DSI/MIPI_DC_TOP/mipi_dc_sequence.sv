class mipi_dc_seq extends uvm_sequence #(mipi_dc_seq_item);
  `uvm_object_utils(mipi_dc_seq)

  function new(string name = "mipi_dc_seq");
    super.new(name);
  endfunction

  task body();

    mipi_dc_seq_item req;
    int pixel;   

    repeat(`vsync_cnt) begin
      repeat(`hsync_cnt) begin
        req = mipi_dc_seq_item::type_id::create("req");
        start_item(req);

        if (!req.randomize())
          `uvm_fatal("DC_SEQ", "DC transaction randomization failed");
        for(pixel = 0; pixel < `payload_cnt; pixel++) begin
          req.pixel_data[pixel] = $urandom;
        end

        finish_item(req);
      end
    end
  endtask
endclass