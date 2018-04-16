; #########################################################################
;
;   blit.asm - Assembly file for EECS205 Assignment 3
;	
;	Ethan Park
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include blit.inc

.DATA

	;; If you need to, you can place global variables here
	

.CODE


BasicBlit PROC USES eax ebx ecx edx edi esi ptrBitmap:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD
	
	LOCAL halfx:DWORD, halfy:DWORD, w:DWORD, h:DWORD, left:DWORD, right:DWORD, top:DWORD, bottom:DWORD, xcount:DWORD, ycount:DWORD, tcolor:BYTE, indexbit:DWORD, indexscreen:DWORD, coordx:DWORD, coordy:DWORD

	mov esi, ptrBitmap
	mov eax, [esi]
	mov w, eax
	mov ecx, 2
	mov edx, 0
	idiv ecx
	mov halfx, eax
	mov eax, [esi + 4]
	mov h, eax
	mov edx, 0
	idiv ecx
	mov halfy, eax
	
	mov eax, xcenter
	sub eax, halfx
	mov left, eax
	mov eax, xcenter
	add eax, halfx
	mov right, eax

	mov eax, ycenter
	sub eax, halfy
	mov top, eax
	mov eax, ycenter
	add eax, halfy
	mov bottom, eax

	mov al, [esi + 8]
	mov tcolor, al

	mov eax, 640
	mov ecx, top
	imul ecx
	add eax, left
	mov indexscreen, eax

	mov eax, left
	mov coordx, eax
	mov eax, top
	mov coordy, eax

	;;;;;Nested for loops to draw bitmap line by line;;;;;

	mov eax, h
	mov ycount, eax
	mov eax, [esi + 12]
	mov indexbit, eax		;initializing for the nested for loops

	COND1:					;first for loop conditional for rows
	cmp ycount, 0
	jle EXIT
	mov eax, w
	mov xcount, eax

	COND2:					;second for loop conditional for columns
	cmp xcount, 0
	jle INCREMENT
	mov ebx, indexbit
	mov al, [ebx]
	cmp al, tcolor
	je SKIP
	cmp coordy, 0
	jl SKIP
	cmp coordy, 479
	jg SKIP
	cmp coordx, 0
	jl SKIP
	cmp coordx, 639
	jg SKIP

	COPYCOLOR:
	mov ebx, ScreenBitsPtr
	add ebx, indexscreen
	mov [ebx], al

	SKIP:
	dec xcount
	inc indexbit
	inc indexscreen
	inc coordx
	jmp COND2

	INCREMENT:
	dec ycount
	add indexscreen, 640
	mov eax, w
	sub indexscreen, eax
	inc coordy
	mov eax, left
	mov coordx, eax
	jmp COND1

	EXIT:	
	ret    	;;  Do not delete this line!
BasicBlit ENDP

RotateBlit PROC USES eax ebx ecx edx esi edi lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
	
	LOCAL srcX:DWORD, srcY:DWORD, cosa:FXPT, sina: FXPT, shiftX: DWORD, shiftY:DWORD, dstWidth: DWORD, dstHeight: DWORD, 
	placeX: DWORD, placeY: DWORD, dstX:DWORD, dstY:DWORD

	INVOKE FixedCos, angle ;Computing the sin and cos of the angle given
	mov cosa, eax
	invoke FixedSin, angle
	mov sina, eax	
	mov esi, [lpBmp]
	mov ebx, [esi]
	mov eax, cosa
	sar eax, 1
	sal ebx, 16
	imul ebx ; multiplication with cosa/2
	mov ecx, edx	; value of the product
	mov ebx, [esi + 4]
	mov eax, sina
	sar eax, 1
	shl ebx, 16
	imul ebx
	sub ecx, edx 
	mov shiftX, ecx

; Computing shiftY 

	mov ebx, [esi + 4]
	mov eax, cosa; 
	sar eax, 1
	shl ebx, 16
	imul ebx ; multiplication with sina/2
	mov ecx, edx	
	mov ebx, [esi]
	mov eax, sina
	sar eax, 1
	shl ebx, 16
	imul ebx
	add ecx, edx 
	mov shiftY, ecx
	
