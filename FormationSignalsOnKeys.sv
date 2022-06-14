module FormationSignalsOnKeys (Clock, Synch, PWM, direction, signals);

input bit Clock;
input Synch;
input PWM;
input direction;
output logic [3:0] signals = 0;

always_ff @(posedge Clock) begin
		case ({ PWM, direction})
		//case ({ PWM, direction, Synch})
			/*
			2'b10 : signals = 4'b1001;
			2'b00 : signals = 4'b1010;
			2'b11 : signals = 4'b0110;
			2'b01 : signals = 4'b1010;
			*/
			
			//Политор
			2'b10 : signals = 4'b1001;
			2'b00 : signals = 4'b0101;
			2'b11 : signals = 4'b0110;
			2'b01 : signals = 4'b0100;
			
			/*
			//NulinaVova
			2'b10 : signals = 4'b1001;
			2'b00 : signals = 4'b0000;
			2'b11 : signals = 4'b0110;
			2'b01 : signals = 4'b0000;
			*/
			/*
			//DungeonMaster
			2'b10 : signals = 4'b1001;
			2'b00 : signals = 4'b1000;
			2'b11 : signals = 4'b0110;
			2'b01 : signals = 4'b0010;
			*/
			/*
			//Француз
			3'b000 : signals = 4'b1001;
			3'b100 : signals = 4'b0001;
			3'b001 : signals = 4'b1001;
			3'b101 : signals = 4'b1000;
			3'b010 : signals = 4'b0110;
			3'b110 : signals = 4'b0101;
			3'b011 : signals = 4'b0110;
			3'b111 : signals = 4'b1010;
			*/
			/*
			//Тосол
			3'b000 : signals = 4'b1001;
			3'b100 : signals = 4'b0101;
			3'b001 : signals = 4'b1001;
			3'b101 : signals = 4'b1010;
			3'b010 : signals = 4'b1001;
			3'b110 : signals = 4'b0000;
			3'b011 : signals = 4'b1001;
			3'b111 : signals = 4'b0000;
			*/
			
		endcase
end

endmodule