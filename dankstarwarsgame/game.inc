;  #########################################################################
;
;   game.inc - Includes for EECS205 Assignment 4/5
;
;
; #########################################################################

;; Library Definitions
MouseInfo STRUCT
 horiz DWORD ?
 vert  DWORD ?
 buttons DWORD ?
MouseInfo ENDS

MK_CONTROL  = 0008h  ;; The CTRL key is down.
MK_LBUTTON  = 0001h  ;; The left mouse button is down.
MK_MBUTTON  = 0010h  ;; The middle mouse button is down.
MK_RBUTTON  = 0002h  ;; The right mouse button is down.
MK_SHIFT    = 0004h  ;; The SHIFT key is down.
MK_XBUTTON1 = 0020h  ;; The first X button is down.
MK_XBUTTON2 = 0040h  ;; The second X button is down.

xwingsprite STRUCT
 basehealth DWORD ?
 health DWORD ?
 damage DWORD ?
 velocity DWORD ?
 xcenter DWORD ?
 ycenter DWORD ?
 firespeed DWORD ?
 firestatus DWORD ?
 laserx1 DWORD ?
 lasery1 DWORD ?
 laserx2 DWORD ?
 lasery2 DWORD ?
 laserx3 DWORD ?
 lasery3 DWORD ?
 laser1 DWORD ?
 laser2 DWORD ?
 laser3 DWORD ?
 presence DWORD ?
xwingsprite ENDS

enemysprite STRUCT
 health DWORD ?
 damage DWORD ?
 velocity DWORD ?
 xcenter DWORD ?
 ycenter DWORD ?
 goaly DWORD ? 
 laserx DWORD ?
 lasery DWORD ?
 laser DWORD ?
 presence DWORD ?
 moving DWORD ?
enemysprite ENDS

;; Library Functions
BlackStarField	PROTO
DrawStr PROTO myStr:PTR BYTE, x:DWORD, y:DWORD, color:DWORD

;; Library Data
EXTERNDEF StarBitmap:EECS205BITMAP
EXTERNDEF MouseStatus:MouseInfo
EXTERNDEF KeyUp:DWORD
EXTERNDEF KeyDown:DWORD
EXTERNDEF KeyPress:DWORD
EXTERNDEF x_wing:EECS205BITMAP
EXTERNDEF tie_fighter:EECS205BITMAP
EXTERNDEF purplelaser:EECS205BITMAP
EXTERNDEF bluelaser:EECS205BITMAP
EXTERNDEF redlaser:EECS205BITMAP
EXTERNDEF greenlaser:EECS205BITMAP
EXTERNDEF starwars:EECS205BITMAP
EXTERNDEF explosion:EECS205BITMAP
EXTERNDEF darthvader:EECS205BITMAP
EXTERNDEF darthvaderhit:EECS205BITMAP
EXTERNDEF tie_fighterhit:EECS205BITMAP
EXTERNDEF x_winghit:EECS205BITMAP
EXTERNDEF yoda:EECS205BITMAP
EXTERNDEF spacebar:EECS205BITMAP
EXTERNDEF arrowkeys:EECS205BITMAP
EXTERNDEF tieinterceptor:EECS205BITMAP
EXTERNDEF tieinterceptorhit:EECS205BITMAP
EXTERNDEF x_wing2:EECS205BITMAP
EXTERNDEF x_wing2hit:EECS205BITMAP
EXTERNDEF x_wing3:EECS205BITMAP
EXTERNDEF x_wing3hit:EECS205BITMAP
EXTERNDEF tieinterceptor2:EECS205BITMAP
EXTERNDEF tieinterceptor2hit:EECS205BITMAP

;; User Defined Functions
GameInit PROTO
GamePlay PROTO





