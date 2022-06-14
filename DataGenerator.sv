module DataGenerator (Clock, Button_Up, Button_Reset, Button_Down, Button_Sign, Data);
	parameter Size = 4,
		  Signed = "No",
		  ClockPeriod_ns = 20,
		  FilterPeriod_ns = 1_000_000,
		  PauseInterval_ns = 400_000_000,
		  RepeatsInterval_ns = 150_000_000,
		  NumberButtons = 4;

	input var bit Clock;
	input var logic Button_Up, Button_Reset, Button_Down, Button_Sign;
	output var logic [Size-1:0] Data; // edit

	var logic FilteredUp, FilteredReset, FilteredDown, FilteredSign,
				 Up, Down;
	
	Filter #(.Size(NumberButtons),
		 .ClockPeriod_ns(ClockPeriod_ns),
		 .FilterPeriod_ns(FilterPeriod_ns))
	F1 (.Clock,
	    .I({Button_Up,Button_Reset,Button_Down,Button_Sign}),
	    .O({FilteredUp, FilteredReset, FilteredDown, FilteredSign}));

	PulseGenerator #(.ClockPeriod_ns(ClockPeriod_ns),
						  .PauseInterval_ns(PauseInterval_ns),
						  .RepeatsInterval_ns(RepeatsInterval_ns))
	PG1 (.Clock,
	     .iUp(FilteredUp),
	     .iDown(FilteredDown),
	     .oUp(Up),
	     .oDown(Down));

	DataCounter #(.Size(Size), .Signed(Signed))
	DCnt1 (.Clock(Clock), .Up(Up), .Reset(FilteredReset), .Down(Down), .Sign(FilteredSign), .Data(Data));
endmodule: DataGenerator