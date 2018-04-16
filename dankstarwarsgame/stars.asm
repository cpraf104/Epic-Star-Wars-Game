; #########################################################################
;
;   stars.asm - Assembly file for EECS205 Assignment 1
;	
;	Ethan Park
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive


include stars.inc

.DATA

	;; If you need to, you can place global variables here
	
.CODE

DrawStarField proc

	;; Place your code here

	invoke DrawStar, 268, 74
	invoke DrawStar, 369, 340
	invoke DrawStar, 215, 193
	invoke DrawStar, 84, 342
	invoke DrawStar, 595, 83
	invoke DrawStar, 201, 431
	invoke DrawStar, 492, 178
	invoke DrawStar, 526, 43
	invoke DrawStar, 212, 150
	invoke DrawStar, 336, 353
	invoke DrawStar, 289, 316
	invoke DrawStar, 153, 188
	invoke DrawStar, 356, 450
	invoke DrawStar, 575, 228
	invoke DrawStar, 125, 391
	invoke DrawStar, 480, 127

	ret  			; Careful! Don't remove this line
DrawStarField endp


AXP	proc a:FXPT, x:FXPT, p:FXPT

	;; Place your code here

	mov eax,a
	mov ecx,x
	imul ecx
	shr eax,16
	shl edx,16
	mov ebx,p
	add eax,ebx
	add eax,edx
	;mov eax,ecx

	;; Remember that the return value should be copied in to EAX
	
	ret 			; Careful! Don't remove this line	
AXP	endp

	

END
