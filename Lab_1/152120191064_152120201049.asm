	;152120191064 BENG?SU ?AH?N
	;152120201049 MUHAMMET EREN SÖME	
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
z EQU 0x22
r1 EQU 0x23
r2 EQU 0x24
r3 EQU 0x25
r4 EQU 0x26
tmp1 EQU 0x27
tmp2 EQU 0x28
r EQU  0x29
 
    ;assign x,y,z values
    MOVLW d'5' ;WREG=5
    MOVWF x ;x=5
    MOVLW d'6' 
    MOVWF y
    MOVLW d'7' 
    MOVWF z
    
    ;--------------------------------------
    ;    r1 = (5 * x - 2 * y + z - 3);
    ;--------------------------------------
    
    ;5*x
    MOVF x,W ;WREG=x
    ADDWF x,W ;WREG=WREG+x
    ADDWF x,W ;WREG=WREG+x
    ADDWF x,W ;WREG=WREG+x
    ADDWF x,W ;WREG=WREG+x
    MOVWF tmp1 ;tmp1=WREG
    
    ;2*Y
    MOVF y,W ;WREG=Y
    ADDWF y,W ;WREG=2*Y
    
    ;5X-2Y
    SUBWF tmp1,F ;tmp1=tmp1-WREG --> 5x-2y
    ;move 3
    MOVLW d'3' ;W=3
    ;5X-2Y-3
    SUBWF tmp1,W
    ;5 * x - 2 * y + z - 3
    ADDWF z,W 
    ;MOVE r1
    MOVWF r1 
    
    ;--------------------------------------
    ;       r2 = (x + 5) * 4 - 3 * y + z;
    ;--------------------------------------
    
    ;(x+5)*4
    MOVF x,W ;WREG=x
    ADDLW d'5' ;WREG=WREG+5
    MOVWF tmp1 ;tmp1=WREG
    ADDWF tmp1,W ;1th
    ADDWF tmp1,W ;2th
    ADDWF tmp1,W ;3th
    MOVWF tmp1 ;tmp1=WREG
    
    ;(x + 5) * 4 - 3 * y
    MOVF y,W ;WREG=y
    ADDWF y,W ;wreg=Y+Y
    ADDWF y,W ;WREG= y+y+y
    SUBWF tmp1,W ; WREG=tmp1-WREG
    
    ;(x + 5) * 4 - 3 * y + z;
    ADDWF z,W ;WREG=WREG+z
    MOVWF r2 ;r2=WREG
    
    ;--------------------------------------
    ;           r3 = x / 2 + y / 2 + z / 4
    ;--------------------------------------
    BCF   STATUS, C	;Clear the carry bit in STATUS register
    RRF   x, W		;W = x/2
    MOVWF tmp1		;tmp1=x/2
    
    BCF STATUS , C  ;Clear the carry bit 
    RRF y,W	    ;W=y/2
    ADDWF tmp1,F    ;tmp1=WREG+tmp1=x/2+y/2
    
    MOVF z,W
    MOVWF tmp2
    BCF STATUS , C
    RRF tmp2,F	    ;tmp2=z/2
    BCF STATUS , C
    RRF tmp2,F		   ;tmp2=Z/2 * 1/2
    MOVF tmp2,W
    ADDWF tmp1,W   ;WREG=x / 2 + y / 2 + z / 4
    MOVWF r3       ;r3=x / 2 + y / 2 + z / 4
    
    ;--------------------------------------
    ;           r4 = (3 * x - y - 3 * z) * 2 - 30
    ;--------------------------------------
    MOVF x,W ;WREG=x
    ADDWF x,W ;WREG=x+x
    ADDWF x,W ;WREG=x+x+x
    MOVWF tmp1 ;tmp1=WREG=3*x
    
    MOVF y,W  ;WREG=Y
    SUBWF tmp1,F ;tmp1=3*x - y
    
    MOVF z,W ;WREG=z
    ADDWF z,W ;WREG=z+z
    ADDWF z,W ;WREG=3*z
    
    SUBWF tmp1,F ;tmp1=3*x - y -3*z
    MOVF tmp1,W ;WREG=tmp1
    ADDWF tmp1,F ;tmp1=2*tmp1=(3 * x - y - 3 * z) * 2
    
    MOVLW d'30' ;WREG=30
    SUBWF tmp1,W ;WREG=tmp1-30
    
    MOVWF r4 ;r4=WREG
    
    ;---------------------------------------------
    ;          r = 3 * r1 + 2 * r2 - r3 / 2 - r4
    ;---------------------------------------------
    
    MOVF r1,W ;Wreg=r1
    ADDWF r1,W ;WREG=r1+r1
    ADDWF r1,W ;WREG=r1+r1+r1
    MOVWF tmp1 ;tmp1=WREG
    
    MOVF r2,W ;WREG=r2
    ADDWF r2,W ;WREG=r2+r2
    ADDWF tmp1,F ;tmp1=WREG=3 * r1 + 2 * r2
    
    MOVF r3,W
    BCF STATUS , C ;set carry bit 0
    RRF r3,W ;WREG=r3/2
    
    SUBWF tmp1,F ;tmp1=tmp1 - WREG = 3 * r1 + 2 * r2 - r3 / 2
    
    MOVF r4,W 
    SUBWF tmp1,W ;WREG=3 * r1 + 2 * r2 - r3 / 2 - r4
    
    MOVWF r ;r=WREG
    
    MOVWF PORTD 
    
LOOP	GOTO $		; Infinite loop

    END			; End of the program