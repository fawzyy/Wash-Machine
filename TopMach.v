/*****************************************/
/* Author  :  Ahmed Fawzy                */
/* Version :  V01                        */
/* Date    : 1 April  2024	 	         */
/*****************************************/

module TopMach (
					input 	wire  	CLK,RST,
					input  	wire 	I_COIN,
					input  	wire 	I_LID,
					input  	wire 	I_DOUBLEWASH,
					output  wire 	DN
				);
				
wire 	CNTPULSE, CNTEN;
wire    [1:0] CNTNUM; 

WachMach 	U0	(
					.clk(CLK),.rst(RST),
					.i_coin(I_COIN),
					.i_Lid(I_LID),
					.i_DoubleWash(I_DOUBLEWASH),
					.i_cntPulse(CNTPULSE),
					.o_CntEN(CNTEN),
					.o_CntNUM(CNTNUM),
					.Dn(DN)
				);
WachTimer 	U1	(
					.clk(CLK),.rst(RST),
					.i_CntEN(CNTEN),
					.i_CntNUM(CNTNUM),
					.o_cntPulse(CNTPULSE)	
					);



endmodule