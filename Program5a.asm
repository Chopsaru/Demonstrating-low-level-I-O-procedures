TITLE Program 5a     (Program5a.asm)

; Author: Greg Noetzel	
; Last Modified: 7/29/19
; OSU email address: noetzelg@oregonstate.edu
; Course number/section: CS_271_400_U2019
; Assignment Number: 5a                Due Date: Aug 11th
; Description:	Implement custom ReadVal and WriteCal precedures for unsigned integers. procedures included: ReadVal, WriteVal. Macros: getString, displayString.
;				Program will prompt users for 10 valid inputs and store them in an array. It will then list the integers, their sum and the average value of the list

INCLUDE Irvine32.inc

; Macros


displayString	MACRO	stringIn
;macro that prints a passed in string
;recieves: string reference
;returns: nothing
;preconditions: none
;registeres changed: none

		push			edx

		mov				edx, stringIn
		call			writestring

		pop				edx
ENDM


getString		MACRO	promptIn, nstring
;macro that prompts user for a string and saves it to a passed in variable
;recieves: prompt reference, string variable
;returns: nothing	
;preconditions: 
;registeres changed: none

		push			ecx
		push			edx
				
		mov				edx, promptIn
		call			readstring

		mov				ecx, nstring

		pop				edx
		pop				ecx
ENDM


.data

		progtitle		BYTE	"Demonstrating low-level I/O procedures",0
		myname			BYTE	"Written by: Greg Noetzel",0
		instructions1	BYTE	"Please provide 10 decimal integers.",0
		instructions2	BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 0
		instructions3	BYTE	"After you have finished inputting the raw numbers I will display a list",0
		instructions4	BYTE	"of the integers, their sum, and their average value.",0
		numprompt		BYTE	"Please enter an integer: ",0
		invalidmsg		BYTE	"ERROR: You did not enter an integer number or your number was too big.",0
		tryagain		BYTE	"Please try again: ",0
		printheader		BYTE	"You entered the following numbers:",0
		summsg			BYTE	"The sum of these numbers is: ",0
		avgmsg			BYTE	"The average is: ",0
		byemsg			BYTE	"Thanks for playing!",0
		comma			BYTE	", ",0

		intarray		DWORD	10 DUP (?)
		sum				DWORD	?
		average			DWORD	?
		buff			BYTE	255 DUP(?)
		temp			BYTE	32 DUP(?)


.code

main PROC

		call			intro

		call			fillArray

		call			calcValues

		call			printValues

		call			goodbye

	exit
main ENDP


intro PROC
;procedure that prints introduction and instructions for program
;recieves: nothing
;returns: nothing
;preconditions: none
;registeres changed: none

		displayString	OFFSET progtitle
		call			crlf
		displayString	OFFSET myname
		call			crlf
		call			crlf
		displayString	OFFSET instructions1
		call			crlf
		displayString	OFFSET instructions2
		call			crlf
		displayString	OFFSET instructions3
		call			crlf
		displayString	OFFSET instructions4
		call			crlf
		call			crlf

		ret
intro ENDP


fillArray PROC
;procedure that fills prompts leverages the readVal macro to prompt user for ints to fill array and also fills
;recieves: nothing
;returns: nothing
;preconditions: array size 10 initialized
;registeres changed: none

		mov				ecx, 10							;set loop
		mov				edi, OFFSET intArray

	nextInt:
		displayString	OFFSET numprompt				;prompt reference
		call			crlf

		push			OFFSET buff						;variable buffer
		push			SIZEOF buff
		call			readVal

		mov				eax, DWORD PTR buff				;ctr-s
		mov				[edi], eax
		add				edi, 4

		loop			nextInt	

		ret
fillArray ENDP


calcValues PROC
;procedure that calculates sum and mean and also prints array elements in order
;recieves: nothing
;returns: nothing
;preconditions: array filled with 10 elements
;registeres changed: none

		displayString	OFFSET printheader				;display intarray while calc sum to not repeat code
		call			crlf

		mov				ebx, 0							;sum goes here
		mov				ecx, 10							;loop counter
		mov				esi, OFFSET intArray

	sumnext:
		mov				eax, [esi]
		add				ebx, eax						;add to total sum

		push			eax
		push			OFFSET temp
		call			writeVal

		cmp				ecx, 1							;is last in array
		je				nocomma
		mov				al, ','
		call			writechar
		mov				al, ' '
		call			writechar

	nocomma:
		add				esi, 4							;next int in array
		loop			sumnext

		call			crlf

		mov				sum, ebx

		mov				eax, sum
		mov				ebx, 10
		mov				edx, 0

		div				ebx								;average calc
		mov				average, eax

	ret
calcValues ENDP


printValues PROC
;procedure that prints values calculated in calcValues
;recieves: nothing
;returns: nothing
;preconditions: 
;registeres changed: none

		displayString	OFFSET summsg				;print sum
		push			sum
		push			OFFSET temp
		call			writeVal
		call			crlf

		displayString	OFFSET avgmsg				;print average 
		push			average
		push			OFFSET temp
		call			writeVal
		call			crlf
	ret
printValues ENDP


goodbye PROC
;procedure that says goodbye
;recieves: nothing
;returns: nothing
;preconditions: none
;registeres changed: none

		displayString	OFFSET byemsg
	ret
goodbye	ENDP


readVal PROC
;procedure that conternts user input string to ascii and stores as int
;recieves: 
;returns: nothing
;preconditions: 
;registeres changed: none

		push			ebp
		mov				ebp, esp
		pushad									;order: EAX, ECX, EDX, EBX, ESP

	start:
		mov				edx, [ebp + 12]			;buff address
		mov				ecx, [ebp + 8]			;buff size

		getString		edx, ecx				;get imput

		mov				esi, edx				;intitialize registers 
		mov				eax, 0
		mov				ecx, 0
		mov				ebx, 10

	loadsbyte:
		lodsb									;swap to 16 bit reg
		cmp				ax, 0					;check if there are any ascii left in string
		je				done

		cmp				ax, 48					;is below ascii 0?
		jb				invalid	
		cmp				ax, 57					;is above ascii 9?
		ja				invalid

		sub				ax, 48	
		xchg			eax, ecx
		mul				ebx						;check if otherwise valid
		jc				invalid
		jnc				valid

	invalid:									;start over if invalid
		displayString	OFFSET invalidmsg
		call			crlf
		displayString	OFFSET tryagain
		jmp				start

	valid:										;exchange for next loop
		add				eax, ecx
		xchg			eax, ecx
		jmp				loadsbyte

	done:
		xchg			eax, ecx
		mov				DWORD ptr buff, eax		;ctr s
		popad
		pop				ebp

	ret 8
readVal ENDP
	

writeVal PROC
;procedure that converts inty to printable statements
;recieves: int value, int address
;returns: nothing
;preconditions: value and referenced pushed onto stack before call
;registeres changed: none

		push			ebp
		mov				ebp, esp
		pushad									;order: EAX, ECX, EDX, EBX, ESP

		mov				eax, [ebp+12]			;int value
		mov				edi, [ebp+8]			;int val ref address
		mov				ebx, 10
		push			0

	convertnext:
		mov				edx, 0
		div				ebx
		add				edx, 48
		push			edx
		cmp				eax,0
		jne				convertnext

	popnext:
		pop				[edi]
		mov				eax, [edi]
		inc				edi
		cmp				eax,0
		jne				popnext

		mov				edx, [ebp+8]
		displaystring	OFFSET temp

		popad
		pop				ebp

	ret 8
writeVal ENDP

END main
