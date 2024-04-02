/*****************************************/
/* Author  :  Ahmed Fawzy                */
/* Version :  V01                        */
/* Date    : 1 April  2024	 	         */
/*****************************************/

// the counter will counts to 60 which indicates to 60ns 
// the pulse width will stay for 10 counts which indicats 10 ns
// testpench clock period must be 1ns 

module WachTimer (
					input 	wire 	clk,rst,
					input  	wire 	i_CntEN,
					input  	wire 	[1:0] i_CntNUM,
					output 	reg 	o_cntPulse	
					);
					
reg 	[8:0] Counts;
reg 	[3:0] PCounts;
					
always @(posedge clk,negedge rst)
begin
	if(~rst) begin
		o_cntPulse	<= 0;
		Counts 		<= 9'b111111111;
		PCounts		<= 0;
	end
	else begin
		if(i_CntEN) begin
			if((i_CntNUM * 60) - 1 == Counts) begin
				if(PCounts != 10) begin
						o_cntPulse <= 1;
						PCounts	   <= PCounts + 1;
				end 
				else begin
						o_cntPulse <= 0	;
						PCounts	   <= 0;
						Counts 	   <= 0;
				end	
			end
			else begin
				Counts <= Counts + 1;	
			end
		end
	end

end					
					
endmodule
					
					


