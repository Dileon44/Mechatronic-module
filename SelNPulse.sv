module SelNPulse (input Clk, output Ena);
parameter N = 10;
logic [$clog2(N)-1:0] Cnt = 0;
assign Ena = (Cnt == 0);
always_ff @(posedge Clk)
if (Ena) Cnt <= N - 1;
else Cnt <= Cnt - 1;
endmodule: SelNPulse