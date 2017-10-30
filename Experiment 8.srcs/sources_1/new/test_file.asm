;-------------------------------------------------------------
; This program tests many of the RAT instructions. This 
; program has so many issues that I'm not interested in 
; wasting my time writing about what it does. The program 
; basically turns on leds as it tests various instructions
; in the RAT instruction set. There are seven tests, each 
; test turns on a given number of LEDs (check the comments
; in each test for more details). 
; 
; The basic idea is that if an LED does not light up, then 
; there is a problem with that instruction and you can 
; "usually" go right there and fix it (but not always). 
; 
; Note that this program has two different delay functions: 
; "waitx" and "waitxx". The waitxx is never called as it is
; a short delay; waitx is a long delay. The long delay is 
; used when attempting to run the program on the dev board; 
; use the short delay when you're simulating the program 
; on the simulator. The easiest approach to swapping delay
; subroutines is to swap the names of the subroutines 
; themselves; don't try to change the names associated with 
; the arguments of the actuall CALL instructions. 
; 
; NOTE: Most of the debug problems associated with running
; this program in hardware as associated with the CALL and 
; RET instructions. The best way to tell is these instructions
; are working is to use the short delay and watch the program
; counter change as it call the initial set of subroutines. 
; There is initially a doubly-nested subroutine call; the 
; first thing you want to do is to verify that it properly 
; makes it back from that first set of nested CALLs. 

;-------------------------------------------------------------

;-------------------------------------------------------------
; Various Ports 
;-------------------------------------------------------------
.EQU LED_PORT = 0x40
.EQU SEGS     = 0x82
.EQU DISP_EN  = 0x83


;-------------------------------------------------------------
; Bit Location Constants 
;-------------------------------------------------------------
.EQU BIT0 = 0X01
.EQU BIT1 = 0X02
.EQU BIT2 = 0X04
.EQU BIT3 = 0X08
.EQU BIT4 = 0X10
.EQU BIT5 = 0X20
.EQU BIT6 = 0X40
.EQU BIT7 = 0X80


;-------------------------------------------------------------
; Segment Constants for Decimal Digits
;-------------------------------------------------------------
.EQU ZERO   = 0x03
.EQU ONE    = 0x9F
.EQU TWO    = 0x25
.EQU THREE  = 0x0D
.EQU FOUR   = 0x99
.EQU FIVE   = 0x49
.EQU SIX    = 0x41
.EQU SEVEN  = 0x1F
.EQU EIGHT  = 0x01
.EQU NINE   = 0x09



.CSEG
.ORG 0x01



           MOV   r0,ZERO       ; load digit value
           CALL  display_num   ; fancy but simple disply

;---------------------------------------------------------------
;---------------------------------------------------------------
Test1:
;---------------------------------------------------------------
;---------------------------------------------------------------
           MOV   r0,ONE        ; load digit value
           CALL  display_num   ; fancy but simple disply


init1:     MOV   r20,0x00
           MOV   r10,0x00
           MOV   r11,0x01
           MOV   r1,0x0F
           MOV   r2,0xAA

           ;-----------------
           ; bit0 test
           ;-----------------
           MOV   r3,r1
           AND   r3,r2
           CMP   r3,0x0A
           BRNE  endtest11
           OR    r20,BIT0
endtest11: OUT   r20,LED_PORT
           CALL  waitx
           ;-----------------
	

           ;-----------------
           ; bit1 test
           ;-----------------
           MOV   r4,r1
           OR    r4,r2
           CMP   r4,0XAF
           BRNE  endtest12
           OR    r20,BIT1
endtest12: OUT   r20,LED_PORT
           CALL  waitx
           ;-----------------


           ;-----------------
           ; bit2 test
           ;-----------------
           MOV   r5,r1
           EXOR  r5,r2
           CMP   r5,0XA5
           BRNE  endtest13
           OR    r20,BIT2
endtest13: OUT   r20,LED_PORT
           CALL  waitx
           ;-----------------
	

           ;-----------------
           ; bit3 test
           ;-----------------
           MOV   r6,r1
           CMP   r10,r1 
           LSL   r6
           CMP   r6,0x1F
           BRNE  endtest14
           OR    r20,BIT3
endtest14: OUT   r20,LED_PORT
           CALL  waitx
           ;-----------------


           ;-----------------
           ; bit4 test
           ;-----------------
           MOV   r7,r1
           CMP   r10,r11
           LSR   r7
           CMP   r7,0X87
           BRNE  endtest15
           OR    r20,BIT4
