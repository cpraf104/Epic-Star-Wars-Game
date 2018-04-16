; #########################################################################
;
;   lines.asm - Assembly file for EECS205 Assignment 2
;	Ethan Park
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA
;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  256 / PI   (use this to find the table entry for a given angle
	                        ;;              it is easier to use than divison would be)

	;; If you need to, you can place global variables here
	
.CODE
	

FixedSin PROC USES ebx esi edi edx ecx angle:FXPT

	mov ecx, angle
	mov esi, angle

	Checkangle:
	cmp ecx, 0
	jl Increaseangle
	cmp ecx, TWO_PI
	jge Reduceangle

	Rangecondition:
	cmp ecx, PI
	jg Twopiecase
	cmp ecx, PI_HALF
	jg Piecase

	Basecase:					;Basically the case where 0 < angle < PI/2
	mov eax, PI_INC_RECIP
	imul ecx
	mov ecx, edx
	mov eax, 2
	imul ecx
	mov ecx, eax
	movzx eax, [SINTAB + ecx]
	cmp esi, PI
	jge Negation
	jmp Exit

	Negation:
	not eax
	add eax, 1
	jmp Exit

	Nothing:
	mov eax, 0
	jmp Exit

	Twopiecase:					;Basically the case where angle > PI
	mov eax, PI
	sub ecx, eax
	cmp ecx, PI_HALF
	jge Piecase
	jmp Basecase

	Piecase:					;Basically the case where PI/2 < angle < PI
	mov eax, PI_INC_RECIP
	mov ebx, PI
	sub ebx, ecx
	imul ebx
	mov ebx, edx
	mov eax, 2
	imul ebx
	mov ebx, eax
	movzx eax, [SINTAB + ebx]
	cmp esi, PI
	jge Negation
	jmp Exit

	Reduceangle:
	mov eax, angle
	mov edx, 0
	mov ebx, TWO_PI
	div ebx
	mov ecx, edx
	mov esi, edx
	jmp Rangecondition

	Increaseangle:
	mov eax, TWO_PI
	add ecx, eax
	mov esi, eax
	jmp Checkangle


	Exit:
	ret      	;;  Don't delete this line...you need it	
FixedSin ENDP 
	
FixedCos PROC USES ecx ebx angle:FXPT

	mov ecx, angle
	mov ebx, PI_HALF
	add ecx, ebx
	invoke FixedSin, ecx
	
	ret        	;;  Don't delete this line...you need it		
FixedCos ENDP	

	
DrawLine PROC USES eax ebx ecx edx esi edi x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD

	LOCAL fixed_inc:FXPT, fixed_j:FXPT, j_val_temp:DWORD	 ; Creating two fixed point variables 
    mov ebx, 0   					 ; int i
    
compute_ydelta:
    mov ecx, y1			; ABS(y1 - y0)
    sub ecx, y0
    cmp ecx, 0
    jge compute_xdelta
    mov ecx, y0
    sub ecx, y1			; ECX --> (y1 - y0) or (y0 - y1)

compute_xdelta:		; ABS(x1 - x0)
    mov esi, x1
    sub esi, x0
    cmp esi, 0
    jge comparison
    mov esi, x0		; ESI --> (x1 - x0) or (x0 - x1)
    sub esi, x1

comparison:			; Checking condition of absolute values
    cmp ecx, esi
    jl ydeltaless	; ABS(y1 - y0) < ABS(x1 - x0)
    mov ecx, y0
    cmp ecx, y1
    jz finish
    jmp case_elseif	; (y1 != y0)
    
