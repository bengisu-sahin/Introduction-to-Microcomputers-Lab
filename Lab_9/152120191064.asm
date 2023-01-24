	LIST 	P=16F877A
	INCLUDE	P16F877.INC
	radix	dec
	__CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF

    org 0x00
        ; ---------- Initialization ---------------------------------
    BSF     STATUS, RP0	; Select Bank1
    CLRF    TRISB	; Set all pins of PORTB as output
    CLRF    TRISD	; Set all pins of PORTD as output
    BCF     STATUS, RP0	; Select Bank0    
    CLRF    PORTB	; Turn off all LEDs connected to PORTB
    CLRF    PORTD	; Turn off all LEDs connected to PORTD
    
x EQU 0x20
y EQU 0x21
tmp EQU 0x22
 
    MOVLW d'20' ;WREG=5
    MOVWF x ;x=5
    MOVLW d'24' 
    MOVWF y
    
    ;tmp=x
    MOVF x,W
    MOVWF tmp
    ;x/4
    BCF STATUS,C 
    RRF x,F ;x/2
    BCF STATUS,C 
    RRF x,F ;x/4
    MOVF x,W
    
    ;y/8
    BCF STATUS,C 
    RRF y,F ;y/2
    BCF STATUS,C 
    RRF y,F ;y/4
    BCF STATUS,C 
    RRF y,F ;y/8
    MOVF y,W
    
    MOVF tmp,W ;WREG=tmp
    ADDWF tmp,F ;tmp=tmp+tmp
    ADDWF tmp,F ;tmp=tmp+tmp+tmp=3*tmp=3*x
    MOVLW d'3'
    ADDWF tmp,F ;tmp=tmp)+3(3x)+3
    
    MOVF y,W ;WREG=y=y/8
    SUBWF x,W ;WREG=x-y=x/4 - y/8
    ADDWF tmp,W ;WREG=x/4 - y/8+(3+x*3)
    
    MOVWF PORTD
    
 LOOP	GOTO $		; Infinite loop

    END			; End of the program


