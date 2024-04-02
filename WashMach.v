/*****************************************/
/* Author  :  Ahmed Fawzy                */
/* Version :  V01                        */
/* Date    : 1 April  2024	 	         */
/*****************************************/



// This is the finite state machine module of the Waching machine
// The machine is start at the IDLE state and if the user put coins the cycle will start at next positive edge.
// the waching cycle start by the state SOAK and wait for 60 positive edges (60ns if the period 1ns) then the signal pulse output high for 10 positive edges (10ns if the period 1ns)
// if it finishes it moved to next state WASH and wait for 180 positive edges (180ns if the period 1ns) then the signal pulse output high for 10 positive edges (10ns if the period 1ns)
// if it finishes it moved to next state RINSE and wait for 60 positive edges (60ns if the period 1ns) then the signal pulse output high for 10 positive edges (10ns if the period 1ns)
// if it finishes it moved to next state SPIN and wait for 60 positive edges (60ns if the period 1ns) then the signal pulse output high for 10 positive edges (10ns if the period 1ns)
// If the lid is raised only during the spin cycle, the machine stops spinning until the lid is closed (that the counter stopped).
// There is a double wash switch, which if turned on, causes a second wash and rinse to occur after completing the first rinse.
// Assume that the double wash button is pressed before depositing the coins (if needed) and stays pressed till the job completes. 
module WachMach (
					input 	wire 	clk,rst,
					input   wire    i_coin,
					input 	wire 	i_Lid,
					input 	wire 	i_DoubleWash,
					input 	wire 	i_cntPulse,
					output  reg 	o_CntEN,
					output  reg 	[1:0] o_CntNUM,
					output 	reg 	Dn
				);
				
reg  [2:0] STATE, NEXT_STATE;
reg  [3:0] TimeCnts; // to counts the 10ns pulse width.
reg  r_DoubleCnt; // register to store the double wach button.
reg  w_DoubleCnt; // wire to assign the next state of the DoubleCnt (double wach register).

localparam 	IDLE = 3'b000, SOAK = 3'b001, WASH = 3'b010, RINSE = 3'b011, SPIN = 3'b100, FINISH = 3'b101;



always @(posedge clk,negedge rst) begin  
	if(!rst)
		STATE <= IDLE;
	else
		STATE <= NEXT_STATE;
end


always @(*)
begin
	w_DoubleCnt = r_DoubleCnt;
	case(STATE)
	IDLE :  begin
				if(i_coin) begin
					NEXT_STATE  = SOAK;
					o_CntEN		= 1;
					o_CntNUM	= 2'b01;
				end
				else begin
					NEXT_STATE  = IDLE;
					o_CntEN		= 0;
					o_CntNUM	= 2'b01;
				end
				w_DoubleCnt = i_DoubleWash;
			end
	SOAK :	begin
				o_CntEN		= 1;
				o_CntNUM	= 2'b01;
				if(i_cntPulse) begin
                    if(TimeCnts == 9) begin
						NEXT_STATE  = WASH;
					end
					else begin
						NEXT_STATE  = SOAK;
					end
				end
				else begin
					NEXT_STATE  = SOAK;				
				end
			end
	WASH : begin
				o_CntEN		= 1;
				o_CntNUM	= 2'b11;
				if(i_cntPulse) begin
                    if(TimeCnts == 9) begin
						NEXT_STATE  = RINSE;
					end
					else begin
						NEXT_STATE  = WASH ;
					end
				end
				else begin
					NEXT_STATE  = WASH;				
				end
			end	
	RINSE : begin
				if(i_Lid)
					o_CntEN		= 0;
				else
					o_CntEN		= 1;
				if(i_cntPulse) begin
                    if(TimeCnts == 9) begin
							if(r_DoubleCnt) begin
								NEXT_STATE  = WASH;
								o_CntNUM	= 2'b01;
								w_DoubleCnt = ~w_DoubleCnt; 
							end 
							else begin
								NEXT_STATE  = SPIN;
								o_CntNUM	= 2'b01;
							end
					end
					else begin
						NEXT_STATE  = RINSE;
						o_CntNUM	= 2'b01;
					end
				end
				else begin
                    o_CntNUM	= 2'b01;
					NEXT_STATE  = RINSE;				
				end
			end		
	SPIN : begin
				o_CntEN		= 1;
                o_CntNUM	= 2'b01;
				if(i_cntPulse) begin
                    if(TimeCnts == 9) begin
						NEXT_STATE  = FINISH;
					end
					else begin
						NEXT_STATE  = SPIN;
					end
				end
				else begin
					NEXT_STATE  = SPIN;				
				end
			end			
	FINISH : begin
				o_CntEN		= 0;
                o_CntNUM	= 2'b00;
				NEXT_STATE  = IDLE;				
			end	
	default: begin
					o_CntEN		= 0;
					o_CntNUM	= 2'b00;
	                NEXT_STATE  = IDLE;	
					w_DoubleCnt = 0;
			end
	endcase

end
always @(*)
begin
	case(STATE)
		IDLE  :  Dn = 0;
		SOAK  :  Dn = 0;
		WASH  :  Dn = 0;
		RINSE :  Dn = 0;
		SPIN  :  Dn = 0;
		FINISH:  Dn = 1;
		default: Dn = 0;
	endcase


end


// counter the pulse width
always @(posedge clk,negedge rst) begin  
	if(!rst) begin
		TimeCnts	 	<= 0;
		r_DoubleCnt 	<= i_DoubleWash;
	end
	else begin
		r_DoubleCnt 	<= w_DoubleCnt;
		if(i_cntPulse)
			TimeCnts <= TimeCnts + 1 ;
		else 
			TimeCnts <= 0;
	end
end

endmodule