// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)

// Zero the sum
@R2
M=0

// Set the counter
@R3
M=1

(LOOP)
@R3
D=M

@R0
D=D-M
@END
D;JGT // If (R3-R0) > 0 goto END

@R1
D=M // D = R1
@R2
M=D+M // R2 = R2 + R1

@R3  // R3 = R3 + 1
M=M+1

@LOOP
0;JMP  // Goto LOOP

// End of program
(END)
  @END
  0;JMP // Infinite loop
