// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed.
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

// Set the last keyboard input
@R0
M=-1

(KEYLOOP)

// Read the keyboard
@KBD
D=M
@R1
M=D

// Compare with the last value
@R0
D=M
@R1
D=D-M

@CHANGE
D;JNE // If (R1 != R0) goto CHANGE

@KEYLOOP
0;JMP  // Goto KEYLOOP

(CHANGE)
// Save the new values
@R1
D=M
@R0
M=D

// Fill the screen
@FILLSCREEN
0;JMP  // Goto FILLSCREEN

(FILLSCREENRETURN)
@KEYLOOP
0;JMP  // Goto KEYLOOP

(FILLSCREEN)

@8192
D=A
@R2
M=D

@SCREEN
D=A
@R3
M=D

(FILLWORD)

// Fill word

@R0
D=M
@BLACK
D;JNE // If (R0 != 0) goto BLACK

// White
@R3
A=M
M=0

@ENDFILL
0;JMP  // Goto ENDFILL

// Black
(BLACK)
@R3
A=M
M=-1

(ENDFILL)

// Move to the next word
@R3
D=M
@1
D=D+A
@R3
M=D

@R2
M=M-1

@R2
D=M

@FILLWORD
D;JGE // If (R2  0) goto FILLWORD

@FILLSCREENRETURN
0;JMP  // Goto FILLSCREENRETURN

@R0
D=M
@0
D=D-M
@BLACK
D;JNE // If (R1 != R0) goto CHANGE

// Fill word
@17
A=M
M=0

@ENDFILL
0;JMP  // Goto ENDFILL





// Move to the next line
@17
D=M
@2
D=D+A
@17
M=D

@16
MD=M-1
@10
D,JGT
