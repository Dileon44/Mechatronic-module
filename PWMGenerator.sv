module PWMGenerator (Clock, Data, PWM, Synch, Sign);
parameter ClockPeriod_ns = 20,
PWMPeriod_ns = 200_000, 
PWMType = "Front", 
Size = 4,
TypeData = "Sign";

input bit Clock;
input logic [Size-1:0] Data;
output logic PWM = 0, Synch = 0, Sign = 0;

// Internal parameters and nets
localparam
k1 = (PWMType == "Centered") ? 2 : 1,
Max = (TypeData == "Sign") ? 2**(Size - 1) - 2 : 2**Size - 2,
Prescaler = PWMPeriod_ns/ClockPeriod_ns/(Max+1)/k1,

 
//Prescaler = 1_000_000, ////////////////////////////////// !!!!!!!!!!!!!!!!!


Number = (TypeData == "Sign") ? Size - 2 : Size - 1;

var logic Enable, EndOfPeriod;
var logic [Number:0] LoadedData = 0;
var logic [Number:0] Counter = 0;

// Prescaler (n-th clock period selector)
generate
	if (Prescaler > 1)
		SelectNPulse #(.N(Prescaler))
		S1 (.Clock,.Pulse(Enable));
	else
		always_comb Enable = 1;
endgenerate

generate
	if (TypeData == "Sign") begin
		always_ff @(posedge Clock) begin
			if (Enable && EndOfPeriod) begin 
				LoadedData <= Data[Number : 0];
				Sign <= Data[Size - 1];
			end
		end
	end else begin 
		always_ff @(posedge Clock) begin
			if (Enable && EndOfPeriod) begin
				LoadedData <= Data;
			end
		end
	end
endgenerate

// Compare block
always_ff @(posedge Clock) 
if (Enable) PWM = (LoadedData > Counter);

// Counter
generate
	if (PWMType == "Front") begin: summative_counter
	
		always_comb EndOfPeriod = (Counter == Max); 
		
		always_ff @(posedge Clock)
			if (Enable) if (EndOfPeriod) Counter <= 0;
			else Counter <= Counter + 1;
			
		always_ff @(posedge Clock)
			if (Enable)
				if ((LoadedData > 0) && (Counter == 0)) Synch <= ~Synch;
		
	end: summative_counter
	
	else if (PWMType == "Back") begin: subtractive_counter
	
		always_comb EndOfPeriod = (Counter == 0); 
		
		always_ff @(posedge Clock)
			if (Enable) if (EndOfPeriod) Counter <= Max;
			else Counter <= Counter - 1;
		
		always_ff @(posedge Clock)
			if (Enable)
				if ((LoadedData > 0) && (Counter == Max)) Synch <= ~Synch;
	
	end: subtractive_counter
	
	else if (PWMType == "Centered") begin: reversed_counter
	
		var logic Direction = 0;
		always_comb
			EndOfPeriod = ~Direction && Counter == Max || Direction && Counter == 0;
	
		always_ff @(posedge Clock) 
			if (Enable)
				if (EndOfPeriod) Direction <= ~Direction;
				else if (!Direction) Counter <= Counter + 1;
				else Counter <= Counter - 1;
	
		always_ff @(posedge Clock) 
			if (Enable) 
				if ((LoadedData > 0) && (~Direction && Counter == 0))
					Synch <= ~Synch;
				
	end: reversed_counter
	
endgenerate

endmodule: PWMGenerator