endtest15: OUT   r20,LED_PORT
           CALL  waitx
	

           ;-----------------
           ; Turn on remaining LEDs
           ;-----------------
           CALL  waitx
           OR    r20,0xE0
           OUT   r20,LED_PORT
           CALL  NextTest        ; generic delay
;---------------------------------------------------------------
;---------------------------------------------------------------






;---------------------------------------------------------------
;---------------------------------------------------------------
Test2:
;---------------------------------------------------------------
;---------------------------------------------------------------
           MOV   r0,TWO        ; load digit value
           CALL  display_num   ; fancy but simple display


init2:     MOV   R31,0x00


           ;-----------------
           ; Test2: bit0 test
           ;-----------------
           MOV   r10,0x35
           AND   r10,0xDB
           CMP   r10, 0x11
           BRNE  endtest21
           OR    r31,BIT0
endtest21: OUT   r31,LED_PORT
           CALL  Waitx
	

           ;-----------------
           ; Test2: bit1 test
           ;-----------------
           MOV   r10,0x55
           OR    r10,0xAA
           CMP   r10,0xFF
           BRNE  endtest22
           OR    r31,BIT1
endtest22: OUT   r31,LED_PORT ;pass OR
           CALL  Waitx

           ;-----------------
           ; Test2: bit2 test
           ;-----------------
           MOV   r10,0xAB
           EXOR  r10,0x54
           CMP   r10,0xFF
           BRNE  endtest23
           OR    r31,BIT2
endtest23: OUT   r31,LED_PORT ;pass XOR
           CALL  Waitx
	

           ;-----------------
           ; Test2: bit3 test
           ;-----------------
           MOV   r10,0x7F
           ROL   r10
           CMP   r10,0xFE
           BRNE  endtest24
           OR    r31,BIT3
endtest24: OUT   r31,LED_PORT ;pass ROL
           CALL  Waitx
	
           ;-----------------
           ; Test2: bit4 test
           ;-----------------
           MOV   r10,0xFE
           ROR   r10
           CMP   r10,0x7F
           BRNE  endtest25
           OR    r31,BIT4
endtest25: OUT   r31,LED_PORT ;pass ROR
           CALL  Waitx

           ;-----------------
           ; Test2: bit5 test
           ;-----------------
           MOV   r10,0xBE
           ASR   r10
           CMP   r10,0xDF
           BRNE  endtest26
           OR    r31,BIT5
endtest26: OUT   r31,LED_PORT ;pass ASR
           CALL  waitx


           ;-----------------
           ; Turn on remaining LEDs
           ;-----------------
           CALL  waitx
           OR    r31,0xC0
           OUT   r31,LED_PORT
           CALL  NextTest        ;  generic delay
;---------------------------------------------------------------
;---------------------------------------------------------------




;---------------------------------------------------------------
;---------------------------------------------------------------
Test3:
;---------------------------------------------------------------
;---------------------------------------------------------------
           MOV   r0,THREE      ; load digit value
           CALL  Display_num   ; fancy but simple display

init3:     MOV   r1,0x00

           ;-----------------
           ; Test3: bit0 test
           ;-----------------
test_30:   MOV   r4,0x77
           CMP   r4,0x77
           BRNE  end_t30
           OR    r1,BIT0
           OUT   r1,LED_PORT
end_t30:   CALL  Waitx
           

           ;-----------------
           ; Test3: bit1 test
           ;-----------------
test_31:   CMP   r4,0x66
           BREQ  end_t31
           OR    r1,BIT1
           OUT   r1,LED_PORT
end_t31:   CALL  Waitx


           ;-----------------
           ; Test3: bit2 test
           ;-----------------
test_32:   BRN   t_32
           MOV   r1,r1
           BRN   end_t32    
t_32:      OR    r1,BIT2
           OUT   r1,LED_PORT
end_t32:   CALL  Waitx


           ;-----------------
           ; Test3: bit3 test
           ;-----------------
test_33:   MOV   R4,0xFF
           ADD   R4,0x55
           BRCC  end_t33
           OR    r1,BIT3
           OUT   r1,LED_PORT
end_t33:   CALL  Waitx


           ;-----------------
           ; Test3: bit4 test
           ;-----------------
test_34:   MOV   r4,0x77
           ADD   r4,0x11
           BRCS  end_t34
           OR    r1,BIT4
           OUT   r1,LED_PORT
end_t34:   CALL  Waitx


           ;-----------------
           ; Test3: bit5 test
           ;-----------------
test_35:   MOV   r4,0x23
           ADD   r4,0xFF
           CLC
           BRCS  end_t35
           OR    r1,BIT5
           OUT   r1,LED_PORT
