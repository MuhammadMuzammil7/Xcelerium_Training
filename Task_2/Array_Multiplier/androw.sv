// And Row:
module androw(pp, a, b);
	output logic [7:0] pp;
	input logic [7:0] a;
	input logic b;

and AND0(pp[0], a[0], b);
and AND1(pp[1], a[1], b);
and AND2(pp[2], a[2], b);
and AND3(pp[3], a[3], b);
and AND4(pp[4], a[4], b);
and AND5(pp[5], a[5], b);
and AND6(pp[6], a[6], b);
and AND7(pp[7], a[7], b);

endmodule