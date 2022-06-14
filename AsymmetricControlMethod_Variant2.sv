module AsymmetricControlMethod_Variant2 (
	Clock,
	Button_Up,
	Button_Reset,
	Button_Down,
	Button_Sign,
	Synch, 
	PWM, 
	Sign, 
	signals_on_keys_with_pause,
	Indicators, //
	Segments    //
	);

parameter ClockPeriod_ns = 20;
parameter Signed = "Yes"; // type data (Direct or Reverse or Additional codes with sign or without sign)
parameter PWMPeriod_ns = 200_000,//200_000,
			 PWMType = "Front",
			 TypeData = "Sign", // type data in PWM generator: with sign or without sign
			 Size = 10,
			 TPause_ns = 10,
			 Periods = TPause_ns * 50;//PWMPeriod_ns / 20;
parameter FilterPeriod_ns = 1_000_000,
			 PauseInterval_ns = 450_000_000,
			 RepeatsInterval_ns = 10_000_000;
			 
parameter ArmNum = 2;

parameter RefreshTime_ns = 20_000_000,
			 ISize = (Signed == "No") 
						? General::clog10(1<<Size) 
						: (General::clog10(1<<(Size-1)) + 1);

input bit Clock;
input logic Button_Up, Button_Reset, Button_Down, Button_Sign;
output logic Synch, PWM, Sign;
output logic [3:0] signals_on_keys_with_pause;
output var bit [ISize-1:0] Indicators;
output var bit [ 7:0] Segments;

logic [Size-1:0] Data;
logic [3:0] signals;

DataGenerator #(.Size(Size), .Signed(Signed), .ClockPeriod_ns(ClockPeriod_ns), .FilterPeriod_ns(FilterPeriod_ns),
		.PauseInterval_ns(PauseInterval_ns), .RepeatsInterval_ns(RepeatsInterval_ns), .NumberButtons(4))
B1 (.Clock, .Button_Up, .Button_Reset, .Button_Down, .Button_Sign, .Data);
 
PWMGenerator #(.Size(Size), .TypeData("Sign"), .ClockPeriod_ns(ClockPeriod_ns), .PWMPeriod_ns(PWMPeriod_ns), .PWMType(PWMType))
B2 (.Clock, .Data, .Synch, .PWM, .Sign);

FormationSignalsOnKeys B3 (.Clock, .Synch(Synch), .PWM(PWM), .direction(Sign), .signals(signals));

FormationPause #(.ArmNum(ArmNum), .Periods(Periods))
B4 (.Clock(Clock), .I(signals), .O(signals_on_keys_with_pause));

Data2Segments #(.Size(Size), .Signed(Signed), .ClockPeriod_ns(ClockPeriod_ns), .RefreshTime_ns(RefreshTime_ns))
B5 (.Clock, .Data, .Indicators, .Segments);

endmodule 