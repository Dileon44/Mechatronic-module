//`include "SelectNPulse.sv"
//`include "SelectNPulse.sv"

module Filter (Clock, I, O);
	parameter Size = 4, 
		  ClockPeriod_ns = 20,
		  FilterPeriod_ns = 500_000;
	input var bit Clock;
	input var logic [Size-1:0] I;
	output var logic [Size-1:0] O = '1;

	localparam Number = 4, 
	Prescale = FilterPeriod_ns / ClockPeriod_ns / (Number-1);
	var logic Enable;
	var logic [Size-1:0][Number-1:0] Register = '1;

	generate
	if (Prescale > 1) 
		SelectNPulse #(.N(Prescale)) S1 (.Clock, .Pulse(Enable));
	else
		assign Enable = 1;
	endgenerate

	always_ff @(posedge Clock) begin: shift_registers
	if (Enable)
		for (int i = 0; i < Size; i++)
			Register[i] <= {Register[i][Number-2:0], I[i]};
	end: shift_registers

	always_ff @(posedge Clock) begin: outputs
	if (Enable)
		for (int i = 0; i < Size; i++) begin
			if ((Register[i] == '0 && O[i] == 1'b1) || 
			    (Register[i] == '1 && O[i] == 1'b0)) begin
				O[i] <= ~O[i];
			end
		end
	end: outputs
endmodule: Filter