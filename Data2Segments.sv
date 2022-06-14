module Data2Segments (Clock,Data,Indicators,Segments);
	parameter Size = 4,
		  Signed = "Yes",
		  ClockPeriod_ns = 20,
		  RefreshTime_ns = 20_000_000; // Frefresh = 50kHz
//		  ISize;
	
	localparam ISize = (Signed == "No") ? 
			    General::clog10(1<<Size) :
			   (General::clog10(1<<(Size-1)) + 1);
	
	input var bit Clock;
	input var logic [ Size-1:0] Data;
	output var bit [ISize-1:0] Indicators;
	output var bit [ 7:0] Segments;

	import General::Bin2BCD;
	import General::BCD2ESC;
	import General::clog2;

	localparam BCDSize = 4*ISize;
	var bit [4*ISize-1:0] BCD;

	generate
	begin: binary_to_BCD
		if (Signed == "No") begin
			always_comb begin
				BCD = (BCDSize)'(Bin2BCD(Data,BCDSize));
			end
		end else begin
			always_comb begin
				 BCD = {(Data[Size-1] == 1'b0) ? 
					 General::Empty :
					 General::Minus, 
					(BCDSize-4)'(Bin2BCD(Data[Size-2:0],
					 BCDSize-4))};
			end
		end
	end: binary_to_BCD

	begin: BCD_to_segments
		if (ISize > 1) begin: multiple_indicators
			localparam Prescale = RefreshTime_ns / ClockPeriod_ns / ISize,
				   ICounterSize = clog2(ISize); 
			var bit [ICounterSize-1:0] ICounter = 0;
			var bit Enable;

			SelectNPulse #(.N(Prescale)) S1 (.Clock, .Pulse(Enable));

			always_ff @(posedge Clock) begin: counter
				if (Enable) begin
					if (ICounter == ISize - 1) begin
						ICounter <= 0;
					end else begin
						ICounter <= ICounter + 1;
					end
				end
			end: counter

			always_comb begin: outputs
				Indicators = ~(1 << ICounter);
				Segments = BCD2ESC(BCD[4*ICounter +: 4]);
			end: outputs
		end: multiple_indicators
		else begin
			always_comb begin: single_indicator
				Indicators = 1'b0;
				Segments = BCD2ESC(BCD);
			end: single_indicator
		end
	end: BCD_to_segments
	endgenerate
endmodule: Data2Segments