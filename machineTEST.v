/*****************************************/
/* Author  :  Ahmed Fawzy                */
/* Version :  V01                        */
/* Date    : 1 April  2024	 	         */
/*****************************************/

// The test work on period 1 ns until observation the output well

`timescale 1ns / 100ps

module machineTEST;




////////////////////////////////////////////////////////
/////////////////// DUT Signals //////////////////////// 
////////////////////////////////////////////////////////

reg        CLK_tb      		;
reg        RST_tb       	;
reg        I_COIN_tb  		;
reg        I_LID_tb  		;
reg        I_DOUBLEWASH_tb  ;
wire       DN_tb      		;

 
////////////////////////////////////////////////////////
////////////////// initial block /////////////////////// 
////////////////////////////////////////////////////////

initial 
 begin
   
 // Save Waveform
   $dumpfile("DOOR_CONTROLLER.vcd") ;       
   $dumpvars; 
 

 // initialization
   initialize();

 // Reset
   reset();

 // Put the coins
   start(); 
 
 //wait for the one washing cycle without double or lid
	wait(DN_tb);
	$display("the cycle happened in time : %t", $time);
	#1

 // Start another washing cycle 
   start(); 
 	
	
 // Check what happen if the lid is rised in SOAK cycle
   #30;
   LidOn();	
 // Check what happen if the lid is rised in WASH cycle
   #70;
   LidOn();	
 // Check what happen if the lid is rised in RINSE cycle
   #190;
   LidOn();	
 // Check what happen if the lid is rised in SPIN cycle
   #70;
   LidOn();
 //wait for the one washing cycle without double or lid
	wait(DN_tb);
	$display("the second cycle happened in time : %t", $time);
	#1
	
// Turn on the double waching button 
   I_DOUBLEWASH_tb 	= 1'b1	   ; 
// Start another washing cycle 
   start(); 
 //wait for the one washing cycle with lid and without double 
	wait(DN_tb);
	$display("the second cycle happened in time : %t", $time);
	#1
 
// Turn on the double waching button 
   I_DOUBLEWASH_tb 	= 1'b1	   ; 
 // Start another washing cycle 
   start(); 
 	
	
 // Check what happen if the lid is rised in SOAK cycle
   #30;
   LidOn();	
 // Check what happen if the lid is rised in first WASH cycle
   #70;
   LidOn();	
 // Check what happen if the lid is rised in first RINSE cycle
   #190;
   LidOn();	
 // Check what happen if the lid is rised in second WASH cycle
   #70;
   LidOn();	
 // Check what happen if the lid is rised in second RINSE cycle
   #190;
   LidOn();	
 // Check what happen if the lid is rised in SPIN cycle
   #70;
   LidOn();
 //wait for the one washing cycle without double or lid
	wait(DN_tb);
	$display("the third cycle happened in time : %t", $time); 

   #70
   $finish ;
 
 end  


////////////////////////////////////////////////////////
/////////////////////// TASKS //////////////////////////
////////////////////////////////////////////////////////

/////////////// Signals Initialization //////////////////

task initialize;
 begin
  I_COIN_tb  		= 1'b0	   ;
  CLK_tb     		= 1'b0	   ;
  I_LID_tb	 		= 1'b0     ;
  RST_tb 	 		= 1'b1	   ;
  I_DOUBLEWASH_tb 	= 1'b0	   ;
 end
endtask

///////////////////////// RESET /////////////////////////
  
task reset;
 begin
 RST_tb =  1'b1;
 #0.2
 RST_tb  = 1'b0;
 #0.8
 RST_tb  = 1'b1;
 end
endtask  

////////////////////// Insert Coins /////////////////////
  
task start;
  
begin
 I_COIN_tb = 1'b1 ; 		// behaviour as a push button pressed for one second then released. 
 #1
 I_COIN_tb = 1'b0 ;                   
end

endtask  

/////////////////////// Lid is rised ///////////////////////
  
task LidOn();

begin                  
I_LID_tb = 1'b1 ;
#10  
I_LID_tb = 1'b0 ;
end

endtask  

 
////////////////////////////////////////////////////////
////////////////// Clock Generator  ////////////////////
////////////////////////////////////////////////////////

always #0.5  CLK_tb = !CLK_tb ;   // period = 1 ns (1 GHz)
  
////////////////////////////////////////////////////////
/////////////////// DUT Instantation ///////////////////
////////////////////////////////////////////////////////


TopMach DUT(
.CLK(CLK_tb),
.RST(RST_tb),
.I_COIN(I_COIN_tb),
.I_LID(I_LID_tb),
.I_DOUBLEWASH(I_DOUBLEWASH_tb),
.DN(DN_tb)
				);
 
endmodule


