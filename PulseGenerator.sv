module PulseGenerator (Clock,iUp,iDown,oUp,oDown);
	parameter ClockPeriod_ns = 20,
		  PauseInterval_ns = 250_000_000, // 250 ms
		  RepeatsInterval_ns = 150_000_000; // 150 ms

	input var bit Clock;
	input var logic iUp, iDown;
	output var logic oUp = 1, oDown = 1;

	localparam
	MaxPause = PauseInterval_ns / ClockPeriod_ns,
	MaxRepeats = RepeatsInterval_ns / ClockPeriod_ns,
	MaxInterval = (MaxPause > MaxRepeats) ? MaxPause : MaxRepeats,
	Size = $clog2(MaxInterval);

	var logic [Size-1:0] Counter = 0;
	var logic Pulse = 0;
	var logic Pressed;
	enum logic [1:0] {Idle, Pause, Repeats} State = Idle;

	assign Pressed = ~(iUp & iDown);

	always_comb begin: outputs
		oUp = Pulse & ~iUp;
		oDown = Pulse & ~iDown;
	end: outputs

	always_ff @(posedge Clock) begin: state_machine
		if (Pressed) begin //
			case (State)
				Idle: begin
					State <= Pause; 
					Pulse <= 1; 
				end
				Pause: begin //
					if (Counter == MaxPause) begin
						State <= Repeats;
						Pulse <= 1;
						Counter <= 0;
					end else begin
						Pulse <= 0; 
						Counter <= Counter + 1;
					end
				end //
				Repeats: begin //
					if (Counter == MaxRepeats) begin
						Pulse <= 1;
						Counter <= 0;
					end else begin
						Pulse <= 0;
						Counter <= Counter + 1;
					end
				end
			endcase
		end/**/ else begin: reset
			State <= Idle;
			Counter <= 0;
		end: reset
	end: state_machine
endmodule: PulseGenerator
