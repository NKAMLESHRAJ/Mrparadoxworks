//TRBG

//module test(output reg xor_out,input ch_ena,clk,reset);

module TRBG(
input ch_ena,clk,reset,
output reg [3:0]trng_out
); 
 
wire d,ts1_out,ts2_out,s;
wire b1,b2;
wire xor_out,out1;				
//wire a1,a2,a3,a4;
wire z;
					//chaos_circuit
chaos_circuit ch(.s(s),.ch_ena(ch_ena),.q(z));
					//ring_osc
ring1 r1(.ts1_out(ts1_out),.clk(clk),.s(s));
ring2 r2(.ts2_out(ts2_out),.clk(clk),.s(s));

xor(d,ts1_out,ts2_out);

					//phase detector
ph_det1 ph(.q(z),.d(d),.clk(clk),.reset(reset)); 
					//metastable introduced at latch
latch l1(.a1(b1),.a2(b2),.t1(ts1_out),.t2(ts2_out),.en(clk),.reset(reset));
xor (xor_out,b1,b2); 
//sipo sp(a1,a2,a3,a4,xor_out,clk,reset);
//nand (out1,xor_out,trng_out);
				//phase detector
lfsr l(.out(trng_out),.clk(clk),.reset(reset),.in(xor_out));
endmodule

//ring1
module ring1(
input clk,s,
output ts1_out
);
wire fg1,a1,a2,a3,a4,a5,a6,a7,t1_out;
assign a1=~(fg1 & clk); 
assign a2=~(s ^ clk ^ a1);
assign a3=~a2;
assign a4=~a3;
assign a5=~a4; 
assign t1_out=~a5;
assign a6=~t1_out;
assign a7=~a6;
assign ts1_out=~a7;
//mux1
assign fg1=s?ts1_out:t1_out;
endmodule

//ring2
module ring2(
input clk,s,
output ts2_out
);
wire fg2,a1,a2,a3,a4,a5,a6,a7,t2_out;

assign a1=~(fg2 & clk); 
assign a2=(s ^ a1);
assign a3=~a2;
assign a4=~a3;
assign a5=~a4; 
assign t2_out=~a5;
assign a6=~t2_out;
assign a7=~a6;
assign ts2_out=~a7;
assign fg2=s?ts2_out:t2_out;
endmodule

//phase detector-DFF

module ph_det1(
output reg q,
input clk,reset,
input d
);
always @(posedge clk,posedge reset)begin
if(reset)
q<=0;
else
q<=d;
end   

endmodule

//chaos circuit
module chaos_circuit(
input q,ch_ena,
output s
);
wire a4, a5;
assign a4=~ q;
assign a5=~ a4;
assign s=~(ch_ena & a5); 

endmodule

//latch-active high

module latch(
input t1,t2,en,reset,
output reg a1,a2
);

always @ (en) begin
if (reset)begin
 a1<=1'b0;
 a2<=1'b1;
end
else
begin
 a1<=~(t1 & a2);
 a2<=~(t2 & a1);
end
end

endmodule

//sipo-structural-stage 2

//module sipo(a[0],a[1],a[2],a[3],xor_out,clk,reset);
//input xor_out,clk,reset;
//output [3:0]a;
//reg [3:0]a;
//
//always @(posedge clk) 
//begin
// if(reset)
//   begin
//    a<=1'b0;
//   end 
// else
//   begin 
//    a[3]<=xor_out;
//    a[2]<=a[3];
//    a[1]<=a[2];
//   a[0]<=a[1];
//  end
//end
//endmodule 

//lfsr-stage 2
module lfsr (
output reg [3:0] out,
input clk, reset,in
);

assign in = ~((out[3] ^ out[2])&in);

always @(posedge clk, posedge reset)
begin
if (reset)
out <= 4'b0;
else
out <= {out[3:1],in}>>1;
end
endmodule

