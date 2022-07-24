1.How you organize the testbench in Part 2, Part 3 and Part4. 
(1)Part 2
First, declare all the variables and nets, then connect two RTL circuits(lut16 and smart) to this testbench. Second, generate clock signal by a infinite loop. Third, use a 4 nested for-loop(Mode, P, S, D)to generate all possible input pattern for input data preparation part. Since the 15 Modes in this part were given and not consecutive, I use a [8*15-1:0] parameter array to store the 15 modes and read it by the outermost loop. The last, also use a 4 nested for-loop and compare the answer between two RTL circuits for output data comparison part.
(2)Part 3
First, declare all the variables and nets, then connect two RTL circuits(lut256 and smart) to this testbench. Second, generate clock signal by a infinite loop. Third, use a 4 nested for-loop(Mode, P, S, D)to generate all possible input pattern for input data preparation part. The last, also use a 4 nested for-loop (otherwise, overflow occurred if single loop in this case) and compare the answer between two RTL circuits for output data comparison part.
(3)Part 4
First, since we want to run just certain mode, use two substitution macros to define the lower and upper bound. Second, declare all the variables and nets, then connect two RTL circuits(lut256 and smart) to this testbench. Third, generate clock signal by a infinite loop. The last, since we want to make the code more readable, move the input data preparation and output data comparison part in Part 3 into two tasks in rop3.task.

2.How you find out all the 256 functions.
From the table in the PDF, we can observe that the "Result" of this particular PSD pattern is equal to the "Mode". On the other hand, this particular PSD pattern and the "Result" may form a truth table. For example, as P=8'b11110000, S=8'b11001100, D=8'b10101010, Mode=8'b00010001, the Result is 8'b00010001. We may obtain a truth table as following.
P     |1 1 1 1 0 0 0 0 
S     |1 1 0 0 1 1 0 0
D     |1 0 1 0 1 0 1 0
-----------------------
Result|0 0 0 1 0 0 0 1
Thus, we can know that Boolean function of Mode=8'b00010001 is (P&(~S)&(~D))|((~P)&(~S)&(~D)). By this method, we can easily figure out 256 Boolean functions for ROP3.

3.Corresponding commands for mode=0-63, 64-127 and 128-255 in test_rop3.v (Part4).
$ncverilog test_rop3.v rop3_lut256.v rop3_smart.v +define+MODE_L=0+MODE_U=63
$ncverilog test_rop3.v rop3_lut256.v rop3_smart.v +define+MODE_L=64+MODE_U=127
$ncverilog test_rop3.v rop3_lut256.v rop3_smart.v +define+MODE_L=128+MODE_U=255
