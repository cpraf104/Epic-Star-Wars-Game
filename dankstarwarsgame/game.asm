; #########################################################################
;
;   game.asm - Assembly file for EECS205 Assignment 4/5
;
;
;   Ethan Park
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include blit.inc
include game.inc
include keys.inc
include \masm32\include\windows.inc
include \masm32\include\winmm.inc
includelib \masm32\lib\winmm.lib
	
.DATA

      xwing xwingsprite <>
      tie1 enemysprite <>
      tie2 enemysprite <>
      tie3 enemysprite <>
      vader enemysprite <>
      screenbits = 307200           ;total number of bits in 640x480 screen
      xwingcol EECS205RECT <>       ; x-wing struct for collision-detecting
      tie1col EECS205RECT <>        ; tie-fighter struct for collision-detecting
      tie2col EECS205RECT <>
      tie3col EECS205RECT <>
      darthvadercol EECS205RECT <>
      laser1col EECS205RECT <>      ; structs for collision-detection on the three x-wing laser beams
      laser2col EECS205RECT <>
      laser3col EECS205RECT <>
      tie1lasercol EECS205RECT <>
      tie2lasercol EECS205RECT <>
      tie3lasercol EECS205RECT <>
      vaderlasercol EECS205RECT <>
      star1 DWORD ?
      star2 DWORD ?
      star3 DWORD ?
      star4 DWORD ?
      star5 DWORD ?
      star6 DWORD ?
      star7 DWORD ?
      star8 DWORD ?
      star9 DWORD ?
      star10 DWORD ?
      star11 DWORD ?
      star12 DWORD ?
      star13 DWORD ?
      star14 DWORD ?
      star15 DWORD ?
      star16 DWORD ?
      starspeed DWORD ?
      xwinglaserptr DWORD ?
      tieptr DWORD ?
      tiehitptr DWORD ?
      xwingptr DWORD ?
      xwinghitptr DWORD ?
      start DWORD ?
      presskeytostart BYTE "Press C to continue", 0
      welcomemessage BYTE "Who doesn't love some good ol' Star Wars action?", 0
      controls1 BYTE "The controls are simple: ", 0
      controls2 BYTE "Arrow keys to move the x-wing.", 0
      controls3 BYTE "Space bar to shoot lasers.", 0
      presskeytocontinue BYTE "Press Enter to start", 0 
      Force BYTE "Force.wav", 0
      strongforce BYTE "strongforce.wav", 0
      no BYTE "no.wav", 0
      cantina BYTE "cantina.wav", 0
      always BYTE "always.wav", 0
      pressptopause BYTE "P to pause", 0
      pressrtoresume BYTE "Press R to resume", 0
      upgrade BYTE "UPGRADES", 0
      damageupgrade BYTE "Increase damage by 5 - Press D", 0
      healthupgrade BYTE "Increase health by 10 - Press H", 0
      level1message BYTE "LEVEL 1", 0
      level2message BYTE "LEVEL 2", 0
      level3message BYTE "LEVEL 3", 0
      gameoverman BYTE "GAME OVER", 0
      pressrtorestart BYTE "Press R to restart level", 0
      bossadvice BYTE "Boss is invincible until its escorts are dead.", 0
      winner BYTE "You've won!", 0
      wave DWORD ?
      level DWORD ?
      randomtimer DWORD ?
      wavetimer DWORD ?
      enemiesleft DWORD ?
      message DWORD ?
      specialtimer DWORD ?
      
;; If you need to, you can place global variables here


.CODE

GameInit PROC USES eax ebx ecx edx edi esi
	
      invoke BasicBlit, OFFSET starwars, 310, 200

      invoke DrawStr, OFFSET presskeytostart, 235, 340, 0ffh

      mov xwing.basehealth, 40
      mov xwing.health, 40
      mov xwing.damage, 10
      mov xwing.velocity, 20
      mov xwing.xcenter, 60
      mov xwing.ycenter, 240
      mov xwing.firespeed, 10
      mov xwing.firestatus, 1
      mov xwing.laser1, 0
      mov xwing.laser2, 0
      mov xwing.laser3, 0
      mov xwing.presence, 1

      mov xwingcol.dwLeft, 4
      mov xwingcol.dwTop, 223
      mov xwingcol.dwRight, 116
      mov xwingcol.dwBottom, 257

      mov tie1.presence, 0
      mov tie1col.dwLeft, 680
      mov tie1col.dwTop, 218
      mov tie1col.dwRight, 740
      mov tie1col.dwBottom, 262

      mov tie2.presence, 0
      mov tie2col.dwLeft, 730
      mov tie2col.dwRight, 790
      mov tie2col.dwTop, 258
      mov tie2col.dwBottom, 302

      mov tie3.presence, 0
      mov tie3col.dwLeft, 730
      mov tie3col.dwRight, 790
      mov tie3col.dwTop, 178
      mov tie3col.dwBottom, 222

      mov vader.presence, 0
      mov darthvadercol.dwLeft, 680
      mov darthvadercol.dwTop, 218
      mov darthvadercol.dwRight, 740
      mov darthvadercol.dwBottom, 262

      mov star1, 268
      mov star2, 369
      mov star3, 215
      mov star4, 84
      mov star5, 595
      mov star6, 201
      mov star7, 492
      mov star8, 526
      mov star9, 212
      mov star10, 336
      mov star11, 289
      mov star12, 153
      mov star13, 356
      mov star14, 575
      mov star15, 125
      mov star16, 480
      mov starspeed, 20

      mov xwinglaserptr, OFFSET redlaser
      mov tieptr, OFFSET tie_fighter
      mov tiehitptr, OFFSET tie_fighterhit
      mov xwingptr, OFFSET x_wing
      mov xwinghitptr, OFFSET x_winghit

      mov start, 0

      mov wave, 1
      mov level, 1

      mov randomtimer, 20

      mov wavetimer, 21

      mov message, 0

      mov specialtimer, 50

	ret         ;; Do not delete this line!!!
GameInit ENDP