end_t35:   CALL  Waitx


           ;-----------------
           ; Test3: bit6 test
           ;-----------------	
test_36:   MOV   r4,0x55
           SUB   r4,0x11
           SEC
           BRCC  end_t36
           OR    r1,BIT6
           OUT   r1,LED_PORT
end_t36:   CALL  Waitx


           ;-----------------
           ; Turn on remaining LEDs
           ;-----------------
           CALL  Waitx
           OR    r1,BIT7
           OUT   r1,LED_PORT
           CALL  NextTest        ;  generic delay
;---------------------------------------------------------------
;---------------------------------------------------------------



;---------------------------------------------------------------
;---------------------------------------------------------------
Test4:
;---------------------------------------------------------------
;---------------------------------------------------------------
           MOV   r0,FOUR       ; load digit value
           CALL  Display_num   ; fancy but simple display


init4:     MOV   r31,0x00
           OUT   r31,LED_PORT

           ;-----------------
           ; Test4: bit0 test
           ;-----------------		
test_40:   MOV   r0,0x50
           PUSH  r0
           LD    r1,0xFF
           CMP   r1,0x50
           BRNE  end_t40
	       OR    r31,BIT0
           OUT   r31,LED_PORT
end_t40:   CALL  Waitx



           ;-----------------
           ; Test4: bit1 test
           ;-----------------		
test_41:   MOV   r1,0xD1
           WSP   r1
           MOV   r0,0x11
           PUSH  r0
           LD    r1,0xD0
           CMP   r1,0x11
           BRNE  end_t41
           OR    r31,BIT1
           OUT   r31,LED_PORT
end_t41:   CALL  Waitx


           ;-----------------
           ; Test4: bit2 test
           ;-----------------		
test_42:   MOV   r1,0xFF
           WSP   r1
           MOV   r0,0x22
           ST    r0,0xFF
           POP   r1
           CMP   r1,0x22
           BRNE  end_t42
           OR    r31,BIT2
           OUT   r31,led_port
end_t42:   CALL  Waitx


           ;-----------------
           ; Test4: bit3 test
           ;-----------------
test_43:   MOV   r1,0x00
           WSP   r1
           MOV   r0,0x42
           PUSH  r0
           POP   r1
           CMP   r1,0x42
           BRNE  end_t43
           OR    r31,BIT3
           OUT   r31,LED_PORT
end_t43:   CALL  Waitx


           ;-----------------
           ; Test4: bit4 test
           ;-----------------
test_44:   MOV   r0,0x11
           PUSH  r0
           MOV   r0,0x22
           PUSH  r0
           MOV   r0,0x33
           PUSH  r0
           MOV   r0,0x44
           PUSH  r0
           MOV   r0,0x55
           PUSH  r0
           POP   r1
           CMP   r1,0x55
           BRNE  end_t44
           POP   r1
           CMP   r1,0x44
           BRNE  end_t44
           POP   r1
           CMP   r1,0x33
           BRNE  end_t44
           POP   r1
           CMP   r1,0x22
           BRNE  end_t44
           POP   r1
           CMP   r1,0x11
           BRNE  end_t44
           OR    r31,BIT4
           OUT   r31,LED_PORT
end_t44:   CALL  Waitx


           ;-----------------
           ; Test4: bit5 test
           ;-----------------
test_45:   CALL  Test6Func
           CMP   r1,0x77
           BRNE  end_t45
           OR    r31,BIT5
           OUT   r31,LED_PORT
end_t45:   CALL  Waitx
	
	
	       ;-----------------
           ; Test4: bit6 test
           ;-----------------
test_46:   CALL  Test7Func
           CMP   r1,0x88
           BRNE  end_t46
           OR    r31,0x40
           OUT   r31,LED_PORT
end_t46:   CALL  Waitx

	       ;-----------------
           ; Test4: bit7 test
           ;-----------------
test_47:   CALL  Test8Func
           CMP   R0,0x59
           BRNE  end_t47
           OR    R31,BIT7
           OUT   R31,LED_PORT
end_t47:   CALL  Waitx


           CALL  Waitx
           CALL  NextTest
;---------------------------------------------------------------
;---------------------------------------------------------------


;---------------------------------------------------------------
;---------------------------------------------------------------
Test5:
;---------------------------------------------------------------
;---------------------------------------------------------------
           MOV   r0,FIVE       ; load digit value
           CALL  Display_num   ; fancy but simple display

init5:     MOV   R20,0x00

           ;-----------------
           ; Test5: bit0 test
           ;-----------------