ydeltaless:			; ABS(y1 - y0) < ABS(x1 - x0)
    mov ecx, y1
    sub ecx, y0    ; Computing y1 - y0
    mov esi, x1
    sub esi, x0    ; Computing x1 - x0
    mov edx, ecx   ; Preparing numerator for the fixed point division (edx, eax)
    mov eax, 0
    shl esi, 16    ; Preparing denominator for the fixed point division
    idiv esi
    mov fixed_inc, eax    ; storing the result in the global variable
    
	;Else conditional for fixed_j assignment ~(x0 > x1)
	mov esi, x1       ; Computing x1 - x0
    sub esi, x0
    cmp esi, 0
    jge assignfixed_j ; If (x1 >=x0)

	;If (x0 > x1)
    mov esi, x0       ; Swapping x0 and x1
    mov edi, x1
    mov x0, edi
    mov x1, esi
    mov ecx, y1       ; Converting y1 from int to fixed
    shl ecx, 16
    mov fixed_j, ecx            
    jmp forloop

assignfixed_j:            ; fixed_j = INT_TO_FIXED(y0)
    mov ecx, y0
    shl ecx, 16
    mov fixed_j, ecx				

forloop: 
    mov ebx, x0

testcondition:
    cmp ebx, x1              ; Checks whether i = x1 has been reached or not
    jg finish			
    mov edi, fixed_j
    mov j_val_temp, edi
    shr j_val_temp, 16       ; Converting fixed_j's value from fixed to int
	cmp j_val_temp, 0
	jl Increment
	cmp j_val_temp, 479
	jg Increment
	cmp ebx, 0
	jl Increment
	cmp ebx, 639
	jg Increment
    mov eax, 640             ; Computing the index of array that we want
    imul j_val_temp          ; (640*fixed_j + i)
    add eax, ebx
    mov ecx, ScreenBitsPtr   ; Copying the pointer to ecx
    mov edi, color           ; Storing color value
    mov [ecx + eax],edi      ; Assigning color value to appropriate index in array
  
  Increment:
    mov esi, fixed_inc
    add fixed_j, esi		 ; fixed_j += fixed_inc      				
    add ebx, 1				 ; Incrementing i
    jmp testcondition

case_elseif: 
    mov ecx, x1
    sub ecx, x0    ; Computing x1 - x0
    mov esi, y1
    sub esi, y0    ; Computing y1 - y0
    mov edx, ecx   ; Preparing numerator for the fixed point division (edx, eax)
    mov eax, 0
    shl esi, 16    ; Preparing denominator for the fixed point division
    idiv esi
    mov fixed_inc, eax			
	
	;Else conditional for fixed_j assignment ~(y0 > y1)
    mov esi, y1    ; Computing y1 - y0
    sub esi, y0
    cmp esi, 0
    jge assignfixed_j2    ; if (y1 >= y0)

	;if (y0 > y1)
    mov esi, y0    ; Swapping y0 and y1
    mov edx, y1    
    mov y0, edx
    mov y1, esi
    mov ecx, x1    ; Converting x1 from int to fixed
    shl ecx, 16
    mov fixed_j, ecx				
    jmp forloop2

assignfixed_j2:            
    mov ecx, x0
    shl ecx, 16
    mov fixed_j, ecx    

forloop2: 
    mov ebx, y0

testcondition2:
    cmp ebx, y1				; Checking condition, i = y0 to y1
    jg finish
    mov esi, fixed_j        ; We store it in a different register as this time we need the original int val of j_val too
    shr esi, 16
    mov eax, 640	
	cmp ebx, 0
	jl increment
	cmp ebx, 479
	jg increment
	cmp esi, 0 
	jl increment
	cmp esi, 639
	jg increment		
    imul ebx				; (640 * i) [ebx = i]
    add eax, esi			; (640 * i + fixed_j)
    mov ecx, ScreenBitsPtr	; ScreenBitsPtr pointer
    mov edi, color
    mov [ecx+eax], edi		; Assign color value (edi) to the appropriate index in array
    
increment:
	mov esi, fixed_inc
    add fixed_j, esi		; fixed_j += fixed_inc
    add ebx, 1				; Incrementing i
    jmp testcondition2

finish:
	ret        	;;  Don't delete this line...you need it
DrawLine ENDP




END
