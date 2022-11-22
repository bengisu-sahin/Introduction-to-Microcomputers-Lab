    ;152120191064 BENGISU SAHIN
    ;152120201049 MUHAMMET EREN SOME	
    LIST 	P=16F877A
    INCLUDE	P16F877.INC
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF
    radix	dec

zib0 EQU 0x20
zib1 EQU 0x21
zib EQU 0x22
i EQU 0x23
N EQU 0x24
tmp1 EQU 0x25
var2 EQU 0x26

    ; Reset vector
	org 0x00
    ; ---------- Initialization ---------------------------------
    BSF     STATUS, RP0	; Select Bank1
    MOVLW   0xff	; W=0xff
    MOVWF   TRISB	; Set all pins of PORTB as input?
    CLRF    TRISD	; Set all pins of PORTD as output
    BCF     STATUS, RP0	; Select Bank0    
    ;CLRF    PORTB	; Turn off all LEDs connected to PORTB
    CLRF    PORTD	; Turn off all LEDs connected to PORTD
    
; ---------- Your code starts here --------------------------
main
;--------------PART 1 - VARIABLES ASSIGNMENT-----------
    MOVLW d'1' ;WREG=1
    MOVWF zib0 ;zib0=1
    MOVLW d'2' ;WREG=2
    MOVWF zib1 ;zib1=2
    MOVLW d'2' ;WREG=2
    MOVWF i ;i=2
    MOVLW d'13' ;WREG=13
    MOVWF N ;N=13
    ;-----------PART 2 - LOOP--------------
LOOP_BEGIN
    MOVF i,W ;WREG=i
    SUBWF N,W ;WREG=N-i
    BTFSS STATUS,C ;If C=1 i<=N 
    GOTO LOOP_END	
LOOP_BODY
    MOVLW d'63' ;WREG=63=0x3f
    ANDWF zib1,W ;WREG=(zib1 & 0x3f)
    MOVWF tmp1 ;tmp1=WREG=(zib1 & 0x3f)
    MOVLW d'5' ;WREG=5=0x05
    IORWF zib0,W ;WREG=(zib0 | 0x05)
    ADDWF tmp1,W ;WREG=(zib1 & 0x3f) + (zib0 | 0x05)
    MOVWF zib ;zib=WREG=(zib1 & 0x3f) + (zib0 | 0x05)
    INCF i,F    ;i++
    MOVF zib1,W ;Wreg = zib1
    MOVWF zib0  ;zib0 = zib1
    MOVF zib,W  ;wreg = zib
    MOVWF zib1  ;zib1 = zib
    MOVF zib,W ;WREG = box
    MOVWF PORTD
    CALL Delay250ms
	;;
INNER_WHILE
    BTFSC PORTB,3 ;1 ise while içinde 0 ise Loop_begine git
    GOTO INNER_WHILE
    GOTO LOOP_BEGIN
LOOP_END
    GOTO LOOP
    
;------------------------------------------------------------------------------
; Waste 250ms in a loop
;------------------------------------------------------------------------------
Delay250ms
k	EQU	    0x70		    ; Use memory slot 0x70
j	EQU	    0x71		    ; Use memory slot 0x71
	MOVLW	    d'250'		    ; 
	MOVWF	    k			    ; i = 250
Delay250ms_OuterLoop
	MOVLW	    d'250'
	MOVWF	    j			    ; j = 250
Delay250ms_InnerLoop	
	NOP
	DECFSZ	    j, F		    ; j--
	GOTO	    Delay250ms_InnerLoop

	DECFSZ	    k, F		    ; i?
	GOTO	    Delay250ms_OuterLoop    
	RETURN
; ---------- Your code ends here ----------------------------    
    LOOP    GOTO    $	; Infinite loop
	END