test_50:   MOV   r10,0x01
           CMP   r10,0x01
           BRNE  end_t50
           OR    r20,BIT0
           OUT   r20,LED_PORT
end_t50:   CALL  Waitx


           ;-----------------
           ; Test5: bit1 test
           ;-----------------
test_51:   MOV   r11,r10
           CMP   r11,0x01
           BRNE  end_t51
           OR    r20,BIT1
           OUT   r20,LED_PORT
end_t51:   CALL  Waitx


           ;-----------------
           ; Test5: bit2 test
           ;-----------------
test_52:   ST    r10,(r11)		
           LD    r12,(r11)
           CMP   r12,0x01
           BRNE  end_t52
           OR    r20,BIT2
           OUT   r20,LED_PORT
end_t52:   CALL  Waitx

	
           ;-----------------
           ; Test5: bit3 test
           ;-----------------
test_53:   ST    r10,0x02
           MOV   r21,0x02
           LD    r13,(r21)
           CMP   r13,0x01
           BRNE  end_t53
           OR    r20,BIT3
           OUT   r20,LED_PORT
end_t53:   CALL  Waitx


           ;-----------------
           ; Test5: bit4 test
           ;-----------------
test_54:   MOV   r22,0x03
           ST    r10,(r22)		
           LD    r14,0x03		
           CMP   r14,0x01
           BRNE  end_t54
           OR    r20,BIT4
           OUT   r20,LED_PORT
end_t54:   CALL  Waitx


           ;-----------------
           ; Test5: bit5 test
           ;-----------------
test_55:   ST    r10,0x04
           LD    r15,0x04		
           CMP   r12,0x01
           BRNE  end_t55
           OR    r20,BIT5
           OUT   r20,LED_PORT
end_t55:   CALL  Waitx


           ;-----------------
           ; Turn on remaining LEDs
           ;-----------------
           CALL  Waitx
           OR    r20,0xC0
           OUT   r20,LED_PORT
           CALL  NextTest        ;  generic delay
;---------------------------------------------------------------
;---------------------------------------------------------------



;---------------------------------------------------------------
;---------------------------------------------------------------
Test6:
;---------------------------------------------------------------
;---------------------------------------------------------------
           MOV   r0,SIX        ; load digit value
           CALL  Display_num   ; fancy but simple display


           ;-----------------
           ; Test6: bit0 test
           ;-----------------
test_60:   MOV   r1,0x00        ; r1 holdz op completed status
           MOV   r4,0x00        ; r4 holdz the bit locator/updater
           OR    r4,0x01
           MOV   r2,0x01
           ADD   r2,0x02
           CMP   r2,0x03
           BRNE  end_t60        ; if correct, go to correct section
           OR    r1,r4          ; update the status bit -- this lights up led 1 only
end_t60:   OUT   r1,led_port
           CALL  Waitx

           ;-----------------
           ; Test6: bit1 test
           ;-----------------
test_61:   OR    R4,0x02        ; change the bit updater value so that the next bit will be updated
           SEC                  ; set carry to 1
           ADDC  R2,0x03
           CMP   R2,0x07
           BRNE  end_t61
           OR    R1, R4
end_t61:   OUT   R1, led_port
           CALL  Waitx

	
           ;-----------------
           ; Test6: bit2 test
           ;-----------------
test_62:   OR    r4,0x04
           SUB   r2,0x02
           CMP   r2,0x05
           BRNE  end_t62
           OR    r1,r4
end_t62:   OUT   r1,led_port
           CALL  Waitx


           ;-----------------
           ; Test6: bit3 test
           ;-----------------
test_63:   OR    r4,0x08
           SEC
           SUBC  r2,0x03
           CMP   r2,0x01
           BRNE  end_t63
           OR    r1,r4
end_t63:   OUT   r1,led_port
           CALL  Waitx


           ;-----------------
           ; Turn on remaining LEDs
           ;-----------------
           CALL  Waitx
           OR    r1,0xF0
           OUT   r1,LED_PORT
           CALL  NextTest        ;  generic delay
;---------------------------------------------------------------
;---------------------------------------------------------------


;---------------------------------------------------------------
;---------------------------------------------------------------
Test7:
;---------------------------------------------------------------
;---------------------------------------------------------------
           MOV   r0,SEVEN
           CALL  display_num


           ;-----------------
           ; Test7: bit0 test
           ;-----------------
test_70:   MOV   r10,0x05 
           MOV   r11,0x04
           ADD   r10,R11	 ;5+4=9
           MOV   r12,0x09
           CMP   r12,r10
           BRNE  end_t70
           OR    r15,BIT0