; Computing dstWidth
	mov ecx, [esi]
	mov ebx, [esi + 4]
	add ebx, ecx
	mov dstWidth, ebx
	mov dstHeight, ebx

; Writing the Outer for loop

	neg ebx
	mov dstX, ebx
	
outerforloop:
	mov ecx, dstWidth
	cmp dstX, ecx
	jge Exit 	; exit of the loop if dstX>=dstHeight
	mov ebx, dstHeight
	neg ebx
	mov dstY, ebx
innerforloop: 
	mov ecx, dstHeight
	cmp dstY, ecx
	jge exitout
;computing srcX
	mov ebx, dstX
	shl ebx, 16
	mov eax, cosa
	imul ebx
	mov srcX, edx
	mov ebx, dstY
	shl ebx, 16	
	mov eax, sina
	imul ebx
	add srcX, edx
		
;Computing srcY
	mov ebx, dstY
	mov eax, cosa
	shl ebx, 16
	imul ebx
	mov srcY, edx
	mov ebx, dstX	
	mov eax, sina
	shl ebx, 16	
	imul ebx
	sub srcY, edx
		
; Writing the 'if' case

	cmp srcX, 0
	jl next_iter
	mov ecx, [esi]; what's the difference between [ptrname] and ptrname[4*index] and [ptrname + 4*index]
	cmp srcX, ecx
	jge next_iter
	
	cmp srcY, 0
	jl next_iter
	mov ecx, [esi +4]
	cmp srcY, ecx
	jge next_iter
	
	mov ebx,xcenter
	add ebx, dstX
	sub ebx, shiftX
	mov placeX, ebx
	cmp ebx, 0
	jl next_iter
	cmp ebx, 639
	jge next_iter

	mov ebx, ycenter
	add ebx, dstY
	sub ebx, shiftY
	mov placeY, ebx
	cmp ebx, 0
	jl next_iter
	
	cmp ebx, 479
	jge next_iter
	
	mov eax, [esi]
	imul srcY
	add eax, srcX
	mov edx, [esi + 12] ; edx xontains the pointer lpbytes 
	mov bl, [edx + eax]	; ecx contains the color value at point (srcX, srcY)
	cmp bl, [esi + 8]
	movzx ecx, bl
	je next_iter
	
; If all things pass and we finally enter the if construct
	mov ebx, ScreenBitsPtr
	mov eax, 640
	imul placeY
	add eax, placeX
	mov [ebx + eax], ecx
	
next_iter: 
	inc dstY
	jmp innerforloop	
	
exitout: 
	inc dstX
	jmp outerforloop

Exit:
	ret  	;;  Do not delete this line!
	
RotateBlit ENDP


CheckIntersectRect PROC USES ebx ecx edx edi esi one:PTR EECS205RECT, two:PTR EECS205RECT
	
	;left = ptr
	;top = ptr + 4
	;right = ptr + 8
	;bottom = ptr + 12

	mov edi, one
	mov esi, two

	;;;one.bottom < two.top;;;
	mov ecx, [edi + 12]		;one.bottom
	mov ebx, [esi + 4]		;two.top
	cmp ecx, ebx
	jl KEEPCALM

	;;;two.bottom < one.top;;;
	mov ecx, [esi + 12]		;two.bottom
	mov ebx, [edi + 4]		;one.top
	cmp ecx, ebx
	jl KEEPCALM

	;;;two.right < one.left;;;
	mov ecx, [esi + 8]		;two.right
	mov ebx, [edi]			;one.left
	cmp ecx, ebx
	jl KEEPCALM

	;;;one.right < two.left;;;
	mov ecx, [edi + 8]		;one.right
	mov ebx, [esi]			;two.left
	cmp ecx, ebx
	jl KEEPCALM

	mov eax, 1
	jmp Exit

	KEEPCALM:
	mov eax, 0

	Exit:
	ret  	;;  Do not delete this line!
	
CheckIntersectRect ENDP

END
