module FormationPause (Clock, I, O);

parameter ArmNum  = 2,
          Periods = 50;
localparam SWNum  = 2*ArmNum;

input bit Clock;
input  logic [SWNum:1] I;
output logic [SWNum:1] O = 0;

logic [SWNum:1] Enable;

generate
if (Periods > 0) begin
   	logic [SWNum:1] Front;
   	logic [SWNum:1] D, M;
   	logic [$clog2(Periods + 1) - 1:0] Counter = 0;
   	logic Zero;

   	assign Zero = (Counter == 0);

	always @(posedge Clock) begin
		D <= I;
	end
	assign Front = ~D & I;
	always @(posedge Clock) begin
		if (Front) Counter <= Periods - 1;
		else if (!Zero) Counter <= Counter - 1;
	end
	always @(posedge Clock) begin
		if (Zero) M <= Front;
	end

	assign Enable = ~(Front | {SWNum{(~Zero)}} & M);

end else begin
	supply1 vcc;
	assign Enable = {SWNum{vcc}};
end
endgenerate

always @(posedge Clock) begin
	integer i;
	for (i = 1; i <= 2*ArmNum; i = i +1)
  		if (Enable[i]) O[i] <= I[i];
end

endmodule