end_t70:   OUT   r15,led_port
           CALL  Waitx


           ;-----------------
           ; Test7: bit1 test
           ;-----------------
test_71:   SEC		            ;set carry to 1
           MOV   r10,0x05 
           MOV   r11,0x04
           ADDC  r10,r11        ;5+4+1=10
           MOV   r12,0x0A
           CMP   r12,r10
           BRNE  end_t71
           OR    r15,BIT1
end_t71:   OUT   r15,led_port
           CALL  Waitx	

	
           ;-----------------
           ; Test7: bit2 test
           ;-----------------
test_72:   MOV   r10,0x05
           MOV   r11,0x04
           SUB   r10,r11         ;5-4=1
           MOV   r12,0x01
           CMP   r12,r10
           BRNE  end_72
           OR    r15,BIT2
end_72:    OUT   r15,led_port
           CALL  Waitx

	
           ;-----------------
           ; Test7: bit3 test
           ;-----------------
test_73:   SEC
           MOV   r10,0x05
           MOV   r11,0x02
           SUBC  r10,r11        ;5-2-1 = 2
           MOV   r12,0x02
           CMP   r12,r10
           BRNE  end_t73
           OR    r15,BIT3
end_t73:   OUT   r15,led_port
           CALL  Waitx


           ;-----------------
           ; Turn on remaining LEDs
           ;-----------------
           CALL  Waitx
           OR    r15,0xF0
           OUT   r15,LED_PORT
           CALL  NextTest        ;  generic delay



;---------------------------------------------------------------
;---------------------------------------------------------------
           CALL  Waitx
           CALL  Waitx

           ;-- write all zeros to dispaly
           MOV   r0,ZERO
           OUT   r0,SEGS
           MOV   r0,0x00
           OUT   r0,DISP_EN    

;--------- wait indefinitely -----------------------------------
end:       BRN end 
;---------------------------------------------------------------
;---------------------------------------------------------------

;-- end of main program ----------------------------------------





;----------------------------------------------------------------
;----------------functions --------------------------------------
;----------------------------------------------------------------
Test6Func:  MOV R1, 0x77
            RET


Test7Func:  MOV R1, 0x30
            CALL test7Func2
            RET


Test7Func2: MOV R1, 0x88
            RET


Test8Func:  MOV R0, 0x01
            MOV R1, 0x01
            MOV R3, 0x0A
            CALL test8Func2
            RET


Test8Func2: ADD R0,R1
            MOV R4, R1
            MOV R1, R0
            MOV R0, R4
            SUB R3, 0x01
            BREQ endtest8Func2
            CALL test8Func2
endtest8Func2: RET


NextTest:   CALL waitx
            CALL waitx

            MOV R31, 0x00
            OUT R31, led_port

            CALL waitx
            RET
;----------------------------------------------------------------
;----------------------------------------------------------------
;----------------------------------------------------------------



;---------------------------------------------------------------
; waitxx:  Delay subroutine for testing. 
; 
; tweaked registers: none
;---------------------------------------------------------------
waitxx:   MOV   r23,r23
          RET
;---------------------------------------------------------------

;---------------------------------------------------------------
; waitx: Delay subroutine consisting of three loop, two 
;        of these loops are nested. 
; 
; tweaked registers: r27,r28,r29 
;---------------------------------------------------------------
waitx:    MOV   r29,0x5F   ;set outside loop count

loop1_s:  MOV   r28,0xFF   ;set middle loop count

loop0_s:  MOV   r27,0xFF   ;set inside loop count
loop0:    SUB   r27,0x01   ;decrement inside loop
          BRNE  loop0      ; branch if count not zero

          SUB   r28,0x01   ;decrement middle loop
          BRNE  loop0_s    ; branch if not zero
         
          SUB   r29,0x01   ;decrement outside loop
          BRNE  loop1_s    ; branch if not zero
        
          RET 
;---------------------------------------------------------

;---------------------------------------------------------
display_num: 
    OUT   r0,SEGS
    MOV   r0,0x0E
    OUT   r0,DISP_EN

    CALL  waitx
    MOV   r0,0x0C
    OUT   r0,DISP_EN
    CALL  waitx
    MOV   r0,0x08
    OUT   r0,DISP_EN
    CALL  waitx
    MOV   r0,0x00
    OUT   r0,DISP_EN
    CALL  waitx
    MOV   r0,0x08
    OUT   r0,DISP_EN
    CALL  waitx
    MOV   r0,0x0C
    OUT   r0,DISP_EN
    CALL  waitx
    MOV   r0,0x0E
    OUT   r0,DISP_EN
    CALL  waitx

    RET 
;------------------------------------------------------------

