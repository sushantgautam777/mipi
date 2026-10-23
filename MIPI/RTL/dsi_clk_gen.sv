
module dsi_clk_gen(
  input      pclk,
  output reg dsi_clk
);

  real pclk_period;
  real dsi_clk_period;
  time t1, t2;

  initial begin
    dsi_clk     = 0;
    pclk_period = 0;
  end

  initial begin
    @(posedge pclk); 
    t1 = $time;
    @(posedge pclk); 
    t2 = $time;
    pclk_period    = t2 - t1;
    dsi_clk_period = pclk_period / 3.0;   // fixed 3:1 ratio, always
  end

  always @(posedge pclk) 
   begin
     disable dsi_toggle_blk; //to stop last leftover fork join
    if(pclk_period!=0) 
      begin
      fork:dsi_toggle_blk
        begin
          repeat(6)//toggle clk
           begin
            #(dsi_clk_period / 2.0);
            dsi_clk = ~dsi_clk;
           end
        end
      join_none
      end
  end
endmodule


/*
module dsi_clk_gen(
  input        pclk,
  output reg   dsi_clk
);

  real pclk_period;
  real dsi_clk_period;
  time t1, t2;
  reg [2:0] DIV;

  initial begin
    dsi_clk     = 0;
    pclk_period = 0;
  end

  //--------------------------------------------------------------
  // Measure pclk period ONCE, in its own independent process.
  //--------------------------------------------------------------
  initial begin
    @(posedge pclk); t1 = $time;
    @(posedge pclk); t2 = $time;
    pclk_period = t2 - t1;
  end

  //--------------------------------------------------------------
  // DIV: number of dsi_clk cycles per pclk cycle, decoded live
  // from dsi_ctrl0[1:0].
  //--------------------------------------------------------------
  always @(*) begin
    case (dsi.dsi_reg.dsi_ctrl0[1:0])
      2'b00: DIV = 1;
      2'b01: DIV = 2;
      2'b10: DIV = 3;
      2'b11: DIV = 4;
      default: DIV = 1;
    endcase
  end

always @(posedge pclk) 
begin
    disable dsi_toggle_blk;
    if (pclk_period != 0)
     begin
      dsi_clk_period = pclk_period / DIV;
      fork : dsi_toggle_blk
        repeat (2*DIV) 
         begin
         #(dsi_clk_period/2.0);
          dsi_clk = ~dsi_clk;
         end
      join_none
      end
end

endmodule
*/

/*
module dsi_clk_gen(
  input      pclk,
  output reg dsi_clk
);

  real pclk_period;
  real dsi_clk_period;
  time t1, t2;

  initial begin
    dsi_clk     = 0;
    pclk_period = 0;
  end

  // Measure pclk period once, accurately, in its own process.
  initial begin
    @(posedge pclk); t1 = $time;
    @(posedge pclk); t2 = $time;
    pclk_period    = t2 - t1;
    dsi_clk_period = pclk_period / 3.0;   // fixed 3:1 ratio, always
  end

  // Free-running dsi_clk generator: independent process, never
  // resynced to pclk edges, so it can never race against them or
  // lose a toggle. With 1ps timescale resolution, the fractional
  // (10/3 = 3.333...ns) rounding error is ~0.03% per cycle --
  // negligible drift even over a long simulation.
  always begin
    wait (pclk_period != 0);
    #(dsi_clk_period / 2.0);
    dsi_clk = ~dsi_clk;
  end

endmodule
*/

/*
module dsi_clk_gen(
  input      pclk,
  output reg dsi_clk
);
  real pclk_period;
  real dsi_clk_period;
  time t1, t2;

  initial begin
    dsi_clk     = 0;
    pclk_period = 0;
  end

  initial begin
    @(posedge pclk); t1 = $time;
    @(posedge pclk); t2 = $time;
    pclk_period    = t2 - t1;
    dsi_clk_period = pclk_period / 3.0;
  end

  always begin
    wait (pclk_period != 0);
    #(dsi_clk_period / 2.0);
    dsi_clk = ~dsi_clk;
  end
endmodule
*/