GamePlay PROC USES eax ebx ecx edx edi esi

      cmp start, 0
      je starwarslogo
      cmp start, 1
      je instructions
      cmp start, 2
      je GAME
      cmp start, 3
      je paused
      cmp start, 4
      je upgrades
      cmp start, 5
      je gameover
      cmp start, 6
      je victorysound
      cmp start, 7
      je victoryscreen
      jmp GAME

    starwarslogo:
      cmp KeyPress, 43h
      je instructionclear
      jmp Exit

    instructionclear:
      mov edi, ScreenBitsPtr
      mov al, 000h
      mov ecx, screenbits
      cld
      rep stosb

    instructions:
      mov start, 1
      invoke DrawStr, OFFSET welcomemessage, 50, 50, 0ffh
      invoke DrawStr, OFFSET controls1, 50, 100, 0ffh
      invoke DrawStr, OFFSET controls2, 50, 200, 0ffh
      invoke DrawStr, OFFSET controls3, 50, 300, 0ffh
      invoke DrawStr, OFFSET presskeytocontinue, 220, 410, 0ffh
      invoke DrawStr, OFFSET pressptopause, 50, 330, 0ffh
      invoke DrawStr, OFFSET bossadvice, 50, 360, 0ffh
      invoke BasicBlit, OFFSET yoda, 530, 100
      invoke BasicBlit, OFFSET arrowkeys, 130, 155
      invoke BasicBlit, OFFSET spacebar, 150, 260
      cmp KeyPress, 0Dh
      je readysetgo
      jmp Exit

    readysetgo:
      mov start, 2
      mov edi, ScreenBitsPtr
      mov al, 000h
      mov ecx, screenbits
      cld
      rep stosb
      invoke PlaySound, OFFSET Force, 0, SND_FILENAME
      jmp GAME

    paused:
      invoke DrawStr, OFFSET pressrtoresume, 230, 220, 0ffh
      cmp KeyPress, 52h
      jne Exit
      mov start, 2
      jmp Exit

    upgrades:
      invoke DrawStr, OFFSET upgrade, 277, 150, 0ffh
      invoke DrawStr, OFFSET damageupgrade, 190, 200, 0ffh
      invoke DrawStr, OFFSET healthupgrade, 190, 230, 0ffh
      cmp KeyPress, 44h
      je upgradedamage
      cmp KeyPress, 48h
      je upgradehealth
      jmp Exit

    upgradedamage:
      mov eax, xwing.basehealth
      mov xwing.health, eax
      add xwing.damage, 5
      mov start, 2
      cmp xwing.damage, 15
      je makepurplelaser
      cmp xwing.damage, 20
      je makebluelaser

    makepurplelaser:
      mov xwinglaserptr, OFFSET purplelaser
      jmp Exit

    makebluelaser:
      mov xwinglaserptr, OFFSET bluelaser
      jmp Exit

    upgradehealth:
      cmp xwing.basehealth, 40
      je firsthealthupgrade
      cmp xwing.basehealth, 50
      je secondhealthupgrade

    firsthealthupgrade:
      mov xwing.health, 50
      mov xwing.basehealth, 50
      mov start, 2
      mov xwingptr, OFFSET x_wing2
      mov xwinghitptr, OFFSET x_wing2hit
      jmp Exit

    secondhealthupgrade:
      mov xwing.health, 60
      mov xwing.basehealth, 60
      mov start, 2
      mov xwingptr, OFFSET x_wing3
      mov xwinghitptr, OFFSET x_wing3hit
      jmp Exit

    gameover:
      invoke DrawStr, OFFSET gameoverman, 265, 150, 0ffh
      invoke DrawStr, OFFSET pressrtorestart, 210, 200, 0ffh
      cmp KeyPress, 52h
      je resetgame
      jmp Exit

    resetgame:
      mov eax, xwing.basehealth
      mov xwing.health, eax
      mov xwing.xcenter, 60
      mov xwing.ycenter, 240
      mov xwing.firestatus, 1
      mov xwing.laser1, 0
      mov xwing.laser2, 0
      mov xwing.laser3, 0
      mov xwing.presence, 1
      mov xwingcol.dwLeft, 4
      mov xwingcol.dwTop, 223
      mov xwingcol.dwRight, 116
      mov xwingcol.dwBottom, 257

      mov vader.presence, 0
      mov darthvadercol.dwLeft, 680
      mov darthvadercol.dwTop, 218
      mov darthvadercol.dwRight, 740
      mov darthvadercol.dwBottom, 262

      mov randomtimer, 20
      mov wavetimer, 21
      mov wave, 1
      mov start, 2
      cmp level, 2
      je resetalttiefighters
      mov tie1.presence, 0
      mov tie1col.dwLeft, 680
      mov tie1col.dwTop, 218
      mov tie1col.dwRight, 740
      mov tie1col.dwBottom, 262

      mov tie2.presence, 0
      mov tie2col.dwLeft, 730
      mov tie2col.dwRight, 790
      mov tie2col.dwTop, 258
      mov tie2col.dwBottom, 302

      mov tie3.presence, 0
      mov tie3col.dwLeft, 730
      mov tie3col.dwRight, 790
      mov tie3col.dwTop, 178
      mov tie3col.dwBottom, 222
      jmp Exit

    resetalttiefighters:
      mov tie1.presence, 0
      mov tie1col.dwLeft, 668
      mov tie1col.dwTop, 218
      mov tie1col.dwRight, 753
      mov tie1col.dwBottom, 262

      mov tie2.presence, 0
      mov tie2col.dwLeft, 718
      mov tie2col.dwRight, 803
      mov tie2col.dwTop, 258
      mov tie2col.dwBottom, 302

      mov tie3.presence, 0
      mov tie3col.dwLeft, 718
      mov tie3col.dwRight, 803
      mov tie3col.dwTop, 178
      mov tie3col.dwBottom, 222
      jmp Exit

    victorysound:
      invoke PlaySound, OFFSET no, 0, SND_FILENAME
      invoke PlaySound, OFFSET always, 0, SND_FILENAME
      invoke DrawStr, OFFSET winner, 270, 150, 0ffh
      invoke PlaySound, OFFSET cantina, 0, SND_FILENAME OR SND_ASYNC
      mov start, 7
      jmp Exit

    victoryscreen:
      invoke DrawStr, OFFSET winner, 270, 150, 0ffh
      jmp Exit
      

    GAME:
      invoke CheckIntersectRect, OFFSET xwingcol, OFFSET tie1col
      cmp eax, 1
      je collision1
      invoke CheckIntersectRect, OFFSET xwingcol, OFFSET tie2col
      cmp eax, 1
      je collision2
      invoke CheckIntersectRect, OFFSET xwingcol, OFFSET tie3col
      cmp eax, 1
      je collision3

      invoke CheckIntersectRect, OFFSET xwingcol, OFFSET tie1lasercol
      cmp eax, 1
      je xwinghit1
      invoke CheckIntersectRect, OFFSET xwingcol, OFFSET tie2lasercol
      cmp eax, 1
      je xwinghit2
      invoke CheckIntersectRect, OFFSET xwingcol, OFFSET tie3lasercol
      cmp eax, 1
      je xwinghit3

      invoke CheckIntersectRect, OFFSET xwingcol, OFFSET vaderlasercol
      cmp eax, 1
      je xwinghitvader
      
      invoke CheckIntersectRect, OFFSET tie1col, OFFSET laser1col
      cmp eax, 1
      je hit1tie1
      invoke CheckIntersectRect, OFFSET tie1col, OFFSET laser2col
      cmp eax, 1
      je hit2tie1
      invoke CheckIntersectRect, OFFSET tie1col, OFFSET laser3col
      cmp eax, 1
      je hit3tie1

      invoke CheckIntersectRect, OFFSET tie2col, OFFSET laser1col
      cmp eax, 1
      je hit1tie2
      invoke CheckIntersectRect, OFFSET tie2col, OFFSET laser2col
      cmp eax, 1
      je hit2tie2
      invoke CheckIntersectRect, OFFSET tie2col, OFFSET laser3col
      cmp eax, 1
      je hit3tie2

      invoke CheckIntersectRect, OFFSET tie3col, OFFSET laser1col
      cmp eax, 1
      je hit1tie3
      invoke CheckIntersectRect, OFFSET tie3col, OFFSET laser2col
      cmp eax, 1
      je hit2tie3
      invoke CheckIntersectRect, OFFSET tie3col, OFFSET laser3col
      cmp eax, 1
      je hit3tie3

      invoke CheckIntersectRect, OFFSET darthvadercol, OFFSET laser1col
      cmp eax, 1
      je hitvader1
      invoke CheckIntersectRect, OFFSET darthvadercol, OFFSET laser2col
      cmp eax, 1
      je hitvader2
      invoke CheckIntersectRect, OFFSET darthvadercol, OFFSET laser3col
      cmp eax, 1
      je hitvader3

    tieupdatepartc:
      cmp vader.laser, 1
      je vaderlasertravel

    tieupdatepartc1:
      cmp vader.presence, 0
      je tieupdatepartd
      cmp vader.xcenter, 510
      jg vaderintro
      cmp vader.moving, 0
      je vadersetgoal
      mov eax, vader.ycenter
      cmp vader.goaly, eax
      je tieupdatepartc2
      jg vaderdown
      mov eax, vader.velocity
      sub vader.ycenter, eax
      sub darthvadercol.dwTop, eax
      sub darthvadercol.dwBottom, eax
      jmp tieupdatepartd

    tieupdatepartc2:
      mov vader.moving, 0
      cmp vader.laser, 1
      jne firevaderlaser

    tieupdatepartd:
      cmp tie1.laser, 1
      je tie1lasertravel

    tieupdatepartd1:
      cmp tie1.presence, 0
      je tieupdateparte
      cmp tie1.xcenter, 510
      jg tie1intro
      cmp tie1.moving, 0
      je tie1setgoal
      mov eax, tie1.ycenter
      cmp tie1.goaly, eax
      je tieupdatepartd2
      jg tie1down
      mov eax, tie1.velocity
      sub tie1.ycenter, eax
      sub tie1col.dwTop, eax
      sub tie1col.dwBottom, eax
      jmp tieupdateparte

    tieupdatepartd2:
      mov tie1.moving, 0
      cmp tie1.laser, 1
      jne firetie1laser

    tieupdateparte:
      cmp tie2.laser, 1
      je tie2lasertravel

    tieupdateparte1:
      cmp tie2.presence, 0
      je tieupdatepartf
      cmp tie2.xcenter, 590
      jg tie2intro
      cmp tie2.moving, 0
      je tie2setgoal
      mov eax, tie2.ycenter
      cmp tie2.goaly, eax
      je tieupdateparte2
      jg tie2down
      mov eax, tie2.velocity
      sub tie2.ycenter, eax
      sub tie2col.dwTop, eax
      sub tie2col.dwBottom, eax
      jmp tieupdatepartf

    tieupdateparte2:
      mov tie2.moving, 0
      cmp tie2.laser, 1
      jne firetie2laser

    tieupdatepartf:
      cmp tie3.laser, 1
      je tie3lasertravel

    tieupdatepartf1:
      cmp tie3.presence, 0
      je laserstuff
      cmp tie3.xcenter, 590
      jg tie3intro
      cmp tie3.moving, 0
      je tie3setgoal
      mov eax, tie3.ycenter
      cmp tie3.goaly, eax
      je tieupdatepartf2
      jg tie3down
      mov eax, tie3.velocity
      sub tie3.ycenter, eax
      sub tie3col.dwTop, eax
      sub tie3col.dwBottom, eax
      jmp laserstuff

    tieupdatepartf2:
      mov tie3.moving, 0
      cmp tie3.laser, 1
      jne firetie3laser
      jmp laserstuff
      
    vadersetgoal:
      mov eax, xwing.ycenter
      mov vader.goaly, eax
      mov vader.moving, 1
      jmp tieupdatepartd

    tie1setgoal:
      mov eax, xwing.ycenter
      mov tie1.goaly, eax
      mov tie1.moving, 1
      jmp tieupdateparte

    tie2setgoal:
      mov tie2.moving, 1
      mov eax, tie1.presence
      add eax, tie3.presence
      add eax, vader.presence
      cmp eax, 0
      je tie2setgoalalt
      mov eax, xwing.ycenter
      add eax, 40
      mov tie2.goaly, eax
      jmp tieupdatepartf

    tie2setgoalalt:
      mov eax, xwing.ycenter
      mov tie2.goaly, eax
      jmp tieupdatepartf

    tie3setgoal:
      mov tie3.moving, 1
      mov eax, tie1.presence
      add eax, tie2.presence
      add eax, vader.presence
      cmp eax, 0
      je tie3setaltgoal
      mov eax, xwing.ycenter
      sub eax, 40
      mov tie3.goaly, eax
      jmp laserstuff

    tie3setaltgoal:
      mov eax, xwing.ycenter
      mov tie3.goaly, eax
      jmp laserstuff

    vaderintro:
      sub vader.xcenter, 5
      sub darthvadercol.dwRight, 5
      sub darthvadercol.dwLeft, 5
      jmp tieupdatepartd

    tie1intro:
      sub tie1.xcenter, 5
      sub tie1col.dwRight, 5
      sub tie1col.dwLeft, 5
      jmp tieupdateparte

    tie2intro:
      sub tie2.xcenter, 5
      sub tie2col.dwRight, 5
      sub tie2col.dwLeft, 5
      jmp tieupdatepartf

    tie3intro:
      sub tie3.xcenter, 5
      sub tie3col.dwRight, 5
      sub tie3col.dwLeft, 5
      jmp laserstuff

    vaderdown:
      mov eax, vader.velocity
      add vader.ycenter, eax
      add darthvadercol.dwTop, eax
      add darthvadercol.dwBottom, eax
      jmp tieupdatepartd

    tie1down:
      mov eax, tie1.velocity
      add tie1.ycenter, eax
      add tie1col.dwTop, eax
      add tie1col.dwBottom, eax
      jmp tieupdateparte

    tie2down:
      mov eax, tie2.velocity
      add tie2.ycenter, eax
      add tie2col.dwTop, eax
      add tie2col.dwBottom, eax
      jmp tieupdatepartf

    tie3down:
      mov eax, tie3.velocity
      add tie3.ycenter, eax
      add tie3col.dwTop, eax
      add tie3col.dwBottom, eax
      jmp laserstuff

    firevaderlaser:
      mov eax, darthvadercol.dwLeft
      mov vader.laserx, eax
      sub eax, 20
      mov vaderlasercol.dwLeft, eax
      add eax, 40
      mov vaderlasercol.dwRight, eax
      mov eax, vader.ycenter
      mov vader.lasery, eax
      sub eax, 6
      mov vaderlasercol.dwTop, eax
      add eax, 13
      mov vaderlasercol.dwBottom, eax
      mov vader.laser, 1
      mov vader.moving, 0
      jmp tieupdatepartd
    
    firetie1laser:
      mov eax, tie1col.dwLeft
      mov tie1.laserx, eax
      sub eax, 20
      mov tie1lasercol.dwLeft, eax
      add eax, 40
      mov tie1lasercol.dwRight,eax
      mov eax, tie1.ycenter
      mov tie1.lasery, eax
      sub eax, 6
      mov tie1lasercol.dwTop, eax
      add eax, 13
      mov tie1lasercol.dwBottom, eax
      mov tie1.laser, 1
      mov tie1.moving, 0
      jmp tieupdateparte

    firetie2laser:
      mov eax, tie2col.dwLeft
      mov tie2.laserx, eax
      sub eax, 20
      mov tie2lasercol.dwLeft, eax
      add eax, 40
      mov tie2lasercol.dwRight,eax
      mov eax, tie2.ycenter
      mov tie2.lasery, eax
      sub eax, 6
      mov tie2lasercol.dwTop, eax
      add eax, 13
      mov tie2lasercol.dwBottom, eax
      mov tie2.laser, 1
      mov tie2.moving, 0
      jmp tieupdatepartf

    firetie3laser:
      mov eax, tie3col.dwLeft
      mov tie3.laserx, eax
      sub eax, 20
      mov tie3lasercol.dwLeft, eax
      add eax, 40
      mov tie3lasercol.dwRight,eax
      mov eax, tie3.ycenter
      mov tie3.lasery, eax
      sub eax, 6
      mov tie3lasercol.dwTop, eax
      add eax, 13
      mov tie3lasercol.dwBottom, eax
      mov tie3.laser, 1
      mov tie3.moving, 0
      jmp laserstuff

    vaderlasertravel:
      sub vader.laserx, 20
      sub vaderlasercol.dwLeft, 20
      sub vaderlasercol.dwRight, 20
      cmp vader.laserx, 20
      jle removevaderlaser
      jmp tieupdatepartc1

    tie1lasertravel:
      sub tie1.laserx, 20
      sub tie1lasercol.dwLeft, 20
      sub tie1lasercol.dwRight, 20
      cmp tie1.laserx, 20
      jle removetie1laser
      jmp tieupdatepartd1

    tie2lasertravel:
      sub tie2.laserx, 20
      sub tie2lasercol.dwLeft, 20
      sub tie2lasercol.dwRight, 20
      cmp tie2.laserx, 20
      jle removetie2laser
      jmp tieupdateparte1

    tie3lasertravel:
      sub tie3.laserx, 20
      sub tie3lasercol.dwLeft, 20
      sub tie3lasercol.dwRight, 20
      cmp tie3.laserx, 20
      jle removetie3laser
      jmp tieupdatepartf1

    laserstuff:
      mov eax, xwing.laser1
      add eax, xwing.laser2
      add eax, xwing.laser3
      cmp eax, 0
      jne reload

    precondcheck:
      cmp xwing.firespeed, 10
      je condcheck
      cmp xwing.firespeed, 0
      je resetfirespeed
      dec xwing.firespeed
      jmp condcheck

    reload:
      cmp xwing.firestatus, 1
      je lasercheck1
      cmp xwing.firespeed, 0
      je resetfirespeed
      sub xwing.firespeed, 1
      jmp lasercheck1

    resetfirespeed:
      mov xwing.firespeed, 10
      mov xwing.firestatus, 1

    lasercheck1:
      cmp xwing.laser1, 1
      je lasertravel1

    lasercheck2:
      cmp xwing.laser2, 1
      je lasertravel2

    lasercheck3:
      cmp xwing.laser3, 1
      je lasertravel3
      jne condcheck

    lasertravel1:
      add xwing.laserx1, 20
      add laser1col.dwLeft, 20
      add laser1col.dwRight, 20
      cmp xwing.laserx1, 620
      jge removelaser1
      jmp lasercheck2

    lasertravel2:
      add xwing.laserx2, 20
      add laser2col.dwLeft, 20
      add laser2col.dwRight, 20
      cmp xwing.laserx2, 620
      jge removelaser2
      jmp lasercheck3

    lasertravel3:
      add xwing.laserx3, 20
      add laser3col.dwLeft, 20
      add laser3col.dwRight, 20
      cmp xwing.laserx3, 620
      jge removelaser3 

    condcheck:
      mov esi, xwing.velocity
      cmp KeyPress, 27h
      je moveright
      cmp KeyPress, 25h
      je moveleft
      cmp KeyPress, 26h
      je moveup
      cmp KeyPress, 28h
      je movedown
      cmp KeyPress, 20h
      je firelaser
      cmp KeyPress, 50h
      je prepause
      jmp intermission

    firelaser:
      cmp xwing.firestatus, 0
      je intermission
      mov xwing.firestatus, 0
      cmp xwing.laser1, 1
      je firesecondlaser
      mov xwing.laser1, 1
      mov eax, xwingcol.dwRight
      mov xwing.laserx1, eax
      sub eax, 20
      mov laser1col.dwLeft, eax
      add eax, 40
      mov laser1col.dwRight, eax
      mov eax, xwing.ycenter
      mov xwing.lasery1, eax
      sub eax, 6
      mov laser1col.dwTop, eax
      add eax, 13
      mov laser1col.dwBottom, eax
      jmp intermission

    firesecondlaser:
      cmp xwing.laser2, 1
      je firethirdlaser
      mov xwing.laser2, 1
      mov eax, xwingcol.dwRight
      mov xwing.laserx2, eax
      sub eax, 20
      mov laser2col.dwLeft, eax
      add eax, 40
      mov laser2col.dwRight, eax
      mov eax, xwing.ycenter
      mov xwing.lasery2, eax
      sub eax, 6
      mov laser2col.dwTop, eax
      add eax, 13
      mov laser2col.dwBottom, eax
      jmp intermission

    firethirdlaser:
      mov xwing.laser3, 1
      mov eax, xwingcol.dwRight
      mov xwing.laserx3, eax
      sub eax, 20
      mov laser3col.dwLeft, eax
      add eax, 40
      mov laser3col.dwRight, eax
      mov eax, xwing.ycenter
      mov xwing.lasery3, eax
      sub eax, 6
      mov laser3col.dwTop, eax
      add eax, 13
      mov laser3col.dwBottom, eax
      jmp intermission

    moveright:
      cmp xwing.xcenter, 580
      jge screenupdate
      add xwing.xcenter, esi
      add xwingcol.dwRight, esi
      add xwingcol.dwLeft, esi
      jmp intermission

    moveleft:
      cmp xwing.xcenter, 60
      jle screenupdate
      sub xwing.xcenter, esi
      sub xwingcol.dwRight, esi
      sub xwingcol.dwLeft, esi
      jmp intermission

    moveup:
      cmp xwing.ycenter, 20
      jle screenupdate
      sub xwing.ycenter, esi
      sub xwingcol.dwTop, esi
      sub xwingcol.dwBottom, esi
      jmp intermission

    movedown:
      cmp xwing.ycenter, 430
      jge screenupdate
      add xwing.ycenter, esi
      add xwingcol.dwTop, esi
      add xwingcol.dwBottom, esi
      jmp intermission

    removelaser1:
      mov xwing.laser1, 0
      mov laser1col.dwLeft, 2000
      mov laser1col.dwRight, 2000
      mov laser1col.dwTop, 2000
      mov laser1col.dwBottom, 2000
      jmp lasercheck2

    removelaser2:
      mov xwing.laser2, 0
      mov laser2col.dwLeft, 2000
      mov laser2col.dwRight, 2000
      mov laser2col.dwTop, 2000
      mov laser2col.dwBottom, 2000
      jmp lasercheck3

    removelaser3:
      mov xwing.laser3, 0
      mov laser3col.dwLeft, 2000
      mov laser3col.dwRight, 2000
      mov laser3col.dwTop, 2000
      mov laser3col.dwBottom, 2000
      jmp condcheck

    removevaderlaser:
      mov vaderlasercol.dwLeft, 2000
      mov vaderlasercol.dwRight, 2000
      mov vaderlasercol.dwTop, 2000
      mov vaderlasercol.dwBottom, 2000
      mov vader.laser, 0
      jmp tieupdatepartd

    removetie1laser:
      mov tie1lasercol.dwLeft, 2000
      mov tie1lasercol.dwRight, 2000
      mov tie1lasercol.dwTop, 2000
      mov tie1lasercol.dwBottom, 2000
      mov tie1.laser, 0
      jmp tieupdateparte

    removetie2laser:
      mov tie2lasercol.dwLeft, 2000
      mov tie2lasercol.dwRight, 2000
      mov tie2lasercol.dwTop, 2000
      mov tie2lasercol.dwBottom, 2000
      mov tie2.laser, 0
      jmp tieupdatepartf

    removetie3laser:
      mov tie3lasercol.dwLeft, 2000
      mov tie3lasercol.dwRight, 2000
      mov tie3lasercol.dwTop, 2000
      mov tie3lasercol.dwBottom, 2000
      mov tie3.laser, 0
      jmp laserstuff

    intermission:

    screenupdate:
      mov edi, ScreenBitsPtr
      mov al, 000h
      mov ecx, screenbits
      cld
      rep stosb 
      cmp randomtimer, 0
      je prewave
      cmp level, 1
      je level1
      cmp level, 2
      je level2
      cmp level, 3
      je level3
      jmp starcond1

    level1:
      invoke DrawStr, OFFSET level1message, 280, 220, 0ffh
      jmp decrementtimer

    level2:
      invoke DrawStr, OFFSET level2message, 280, 220, 0ffh
      jmp decrementtimer

    level3:
      invoke DrawStr, OFFSET level3message, 280, 220, 0ffh
      jmp decrementtimer

    decrementtimer:
      dec randomtimer
      jmp starcond1

    prewave:
      cmp wavetimer, 0
      je starcond1
      cmp wavetimer, 1
      jne decrementwavetimer
      cmp level, 1
      je level1waveconds
      cmp level, 2
      je level2waveconds
      cmp level, 3
      je level3waveconds
      jmp starcond1

    level1waveconds:
      dec wavetimer
      cmp wave, 1
      je level1wave1
      cmp wave, 2
      je level1wave2
      cmp wave, 3
      je level1wave3
      cmp wave, 4
      je level1wave4
      cmp wave, 5
      je level1wave5
      cmp wave, 6
      je level1wave6
      jmp starcond1

    level2waveconds:
      dec wavetimer
      cmp wave, 1
      je level2wave1
      cmp wave, 2
      je level2wave2
      cmp wave, 3
      je level2wave3
      cmp wave, 4
      je level2wave4
      cmp wave, 5
      je level2wave5
      cmp wave, 6
      je level2wave6
      jmp starcond1

    level3waveconds:
      dec wavetimer
      cmp wave, 1
      je level3wave1
      cmp wave, 2
      je level3wave2
      cmp wave, 3
      je level3wave3
      cmp wave, 4
      je level3wave4
      cmp wave, 5
      je level3wave5
      cmp wave, 6
      je level3boss
      jmp starcond1

    level1wave1:
      mov tie1.xcenter, 710
      mov tie1.ycenter, 120
      mov tie1.presence, 1
      mov tie1.moving, 0
      mov tie1.health, 20
      mov tie1.velocity, 10
      mov tie1.damage, 10
      mov tie1.laser, 0
      mov tie1col.dwLeft, 680
      mov tie1col.dwTop, 98
      mov tie1col.dwRight, 740
      mov tie1col.dwBottom, 142
      mov enemiesleft, 1
      jmp starcond1

    level1wave2:
      mov tie1.xcenter, 710
      mov tie1.ycenter, 360
      mov tie1.presence, 1
      mov tie1.moving, 0
      mov tie1.health, 20
      mov tie1.velocity, 10
      mov tie1.damage, 10
      mov tie1.laser, 0
      mov tie1col.dwLeft, 680
      mov tie1col.dwTop, 338
      mov tie1col.dwRight, 740
      mov tie1col.dwBottom, 382
      mov enemiesleft, 1
      jmp starcond1

    level1wave3:
      mov tie1.xcenter, 710
      mov tie1.ycenter, 360
      mov tie1.presence, 1
      mov tie1.moving, 0
      mov tie1.health, 20
      mov tie1.velocity, 10
      mov tie1.damage, 10
      mov tie1.laser, 0
      mov tie1col.dwLeft, 680
      mov tie1col.dwTop, 338
      mov tie1col.dwRight, 740
      mov tie1col.dwBottom, 382

      mov tie2.xcenter, 760
      mov tie2.ycenter, 400
      mov tie2.presence, 1
      mov tie2.moving, 0
      mov tie2.health, 20
      mov tie2.velocity, 10
      mov tie2.damage, 10
      mov tie2.laser, 0
      mov tie2col.dwLeft, 730
      mov tie2col.dwRight, 790
      mov tie2col.dwTop, 378
      mov tie2col.dwBottom, 422
      mov enemiesleft, 2
      jmp starcond1

    level1wave4:
      mov tie1.xcenter, 710
      mov tie1.ycenter, 120
      mov tie1.presence, 1
      mov tie1.moving, 0
      mov tie1.health, 20
      mov tie1.velocity, 10
      mov tie1.damage, 10
      mov tie1.laser, 0
      mov tie1col.dwLeft, 680
      mov tie1col.dwTop, 98
      mov tie1col.dwRight, 740
      mov tie1col.dwBottom, 142
      
      mov tie3.xcenter, 760
      mov tie3.ycenter, 80
      mov tie3.presence, 1
      mov tie3.moving, 0
      mov tie3.health, 20
      mov tie3.velocity, 10
      mov tie3.damage, 10
      mov tie3.laser, 0
      mov tie3col.dwLeft, 730
      mov tie3col.dwRight, 790
      mov tie3col.dwTop, 58
      mov tie3col.dwBottom, 102
      mov enemiesleft, 2
      jmp starcond1

    level1wave5:
      mov tie2.xcenter, 760
      mov tie2.ycenter, 280
      mov tie2.presence, 1
      mov tie2.moving, 0
      mov tie2.health, 20
      mov tie2.velocity, 10
      mov tie2.damage, 10
      mov tie2.laser, 0
      mov tie2col.dwLeft, 730
      mov tie2col.dwRight, 790
      mov tie2col.dwTop, 258
      mov tie2col.dwBottom, 302

      mov tie3.xcenter, 760
      mov tie3.ycenter, 200
      mov tie3.presence, 1
      mov tie3.moving, 0
      mov tie3.health, 20
      mov tie3.velocity, 10
      mov tie3.damage, 10
      mov tie3.laser, 0
      mov tie3col.dwLeft, 730
      mov tie3col.dwRight, 790
      mov tie3col.dwTop, 178
      mov tie3col.dwBottom, 222
      mov enemiesleft, 2
      jmp starcond1

    level1wave6:
      mov tie1.xcenter, 710
      mov tie1.ycenter, 240
      mov tie1.presence, 1
      mov tie1.moving, 0
      mov tie1.health, 20
      mov tie1.velocity, 10
      mov tie1.damage, 10
      mov tie1.laser, 0
      mov tie1col.dwLeft, 680
      mov tie1col.dwTop, 218
      mov tie1col.dwRight, 740
      mov tie1col.dwBottom, 262

      mov tie2.xcenter, 760
      mov tie2.ycenter, 280
      mov tie2.presence, 1
      mov tie2.moving, 0
      mov tie2.health, 20
      mov tie2.velocity, 10
      mov tie2.damage, 10
      mov tie2.laser, 0
      mov tie2col.dwLeft, 730
      mov tie2col.dwRight, 790
      mov tie2col.dwTop, 258
      mov tie2col.dwBottom, 302

      mov tie3.xcenter, 760
      mov tie3.ycenter, 200
      mov tie3.presence, 1
      mov tie3.moving, 0
      mov tie3.health, 20
      mov tie3.velocity, 10
      mov tie3.damage, 10
      mov tie3.laser, 0
      mov tie3col.dwLeft, 730
      mov tie3col.dwRight, 790
      mov tie3col.dwTop, 178
      mov tie3col.dwBottom, 222
      mov enemiesleft, 3
      jmp starcond1

    level2wave1:
      mov tie1.xcenter, 710
      mov tie1.ycenter, 240
      mov tie1.presence, 1
      mov tie1.moving, 0
      mov tie1.health, 30
      mov tie1.velocity, 10
      mov tie1.damage, 15
      mov tie1.laser, 0
      mov tie1col.dwLeft, 668
      mov tie1col.dwTop, 218
      mov tie1col.dwRight, 753
      mov tie1col.dwBottom, 262
      mov enemiesleft, 1
      jmp starcond1

    level2wave2:
      mov tie1.xcenter, 710
      mov tie1.ycenter, 120
      mov tie1.presence, 1
      mov tie1.moving, 0
      mov tie1.health, 30
      mov tie1.velocity, 10
      mov tie1.damage, 15
      mov tie1.laser, 0
      mov tie1col.dwLeft, 668
      mov tie1col.dwTop, 98
      mov tie1col.dwRight, 753
      mov tie1col.dwBottom, 142

      mov tie3.xcenter, 760
      mov tie3.ycenter, 80
      mov tie3.presence, 1
      mov tie3.moving, 0
      mov tie3.health, 30
      mov tie3.velocity, 10
      mov tie3.damage, 15
      mov tie3.laser, 0
      mov tie3col.dwLeft, 718
      mov tie3col.dwRight, 803
      mov tie3col.dwTop, 58
      mov tie3col.dwBottom, 102
      mov enemiesleft, 2
      jmp starcond1

    level2wave3:
      mov tie2.xcenter, 760
      mov tie2.ycenter, 280
      mov tie2.presence, 1
      mov tie2.moving, 0
      mov tie2.health, 30
      mov tie2.velocity, 10
      mov tie2.damage, 15
      mov tie2.laser, 0
      mov tie2col.dwLeft, 718
      mov tie2col.dwRight, 803
      mov tie2col.dwTop, 258
      mov tie2col.dwBottom, 302

      mov tie3.xcenter, 760
      mov tie3.ycenter, 200
      mov tie3.presence, 1
      mov tie3.moving, 0
      mov tie3.health, 30
      mov tie3.velocity, 10
      mov tie3.damage, 15
      mov tie3.laser, 0
      mov tie3col.dwLeft, 718
      mov tie3col.dwRight, 803
      mov tie3col.dwTop, 178
      mov tie3col.dwBottom, 222
      mov enemiesleft, 2
      jmp starcond1

    level2wave4:
      mov tie1.xcenter, 710
      mov tie1.ycenter, 360
      mov tie1.presence, 1
      mov tie1.moving, 0
      mov tie1.health, 30
      mov tie1.velocity, 10
      mov tie1.damage, 15
      mov tie1.laser, 0
      mov tie1col.dwLeft, 668
      mov tie1col.dwTop, 338
      mov tie1col.dwRight, 753
      mov tie1col.dwBottom, 382

      mov tie2.xcenter, 760
      mov tie2.ycenter, 400
      mov tie2.presence, 1
      mov tie2.moving, 0
      mov tie2.health, 30
      mov tie2.velocity, 10
      mov tie2.damage, 15
      mov tie2.laser, 0
      mov tie2col.dwLeft, 718
      mov tie2col.dwRight, 803
      mov tie2col.dwTop, 378
      mov tie2col.dwBottom, 422
      mov enemiesleft, 2
      jmp starcond1

    level2wave5:
      mov tie1.xcenter, 710
      mov tie1.ycenter, 120
      mov tie1.presence, 1
      mov tie1.moving, 0
      mov tie1.health, 30
      mov tie1.velocity, 10
      mov tie1.damage, 15
      mov tie1.laser, 0
      mov tie1col.dwLeft, 668
      mov tie1col.dwTop, 98
      mov tie1col.dwRight, 753
      mov tie1col.dwBottom, 142

      mov tie2.xcenter, 760
      mov tie2.ycenter, 160
      mov tie2.presence, 1
      mov tie2.moving, 0
      mov tie2.health, 30
      mov tie2.velocity, 10
      mov tie2.damage, 15
      mov tie2.laser, 0
      mov tie2col.dwLeft, 718
      mov tie2col.dwRight, 803
      mov tie2col.dwTop, 138
      mov tie2col.dwBottom, 182

      mov tie3.xcenter, 760
      mov tie3.ycenter, 80
      mov tie3.presence, 1
      mov tie3.moving, 0
      mov tie3.health, 30
      mov tie3.velocity, 10
      mov tie3.damage, 15
      mov tie3.laser, 0
      mov tie3col.dwLeft, 718
      mov tie3col.dwRight, 803
      mov tie3col.dwTop, 58
      mov tie3col.dwBottom, 102
      mov enemiesleft, 3
      jmp starcond1

    level2wave6:
      mov tie1.xcenter, 710
      mov tie1.ycenter, 360
      mov tie1.presence, 1
      mov tie1.moving, 0
      mov tie1.health, 30
      mov tie1.velocity, 10
      mov tie1.damage, 15
      mov tie1.laser, 0
      mov tie1col.dwLeft, 668
      mov tie1col.dwTop, 338
      mov tie1col.dwRight, 753
      mov tie1col.dwBottom, 382

      mov tie2.xcenter, 760
      mov tie2.ycenter, 400
      mov tie2.presence, 1
      mov tie2.moving, 0
      mov tie2.health, 30
      mov tie2.velocity, 10
      mov tie2.damage, 15
      mov tie2.laser, 0
      mov tie2col.dwLeft, 718
      mov tie2col.dwRight, 803
      mov tie2col.dwTop, 378
      mov tie2col.dwBottom, 422

      mov tie3.xcenter, 760
      mov tie3.ycenter, 320
      mov tie3.presence, 1
      mov tie3.moving, 0
      mov tie3.health, 30
      mov tie3.velocity, 10
      mov tie3.damage, 15
      mov tie3.laser, 0
      mov tie3col.dwLeft, 718
      mov tie3col.dwRight, 803
      mov tie3col.dwTop, 298
      mov tie3col.dwBottom, 342
      mov enemiesleft, 3
      jmp starcond1

    level3wave1:
      mov tie1.xcenter, 710
      mov tie1.ycenter, 120
      mov tie1.presence, 1
      mov tie1.moving, 0
      mov tie1.health, 40
      mov tie1.velocity, 10
      mov tie1.damage, 20
      mov tie1.laser, 0
      mov tie1col.dwLeft, 668
      mov tie1col.dwTop, 98
      mov tie1col.dwRight, 753
      mov tie1col.dwBottom, 142

      mov tie3.xcenter, 760
      mov tie3.ycenter, 80
      mov tie3.presence, 1
      mov tie3.moving, 0
      mov tie3.health, 40
      mov tie3.velocity, 10
      mov tie3.damage, 20
      mov tie3.laser, 0
      mov tie3col.dwLeft, 718
      mov tie3col.dwRight, 803
      mov tie3col.dwTop, 58
      mov tie3col.dwBottom, 102
      mov enemiesleft, 2
      jmp starcond1

    level3wave2:
      mov tie1.xcenter, 710
      mov tie1.ycenter, 360
      mov tie1.presence, 1
      mov tie1.moving, 0
      mov tie1.health, 40
      mov tie1.velocity, 10
      mov tie1.damage, 20
      mov tie1.laser, 0
      mov tie1col.dwLeft, 668
      mov tie1col.dwTop, 338
      mov tie1col.dwRight, 753
      mov tie1col.dwBottom, 382

      mov tie2.xcenter, 760
      mov tie2.ycenter, 400
      mov tie2.presence, 1
      mov tie2.moving, 0
      mov tie2.health, 40
      mov tie2.velocity, 10
      mov tie2.damage, 20
      mov tie2.laser, 0
      mov tie2col.dwLeft, 718
      mov tie2col.dwRight, 803
      mov tie2col.dwTop, 378
      mov tie2col.dwBottom, 422
      mov enemiesleft, 2
      jmp starcond1

    level3wave3:
      mov tie1.xcenter, 710
      mov tie1.ycenter, 240
      mov tie1.presence, 1
      mov tie1.moving, 0
      mov tie1.health, 40
      mov tie1.velocity, 10
      mov tie1.damage, 20
      mov tie1.laser, 0
      mov tie1col.dwLeft, 668
      mov tie1col.dwTop, 218
      mov tie1col.dwRight, 753
      mov tie1col.dwBottom, 262

      mov tie2.xcenter, 760
      mov tie2.ycenter, 280
      mov tie2.presence, 1
      mov tie2.moving, 0
      mov tie2.health, 40
      mov tie2.velocity, 10
      mov tie2.damage, 20
      mov tie2.laser, 0
      mov tie2col.dwLeft, 718
      mov tie2col.dwRight, 803
      mov tie2col.dwTop, 258
      mov tie2col.dwBottom, 302

      mov tie3.xcenter, 760
      mov tie3.ycenter, 200
      mov tie3.presence, 1
      mov tie3.moving, 0
      mov tie3.health, 40
      mov tie3.velocity, 10
      mov tie3.damage, 20
      mov tie3.laser, 0
      mov tie3col.dwLeft, 718
      mov tie3col.dwRight, 803
      mov tie3col.dwTop, 178
      mov tie3col.dwBottom, 222
      mov enemiesleft, 3
      jmp starcond1

    level3wave4:
      mov tie1.xcenter, 710
      mov tie1.ycenter, 120
      mov tie1.presence, 1
      mov tie1.moving, 0
      mov tie1.health, 40
      mov tie1.velocity, 10
      mov tie1.damage, 20
      mov tie1.laser, 0
      mov tie1col.dwLeft, 668
      mov tie1col.dwTop, 98
      mov tie1col.dwRight, 753
      mov tie1col.dwBottom, 142

      mov tie2.xcenter, 760
      mov tie2.ycenter, 160
      mov tie2.presence, 1
      mov tie2.moving, 0
      mov tie2.health, 40
      mov tie2.velocity, 10
      mov tie2.damage, 20
      mov tie2.laser, 0
      mov tie2col.dwLeft, 718
      mov tie2col.dwRight, 803
      mov tie2col.dwTop, 138
      mov tie2col.dwBottom, 182

      mov tie3.xcenter, 760
      mov tie3.ycenter, 80
      mov tie3.presence, 1
      mov tie3.moving, 0
      mov tie3.health, 40
      mov tie3.velocity, 10
      mov tie3.damage, 20
      mov tie3.laser, 0
      mov tie3col.dwLeft, 718
      mov tie3col.dwRight, 803
      mov tie3col.dwTop, 58
      mov tie3col.dwBottom, 102
      mov enemiesleft, 3
      jmp starcond1

    level3wave5:
      mov tie1.xcenter, 710
      mov tie1.ycenter, 360
      mov tie1.presence, 1
      mov tie1.moving, 0
      mov tie1.health, 40
      mov tie1.velocity, 10
      mov tie1.damage, 20
      mov tie1.laser, 0
      mov tie1col.dwLeft, 668
      mov tie1col.dwTop, 338
      mov tie1col.dwRight, 753
      mov tie1col.dwBottom, 382

      mov tie2.xcenter, 760
      mov tie2.ycenter, 400
      mov tie2.presence, 1
      mov tie2.moving, 0
      mov tie2.health, 40
      mov tie2.velocity, 10
      mov tie2.damage, 20
      mov tie2.laser, 0
      mov tie2col.dwLeft, 718
      mov tie2col.dwRight, 803
      mov tie2col.dwTop, 378
      mov tie2col.dwBottom, 422

      mov tie3.xcenter, 760
      mov tie3.ycenter, 320
      mov tie3.presence, 1
      mov tie3.moving, 0
      mov tie3.health, 40
      mov tie3.velocity, 10
      mov tie3.damage, 20
      mov tie3.laser, 0
      mov tie3col.dwLeft, 718
      mov tie3col.dwRight, 803
      mov tie3col.dwTop, 298
      mov tie3col.dwBottom, 342
      mov enemiesleft, 3
      jmp starcond1

    level3boss:
      mov vader.xcenter, 710
      mov vader.ycenter, 240
      mov vader.presence, 1
      mov vader.moving, 0
      mov vader.health, 75
      mov vader.velocity, 20
      mov vader.damage, 20
      mov vader.laser, 0
      mov darthvadercol.dwLeft, 680
      mov darthvadercol.dwTop, 218
      mov darthvadercol.dwRight, 740
      mov darthvadercol.dwBottom, 262

      mov tie2.xcenter, 760
      mov tie2.ycenter, 300
      mov tie2.presence, 1
      mov tie2.moving, 0
      mov tie2.health, 40
      mov tie2.velocity, 10
      mov tie2.damage, 20
      mov tie2.laser, 0
      mov tie2col.dwLeft, 718
      mov tie2col.dwRight, 803
      mov tie2col.dwTop, 278
      mov tie2col.dwBottom, 322

      mov tie3.xcenter, 760
      mov tie3.ycenter, 180
      mov tie3.presence, 1
      mov tie3.moving, 0
      mov tie3.health, 40
      mov tie3.velocity, 10
      mov tie3.damage, 20
      mov tie3.laser, 0
      mov tie3col.dwLeft, 718
      mov tie3col.dwRight, 803
      mov tie3col.dwTop, 158
      mov tie3col.dwBottom, 202
      mov enemiesleft, 3
      jmp starcond1

    decrementwavetimer:
      cmp message, 1
      je vadermessage
      dec wavetimer
      jmp starcond1

    vadermessage:
      invoke PlaySound, OFFSET strongforce, 0, SND_FILENAME
      mov message, 0
      dec wavetimer
      jmp starcond1
            
    starcond1:
      mov eax, starspeed
      sub star1, eax
      cmp star1, 0
      jge starcond2

    resetstar1:
      mov star1, 639
      invoke DrawStar, star1, 74

    starcond2:
      invoke DrawStar, star1, 74
      mov eax, starspeed
      sub star2, eax
      cmp star2, 0
      jge starcond3

    resetstar2:
      mov star2, 639
      invoke DrawStar, star2, 340

    starcond3:
      invoke DrawStar, star2, 340
      mov eax, starspeed
      sub star3, eax
      cmp star3, 0
      jge starcond4

    resetstar3:
      mov star3, 639
      invoke DrawStar, star3, 193

    starcond4:
      invoke DrawStar, star3, 193
      mov eax, starspeed
      sub star4, eax
      cmp star4, 0
      jge starcond5

    resetstar4:
      mov star4, 639
      invoke DrawStar, star4, 342

    starcond5:
      invoke DrawStar, star4, 342
      mov eax, starspeed
      sub star5, eax
      cmp star5, 0
      jge starcond6

    resetstar5:
      mov star5, 639   
      invoke DrawStar, star5, 83

    starcond6:
      invoke DrawStar, star5, 83
      mov eax, starspeed
      sub star6, eax
      cmp star6, 0
      jge starcond7

    resetstar6:
      mov star6, 639
      invoke DrawStar, star6, 431

    starcond7:
      invoke DrawStar, star6, 431
      mov eax, starspeed
      sub star7, eax
      cmp star7, 0
      jge starcond8

    resetstar7:
      mov star7, 639
      invoke DrawStar, star7, 178

    starcond8:
      invoke DrawStar, star7, 178
      mov eax, starspeed
      sub star8, eax
      cmp star8, 0
      jge starcond9

    resetstar8:
      mov star8, 639
      invoke DrawStar, star8, 43

    starcond9:
      invoke DrawStar, star8, 43
      mov eax, starspeed
      sub star9, eax
      cmp star9, 0
      jge starcond10

    resetstar9:
      mov star9, 639
      invoke DrawStar, star9, 150

    starcond10:
      invoke DrawStar, star9, 150
      mov eax, starspeed
      sub star10, eax
      cmp star10, 0
      jge starcond11

    resetstar10:
      mov star10, 639
      invoke DrawStar, star10, 353

    starcond11:
      invoke DrawStar, star10, 353
      mov eax, starspeed
      sub star11, eax
      cmp star11, 0
      jge starcond12

    resetstar11:
      mov star11, 639
      invoke DrawStar, star11, 316

    starcond12:
      invoke DrawStar, star11, 316
      mov eax, starspeed
      sub star12, eax
      cmp star12, 0
      jge starcond13

    resetstar12:
      mov star12, 639
      invoke DrawStar, star12, 188

    starcond13:
      invoke DrawStar, star12, 188
      mov eax, starspeed
      sub star13, eax
      cmp star13, 0
      jge starcond14

    resetstar13:
      mov star13, 639
      invoke DrawStar, star13, 450

    starcond14:
      invoke DrawStar, star13, 450
      mov eax, starspeed
      sub star14, eax
      cmp star14, 0
      jge starcond15

    resetstar14:
      mov star14, 639
      invoke DrawStar, star14, 228

    starcond15:
      invoke DrawStar, star14, 228
      mov eax, starspeed
      sub star15, eax
      cmp star15, 0
      jge starcond16

    resetstar15:
      mov star15, 639
      invoke DrawStar, star15, 391

    starcond16:
      invoke DrawStar, star15, 391
      mov eax, starspeed
      sub star16, eax
      cmp star16, 0
      jge poststar

    resetstar16:
      mov star16, 639
      invoke DrawStar, star16, 127

    poststar:
      invoke DrawStar, star16, 127

    drawvader:
      cmp vader.presence, 0
      je drawtie1
      invoke BasicBlit, OFFSET darthvader, vader.xcenter, vader.ycenter
      cmp enemiesleft, 1
      je vulnerable
      jmp drawtie1

    vulnerable:
      cmp specialtimer, 0
      je spawnescorts
      dec specialtimer
      jmp xwingcond

    spawnescorts:
      mov tie2.xcenter, 760
      mov tie2.ycenter, 280
      mov tie2.presence, 1
      mov tie2.moving, 0
      mov tie2.health, 40
      mov tie2.velocity, 10
      mov tie2.damage, 20
      mov tie2.laser, 0
      mov tie2col.dwLeft, 718
      mov tie2col.dwRight, 803
      mov tie2col.dwTop, 258
      mov tie2col.dwBottom, 302

      mov tie3.xcenter, 760
      mov tie3.ycenter, 200
      mov tie3.presence, 1
      mov tie3.moving, 0
      mov tie3.health, 40
      mov tie3.velocity, 10
      mov tie3.damage, 20
      mov tie3.laser, 0
      mov tie3col.dwLeft, 718
      mov tie3col.dwRight, 803
      mov tie3col.dwTop, 178
      mov tie3col.dwBottom, 222
      mov enemiesleft, 3
      mov specialtimer, 50
      jmp drawtie2

    drawtie1:
      cmp tie1.presence, 0
      je drawtie2
      invoke BasicBlit, tieptr, tie1.xcenter, tie1.ycenter

    drawtie2:
      cmp tie2.presence, 0
      je drawtie3
      invoke BasicBlit, tieptr, tie2.xcenter, tie2.ycenter

    drawtie3:
      cmp tie3.presence, 0
      je xwingcond
      invoke BasicBlit, tieptr, tie3.xcenter, tie3.ycenter

    xwingcond:
      cmp xwing.presence, 0
      je lasercond1
      invoke BasicBlit, xwingptr, xwing.xcenter, xwing.ycenter

    lasercond1:
      cmp xwing.laser1, 1
      je drawlaser1

    lasercond2:
      cmp xwing.laser2, 1
      je drawlaser2

    lasercond3:
      cmp xwing.laser3, 1
      je drawlaser3

    vaderlasercond:
      cmp vader.laser, 1
      je drawvaderlaser

    tie1lasercond:
      cmp tie1.laser, 1
      je drawtie1laser

    tie2lasercond:
      cmp tie2.laser, 1
      je drawtie2laser

    tie3lasercond:
      cmp tie3.laser, 1
      je drawtie3laser
      jmp Exit

    drawvaderlaser:
      invoke BasicBlit, OFFSET greenlaser, vader.laserx, vader.lasery
      jmp tie1lasercond

    drawtie3laser:
      invoke BasicBlit, OFFSET greenlaser, tie3.laserx, tie3.lasery
      jmp Exit

    drawtie1laser:
      invoke BasicBlit, OFFSET greenlaser, tie1.laserx, tie1.lasery
      jmp tie2lasercond

    drawtie2laser:
      invoke BasicBlit, OFFSET greenlaser, tie2.laserx, tie2.lasery
      jmp tie3lasercond     

    drawlaser3:
      invoke BasicBlit, xwinglaserptr, xwing.laserx3, xwing.lasery3
      jmp tie1lasercond

    drawlaser1:
      invoke BasicBlit, xwinglaserptr, xwing.laserx1, xwing.lasery1
      jmp lasercond2

    drawlaser2:
      invoke BasicBlit, xwinglaserptr, xwing.laserx2, xwing.lasery2
      jmp lasercond3
      
    collision1:
      mov xwing.health, 0
      mov tie1.health, 0
      mov tie1.presence, 0
      mov tie1col.dwLeft, 1000
      mov tie1col.dwRight, 1000
      mov tie1col.dwTop, 1000
      mov tie1col.dwBottom, 1000
      mov xwing.presence, 0
      mov xwingcol.dwLeft, 5000
      mov xwingcol.dwRight, 5000
      mov xwingcol.dwTop, 5000
      mov xwingcol.dwBottom, 5000
      invoke BasicBlit, OFFSET explosion, xwing.xcenter, xwing.ycenter
      invoke BasicBlit, OFFSET explosion, tie1.xcenter, tie1.ycenter
      jmp Exit

    collision2:
      mov xwing.health, 0
      mov tie2.health, 0
      mov tie2.presence, 0
      mov tie2col.dwLeft, 1000
      mov tie2col.dwRight, 1000
      mov tie2col.dwTop, 1000
      mov tie2col.dwBottom, 1000
      mov xwing.presence, 0
      mov xwingcol.dwLeft, 5000
      mov xwingcol.dwRight, 5000
      mov xwingcol.dwTop, 5000
      mov xwingcol.dwBottom, 5000
      invoke BasicBlit, OFFSET explosion, xwing.xcenter, xwing.ycenter
      invoke BasicBlit, OFFSET explosion, tie2.xcenter, tie2.ycenter
      jmp Exit

    collision3:
      mov xwing.health, 0
      mov tie3.health, 0
      mov tie3.presence, 0
      mov tie3col.dwLeft, 1000
      mov tie3col.dwRight, 1000
      mov tie3col.dwTop, 1000
      mov tie3col.dwBottom, 1000
      mov xwing.presence, 0
      mov xwingcol.dwLeft, 1000
      mov xwingcol.dwRight, 1000
      mov xwingcol.dwTop, 1000
      mov xwingcol.dwBottom, 1000
      invoke BasicBlit, OFFSET explosion, xwing.xcenter, xwing.ycenter
      invoke BasicBlit, OFFSET explosion, tie3.xcenter, tie3.ycenter
      jmp Exit

    xwinghitvader:
      mov vader.laser, 0
      mov vaderlasercol.dwLeft, 2000
      mov vaderlasercol.dwRight, 2000
      mov vaderlasercol.dwTop, 2000
      mov vaderlasercol.dwBottom, 2000
      mov vader.moving, 0
      mov eax, vader.damage
      sub xwing.health, eax
      cmp xwing.health, 0
      jle removexwing
      invoke BasicBlit, xwinghitptr, xwing.xcenter, xwing.ycenter
      jmp Exit

    xwinghit1:
      mov tie1.laser, 0
      mov tie1lasercol.dwLeft, 2000
      mov tie1lasercol.dwRight, 2000
      mov tie1lasercol.dwTop, 2000
      mov tie1lasercol.dwBottom, 2000
      mov tie1.moving, 0
      mov eax, tie1.damage
      sub xwing.health, eax
      cmp xwing.health, 0
      jle removexwing
      invoke BasicBlit, xwinghitptr, xwing.xcenter, xwing.ycenter
      jmp Exit

    xwinghit2:
      mov tie2.laser, 0
      mov tie2lasercol.dwLeft, 2000
      mov tie2lasercol.dwRight, 2000
      mov tie2lasercol.dwTop, 2000
      mov tie2lasercol.dwBottom, 2000
      mov tie2.moving, 0
      mov eax, tie2.damage
      sub xwing.health, eax
      cmp xwing.health, 0
      jle removexwing
      invoke BasicBlit, xwinghitptr, xwing.xcenter, xwing.ycenter
      jmp Exit

    xwinghit3:
      mov tie3.laser, 0
      mov tie3lasercol.dwLeft, 2000
      mov tie3lasercol.dwRight, 2000
      mov tie3lasercol.dwTop, 2000
      mov tie3lasercol.dwBottom, 2000
      mov tie3.moving, 0
      mov eax, tie3.damage
      sub xwing.health, eax
      cmp xwing.health, 0
      jle removexwing
      invoke BasicBlit, xwinghitptr, xwing.xcenter, xwing.ycenter
      jmp Exit

    hitvader1:
      mov xwing.laser1, 0
      mov laser1col.dwLeft, 2000
      mov laser1col.dwRight, 2000
      mov laser1col.dwTop, 2000
      mov laser1col.dwBottom, 2000
      mov eax, tie2.presence
      add eax, tie3.presence
      cmp eax, 0
      jne Exit
      mov eax, xwing.damage
      sub vader.health, eax
      cmp vader.health, 0
      jle removevader
      invoke BasicBlit, OFFSET darthvaderhit, vader.xcenter, vader.ycenter
      jmp Exit

    hitvader2:
      mov xwing.laser2, 0
      mov laser2col.dwLeft, 2000
      mov laser2col.dwRight, 2000
      mov laser2col.dwTop, 2000
      mov laser2col.dwBottom, 2000
      mov eax, tie2.presence
      add eax, tie3.presence
      cmp eax, 0
      jne Exit
      mov eax, xwing.damage
      sub vader.health, eax
      cmp vader.health, 0
      jle removevader
      invoke BasicBlit, OFFSET darthvaderhit, vader.xcenter, vader.ycenter
      jmp Exit

    hitvader3:
      mov xwing.laser3, 0
      mov laser3col.dwLeft, 2000
      mov laser3col.dwRight, 2000
      mov laser3col.dwTop, 2000
      mov laser3col.dwBottom, 2000
      mov eax, tie2.presence
      add eax, tie3.presence
      cmp eax, 0
      jne Exit
      mov eax, xwing.damage
      sub vader.health, eax
      cmp vader.health, 0
      jle removevader
      invoke BasicBlit, OFFSET darthvaderhit, vader.xcenter, vader.ycenter
      jmp Exit

    hit1tie1:
      mov xwing.laser1, 0
      mov laser1col.dwLeft, 2000
      mov laser1col.dwRight, 2000
      mov laser1col.dwTop, 2000
      mov laser1col.dwBottom, 2000
      mov eax, xwing.damage
      sub tie1.health, eax
      cmp tie1.health, 0
      jle removetie1
      invoke BasicBlit, tiehitptr, tie1.xcenter, tie1.ycenter
      jmp Exit

    hit2tie1:
      mov xwing.laser2, 0
      mov laser2col.dwLeft, 2000
      mov laser2col.dwRight, 2000
      mov laser2col.dwTop, 2000
      mov laser2col.dwBottom, 2000
      mov eax, xwing.damage
      sub tie1.health, eax
      cmp tie1.health, 0
      jle removetie1
      invoke BasicBlit, tiehitptr, tie1.xcenter, tie1.ycenter
      jmp Exit

    hit3tie1:
      mov xwing.laser3, 0
      mov laser3col.dwLeft, 2000
      mov laser3col.dwRight, 2000
      mov laser3col.dwTop, 2000
      mov laser3col.dwBottom, 2000
      mov eax, xwing.damage
      sub tie1.health, eax
      cmp tie1.health, 0
      jle removetie1
      invoke BasicBlit, tiehitptr, tie1.xcenter, tie1.ycenter
      jmp Exit

    hit1tie2:
      mov xwing.laser1, 0
      mov laser1col.dwLeft, 2000
      mov laser1col.dwRight, 2000
      mov laser1col.dwTop, 2000
      mov laser1col.dwBottom, 2000
      mov eax, xwing.damage
      sub tie2.health, eax
      cmp tie2.health, 0
      jle removetie2
      invoke BasicBlit, tiehitptr, tie2.xcenter, tie2.ycenter
      jmp Exit

    hit2tie2:
      mov xwing.laser2, 0
      mov laser2col.dwLeft, 2000
      mov laser2col.dwRight, 2000
      mov laser2col.dwTop, 2000
      mov laser2col.dwBottom, 2000
      mov eax, xwing.damage
      sub tie2.health, eax
      cmp tie2.health, 0
      jle removetie2
      invoke BasicBlit, tiehitptr, tie2.xcenter, tie2.ycenter
      jmp Exit

    hit3tie2:
      mov xwing.laser3, 0
      mov laser3col.dwLeft, 2000
      mov laser3col.dwRight, 2000
      mov laser3col.dwTop, 2000
      mov laser3col.dwBottom, 2000
      mov eax, xwing.damage
      sub tie2.health, eax
      cmp tie2.health, 0
      jle removetie2
      invoke BasicBlit, tiehitptr, tie2.xcenter, tie2.ycenter
      jmp Exit

    hit1tie3:
      mov xwing.laser1, 0
      mov laser1col.dwLeft, 2000
      mov laser1col.dwRight, 2000
      mov laser1col.dwTop, 2000
      mov laser1col.dwBottom, 2000
      mov eax, xwing.damage
      sub tie3.health, eax
      cmp tie3.health, 0
      jle removetie3
      invoke BasicBlit, tiehitptr, tie3.xcenter, tie3.ycenter
      jmp Exit

    hit2tie3:
      mov xwing.laser2, 0
      mov laser2col.dwLeft, 2000
      mov laser2col.dwRight, 2000
      mov laser2col.dwTop, 2000
      mov laser2col.dwBottom, 2000
      mov eax, xwing.damage
      sub tie3.health, eax
      cmp tie3.health, 0
      jle removetie3
      invoke BasicBlit, tiehitptr, tie3.xcenter, tie3.ycenter
      jmp Exit

    hit3tie3:
      mov xwing.laser3, 0
      mov laser3col.dwLeft, 2000
      mov laser3col.dwRight, 2000
      mov laser3col.dwTop, 2000
      mov laser3col.dwBottom, 2000
      mov eax, xwing.damage
      sub tie3.health, eax
      cmp tie3.health, 0
      jle removetie3
      invoke BasicBlit, tiehitptr, tie3.xcenter, tie3.ycenter
      jmp Exit

    removevader:
      mov vader.presence, 0
      mov darthvadercol.dwLeft, 1000
      mov darthvadercol.dwRight, 1000
      mov darthvadercol.dwTop, 1000
      mov darthvadercol.dwBottom, 1000
      invoke BasicBlit, OFFSET explosion, vader.xcenter, vader.ycenter
      jmp victory

    removetie1:
      mov tie1.presence, 0
      mov tie1col.dwLeft, 1000
      mov tie1col.dwRight, 1000
      mov tie1col.dwTop, 1000
      mov tie1col.dwBottom, 1000
      invoke BasicBlit, OFFSET explosion, tie1.xcenter, tie1.ycenter 
      dec enemiesleft
      cmp enemiesleft, 0
      je endwave
      jmp Exit

    removetie2:
      mov tie2.presence, 0
      mov tie2col.dwLeft, 1000
      mov tie2col.dwRight, 1000
      mov tie2col.dwTop, 1000
      mov tie2col.dwBottom, 1000
      invoke BasicBlit, OFFSET explosion, tie2.xcenter, tie2.ycenter
      dec enemiesleft
      cmp enemiesleft, 0
      je endwave
      jmp Exit

    removetie3:
      mov tie3.presence, 0
      mov tie3col.dwLeft, 1000
      mov tie3col.dwRight, 1000
      mov tie3col.dwTop, 1000
      mov tie3col.dwBottom, 1000
      invoke BasicBlit, OFFSET explosion, tie3.xcenter, tie3.ycenter
      dec enemiesleft
      cmp enemiesleft, 0
      je endwave
      jmp Exit  

    removexwing:
      mov xwing.presence, 0
      mov xwingcol.dwLeft, 5000
      mov xwingcol.dwRight, 5000
      mov xwingcol.dwTop, 5000
      mov xwingcol.dwBottom, 5000
      invoke BasicBlit, OFFSET explosion, xwing.xcenter, xwing.ycenter
      mov start, 5
      jmp Exit

    prepause:
      mov start, 3
      jmp Exit

    endwave:
      inc wave
      mov wavetimer, 21
      cmp wave, 6
      je bossintros
      cmp wave, 7
      je endlevel
      jmp Exit

    endlevel:
      mov wave, 1
      inc level
      mov start, 4
      mov randomtimer, 10
      mov wavetimer, 21
      cmp level, 2
      je level2prep
      jmp level3prep

    bossintros:
      cmp level, 3
      je darthvadersound
      jmp Exit

    darthvadersound:
      mov message, 1
      jmp Exit

    level2prep:
      mov tieptr, OFFSET tieinterceptor
      mov tiehitptr, OFFSET tieinterceptorhit
      mov tie1.presence, 0
      mov tie1col.dwLeft, 668
      mov tie1col.dwTop, 218
      mov tie1col.dwRight, 753
      mov tie1col.dwBottom, 262

      mov tie2.presence, 0
      mov tie2col.dwLeft, 718
      mov tie2col.dwRight, 803
      mov tie2col.dwTop, 258
      mov tie2col.dwBottom, 302

      mov tie3.presence, 0
      mov tie3col.dwLeft, 718
      mov tie3col.dwRight, 803
      mov tie3col.dwTop, 178
      mov tie3col.dwBottom, 222
      jmp Exit

    level3prep:
      mov tieptr, OFFSET tieinterceptor2
      mov tiehitptr, OFFSET tieinterceptor2hit
      jmp Exit

    victory:
      mov start, 6

    Exit:
	ret         ;; Do not delete this line!!!
GamePlay ENDP
	

END
