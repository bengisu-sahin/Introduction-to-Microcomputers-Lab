	;152120191064 BENGISU SAHIN
	;152120201049 MUHAMMET EREN SÖME	
	LIST 	P=16F877A
	INCLUDE	P16F877.INC
	__CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF
	radix	dec

x EQU 0x20
y EQU 0x21
box EQU 0x22
temp EQU 0x23

	; Reset vector
	org 0x00
    ; ---------- Initialization ---------------------------------
    BSF     STATUS, RP0	; Select Bank1
    CLRF    TRISB	; Set all pins of PORTB as output
    CLRF    TRISD	; Set all pins of PORTD as output
    BCF     STATUS, RP0	; Select Bank0    
    CLRF    PORTB	; Turn off all LEDs connected to PORTB
    CLRF    PORTD	; Turn off all LEDs connected to PORTD
    
    ; ---------- Your code starts here --------------------------
    MOVLW d'5'  ;wreg = 5
    MOVWF x	;x = wreg(5)
    
    MOVLW d'6'	;wreg = 6
    MOVWF y	;y = wreg(6)
    
    GOTO COND_1
    
COND_1 ;if(x<0)
    BTFSS x,7 ; if c=1 then x is negative
    GOTO COND_2
    GOTO FALL
    
FALL ;box = -1
	MOVLW -d'1'
	MOVWF box
	GOTO PORTD_DISPLAY
    
COND_2 ;if(x>11)
	MOVLW d'11' ;WREG = 11
	MOVWF temp ;temp = 10
	MOVF x,W    ;wreg = y
	SUBWF temp,W ;wreg = temp - y
	BTFSC STATUS,C ;CARRY = 1 IF Y>10  Y<=10
	GOTO COND_3
	GOTO FALL    
    
COND_3 ;if(y<0)
	BTFSS y,7
	GOTO COND_4
	GOTO FALL
   
COND_4 ;if(y>10)
	MOVLW d'10' ;WREG =10
	MOVWF temp ;temp = 10
	MOVF y,W    ;wreg = y
	SUBWF temp,W ;wreg = temp - y
	BTFSC STATUS,C ;CARRY = 1 IF Y>10  Y<=10
	GOTO ELSE_IF_1
	GOTO FALL
    
ELSE_IF_1 ;if(x<=3)
	MOVLW d'3' ; W = 3
	MOVWF temp
	MOVF x,W
	SUBWF temp,W
	BTFSS STATUS,C
	GOTO ELSE_IF_2
	GOTO INNER_IF_1
	
INNER_IF_1 ;if(y<=1)
	MOVLW d'1'
	MOVWF temp
	MOVF y,W
	SUBWF temp,W
	BTFSS STATUS,C
	GOTO INNER_ELIF_1
	MOVLW d'3'
	MOVWF box
	GOTO PORTD_DISPLAY

INNER_ELIF_1 ;if(y<=4)
	MOVLW d'4'
	MOVWF temp
	MOVF y,W    ;wreg = y
	SUBWF temp,W
	BTFSS STATUS,C 
	GOTO INNER_ELSE_1
	MOVLW d'2'
	MOVWF box   ;box = Wreg
	GOTO PORTD_DISPLAY
	
INNER_ELSE_1
	MOVLW d'1'
	MOVWF box
	GOTO PORTD_DISPLAY

ELSE_IF_2 ;if(x<=7)
	MOVLW d'7'
	MOVWF temp
	MOVF x,W
	SUBWF temp,W
	BTFSS STATUS,C
	GOTO OUTTER_ELSE
	GOTO INNER_IF_2
	
INNER_IF_2 ;if(y<=5)
	MOVLW d'5'
	MOVWF temp
	MOVF y,W
	SUBWF temp,W
	BTFSS STATUS,C
	GOTO INNER_ELSE_2
	MOVLW d'5'
	MOVWF box
	GOTO PORTD_DISPLAY

INNER_ELSE_2
	MOVLW d'4'
	MOVWF box
	GOTO PORTD_DISPLAY
	
OUTTER_ELSE 
	MOVLW d'2'
	MOVWF temp
	MOVF y,W
	SUBWF temp,W
	BTFSS STATUS,C
	GOTO INNER_ELIF_2
	MOVLW d'9'
	MOVWF box
	GOTO PORTD_DISPLAY

INNER_ELIF_2
	MOVLW d'6'
	MOVWF temp
	MOVF y,W
	SUBWF temp,W
	BTFSS STATUS,C
	GOTO INNER_ELIF_3
	MOVLW d'8'
	MOVWF box
	GOTO PORTD_DISPLAY

INNER_ELIF_3
	MOVLW d'8'
	MOVWF temp
	MOVF y,W
	SUBWF temp,W
	BTFSS STATUS,C
	GOTO INNER_ELSE_3
	MOVLW d'7'
	MOVWF box
	GOTO PORTD_DISPLAY
	
INNER_ELSE_3
	MOVLW d'6'
	MOVWF box
	GOTO PORTD_DISPLAY
	
PORTD_DISPLAY
	MOVF box,W ;WREG = box
    
    ; ---------- Your code ends here ----------------------------    
    MOVWF   PORTD    	; Send the result stored in WREG to PORTD to display it on the LEDs
    
LOOP    GOTO    $	; Infinite loop
    END


