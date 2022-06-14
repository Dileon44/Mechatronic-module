module DataCounter (Clock, Up, Reset, Down, Sign, Data);
	parameter Size = 5, Signed = "No";

	input var bit Clock;
	input var logic Up, Reset, Down, Sign;
	output var logic [Size-1:0] Data = 0; // Binary
	
	var bit Synchronizing_signal = 1, Change_sign = 1;	
	
	always_ff @(posedge Clock) begin
		if ((Sign != Synchronizing_signal)) begin
			Synchronizing_signal <= Sign;
			Change_sign <= Sign;
		end else 
			Change_sign <= 1;
	end
	
	generate
	if (Signed == "No") begin

		always_ff @(posedge Clock) begin: unsigned_counter
			if (~Reset) begin Data <= 0; end
			else if (Up) begin
				if (Data < 2**Size - 1) Data <= Data + 1;
			end else if (Down) begin
				if (Data != 0) Data <= Data - 1;
			end
		end: unsigned_counter

	end else if (Signed == "Yes") begin // [-Max, ..., -1, 0, 1, ..., Max] Sign.Magnitude
		
		always_ff @(posedge Clock) begin: signed_counter			
			if (~Reset) begin 
			
				Data <= 0;
				
			end else if (Up) begin
			
				if ((Data >= 0) && (Data < 2**(Size-1)-1)) // [ 0..+2] 
					Data <= Data + 1;
				else if ((Data > 2**(Size-1)+1) && (Data < 2**Size)) // [-3..-2]
					Data <= Data - 1;
				else if (Data == 2**(Size-1)+1) // -1
					Data <= 0;
					
			end else if (Down) begin
				
				if ((Data > 0) && (Data < 2**(Size-1))) begin // [+1..+3]
					Data <= Data - 1;
				end else if ((Data > 2**(Size-1)) && (Data < 2**Size-1)) begin // [-1..-2]
					Data <= Data + 1;
				end else if (Data == 0) begin // 0
					Data <= 2**(Size - 1) + 1;
				end
				
			end else if (~Change_sign)  begin
				if ((Data[Size - 2:0] != 0))
					Data[Size - 1] <= ~Data[Size - 1];
			end
		end: signed_counter

	end else if (Signed == "Reverse") begin
	
		always_ff @(posedge Clock) begin: rev	
			if (~Reset) begin 
			
				Data <= 0;
				
			end else if (Up) begin
			
				if ((Data >= 0) && (Data < 2**(Size-1) - 1)) begin // [ 0..+2]
					Data <= Data + 1;
				end else if ( (Data >= 2**(Size - 1)) && (Data < 2**(Size) - 2) ) begin // [-3..-2]
				
					Data <= Data + 1;
				
				end else if (Data == 2**Size - 2) begin// [-1]
					Data <= Data + 2;
				end
					
			end else if (Down) begin
				
				if ( (Data > 0) && (Data <= 2**(Size-1)-1) 
				  || (Data > 2**(Size - 1)) && (Data <= 2**(Size) - 2) ) begin // [ 1..+3] || [-2..-1]
					Data <= Data - 1;
				end else if (Data == 0) begin// [0]
					Data <= Data - 2;
				end
				
			end else if (~Change_sign)  begin
			
				if ((Data[Size - 2:0] != 0))
					Data <= ~Data;
					
			end
		end: rev
	
	end else begin: add_code

		always_ff @(posedge Clock) begin: always_additional_code

			if (~Reset) begin 
			
				Data <= 0;
				
			end else if (Up) begin
			
				if (Data != 2**(Size - 1) - 1) begin
					Data <= Data + 1;
				end

			end else if (Down) begin
				
				if (Data != 2**(Size - 1)) begin
					Data <= Data - 1;
				end
				
			end else if (~Change_sign)  begin
			
				if (Data != 0 || Data != 2**(Size - 1)) begin
					Data <= (~Data) + 1;
				end

			end

		end: always_additional_code

	end: add_code
	
	endgenerate
	
endmodule: DataCounter