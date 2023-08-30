dana: DB "dana0" ;saved strings, saved in stack segment
franta: DB "franta0" ;strings separated by ASCII num zero
ben: DB "ben0"
emil: DB "emil0"
ann: DB "ann0"
; actual entry point of the program, must be present
start:
MOV BX, 0x0000
MOV CL, 0x00
MOV DX, 0x0000
MOV BP, OFFSET dana ;first string on top of stack
Loop_All:
INC CL ;sum length of strings
INC BP ;move to higher char
CMP byte SS[BP], 0x00 ;find zero - find end of strings array
JNZ Loop_All
MOV byte SS[BP], CL
MOV AX, BP
MOV CL, 0x00
MOV BP, OFFSET dana
TN_Loop:
MOV CL, 0x00
Loop_Names:
INC CL ;count length of string
INC BP ;move to higher char
CMP byte SS[BP], 0x30 ;finding ASCII num zero - end of string
JNZ Loop_Names
MOV BP, AX
INC BX
ADD BP, BX
MOV byte SS[BP], CL
INC DX
ADD DX, CX
MOV BP, AX
CMP byte SS[BP], DL
JZ Free_space
MOV BP, OFFSET dana
ADD BP, DX
JNZ TN_Loop ;created information table - chars sum of array and length of particular strings
;table mov
Free_space: ;moving table and creating of new space - like extra space for sorting array
MOV SI, AX ;new space is length of the longest string
MOV BP, SI ;using data segment pointer like working register - pointer
MOV CH, 0x00 ;SI pointer - now point to start of information table about strings
INC BP
MOV CL, byte SS[BP] 
Length_space:
CMP CH, byte SS[BP]
JZ New_space_begin
INC BP
CMP CL, byte SS[BP]
JNS Length_space
MOV CL, byte SS[BP]
JMP Length_space
New_space_begin:
MOV BP, SI
New_space:
SUB BP, SI
DEC BP
CMP BP, BX
JZ String_weight ;string weight - array sorted by first char value of string
INC BP
ADD BP, SI
MOV DH, byte SS[BP]
ADD BP, BX
ADD BP, 0x0002
MOV byte SS[BP], DH
INC BP
SUB BP, BX ;BX - count of strings presented in array
SUB BP, 0x0002
JMP New_space
;table mov
;string weight
String_weight: ;string weight - ASCII value of first char of string
MOV BP, 0x0000
MOV DI, 0x0000 ;extra segment pointer will point to start of free space for sorting
MOV AH, 0x00
ADD SI, BX
ADD SI, 0x0002
Weight_top:
MOV CL, 0x00
MOV AH, 0x00
Weight_count:
INC CL
MOV AL, byte SS[BP]
CMP CL, 0x02
JZ Weight_end
SUB AL, 0x60 ;sub 60 hexa from ASCII because we are interested only in letters
ADD AH, AL ;we add to count of weight of string only index of letter in alphabet
INC BP ;next char of string
JMP Weight_count
Weight_end:
MOV BP, SI
ADD BP, BX
Find_Zero:
MOV AL, byte SS[BP]
INC BP
CMP AL, 0x00 ;find end of string array
JNZ Find_Zero
DEC BP
MOV byte SS[BP], AH
SUB BP, BX
MOV CL, byte SS[BP]
ADD DI, CX ;counting - finding start of free space for sorting array
INC DI
MOV BP, SI
MOV CL, byte SS[BP]
CMP CX, DI
JZ Sorting_top
MOV BP, 0x0000
ADD BP, DI
JMP Weight_top
;string weight
;sorting
Sorting_top:
MOV BP, SI ;pointing to start of information table
ADD BP, BX ;move to weight section of table
INC BP ;move to weight section of table
MOV DH, 0xFF ;final ending of information table - so we have sum length of strings, length of particular strings and alphabet value of partical strings
ADD BP, BX
MOV byte SS[BP], DH
SUB BP, BX
MOV AL, byte SS[BP]
;sorting top loop
Sorting_top_loop:
MOV BP, SI
ADD BP, BX
MOV DH, 0xFF
;sorting top loop
Compare_highest: ;find highest value of string weight
INC BP
CMP DH, byte SS[BP] ;end loop by end of table
JZ Sort_info
CMP AL, byte SS[BP] ;if higher weight of string then override
JNS Compare_highest
MOV AL, byte SS[BP] ;override current highest value
JMP Compare_highest
Sort_info:
SUB BP, BX
MOV CL, 0x00
MOV DH, 0x00
DEC BP
Sort_info_loop:
INC BP
;bypass null value
MOV AH, byte SS[BP]
CMP AH, 0x00 ;ignore zero - ignore already sorted string of array
JZ Sort_info_loop
;bypass null value
CMP AL, byte SS[BP]
JZ Sort_info_end
SUB BP, BX
MOV CH, byte SS[BP]
MOV DL, CH
ADD CL, CH
INC CL
ADD BP, BX
JMP Sort_info_loop
Sort_info_end:
SUB BP, BX
MOV DH, byte SS[BP]
MOV CH, 0x00
MOV DL, 0x00
;null highest
MOV BP, SI
ADD BP, BX
Null_high:
INC BP
MOV AH, byte SS[BP]
CMP AH, 0xFF ;find end of information table
JZ Temp_store
CMP AH, AL
JNZ Null_high
MOV AH, 0x00
MOV byte SS[BP], AH ;set zero sorted weight value of now sorted string
;null highest
;new offset
ADD CX, SP ;CX - pointing to start of new the most weighted string
;new offset
Temp_store: ;move now sorted string to free temporary space
MOV BP, CX
ADD BP, DX
AND BP, 0x00FF
MOV AH, byte SS[BP]
MOV BP, DI
ADD BP, DX
AND BP, 0x00FF
MOV byte SS[BP], AH
INC DL
CMP DH, DL
JNZ Temp_store
AND DX, 0x00FF
MOV BP, CX
DEC BP
Create_space: ;replacing part of array - shifting part of array to space of the highest string, highest string has new space now
MOV AH, byte SS[BP]
ADD BP, DX
INC BP
MOV byte SS[BP], AH
SUB BP, DX
DEC BP
DEC BP ;minus one
CMP BP, SP
JNS Create_space
MOV DH, DL
AND DX, 0xFF00
New_store:
MOV BP, DI
ADD BP, DX
AND BP, 0x00FF
MOV AH, byte SS[BP]
MOV BP, SP
ADD BP, DX
AND BP, 0x00FF
MOV byte SS[BP], AH
INC DL
CMP DH, DL
JNZ New_store ;store highest string from temp space to end of array, created space by shifting of array
MOV BP, SP
ADD BP, DX
AND BP, 0x00FF
MOV AH, 0x30 ;add ending to sorted string - ASCII zero
MOV byte SS[BP], AH
ADD SP, DX ;move to unsorted part of array, ingoring sorted part
AND SP, 0x00FF
INC SP
;sorting loop
CMP SP, DI ;signaling end of array - so we have sorted entire array
JNZ Sorting_top
;sorting loop
;sorting
;output
Print_out: ;print strings by BIOS servise using software interrupt
MOV AH, 0x13 ;write string functionality
MOV BP, DI
DEC BP
Print_result:
MOV CX, 0x0000
Print_setting:
INC CX ;length of particular string
DEC BP
CMP BP, 0x0000
JZ Print_end
MOV AL, byte SS[BP]
CMP AL, 0x30
JNZ Print_setting
INC BP
DEC CX
int 0x10 ;10 hexa - Video BIOS Services
DEC BP
JMP Print_result
Print_end:
int 0x10
;output
end: