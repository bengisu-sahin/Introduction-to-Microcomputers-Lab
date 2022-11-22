    ;152120191064   BENGISU SAHIN
    ;152120201049   MUHAMMET EREN SÖME
    LIST 	P=16F877
    INCLUDE	P16F877.INC
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF 
    radix	dec
    
    ; Reset vector
    org 0x00
    ; ---------- Initialization ---------------------------------
    BSF     STATUS, RP0	; Select Bank1
    CLRF    TRISB	; Set all pins of PORTB as output
    CLRF    TRISD	; Set all pins of PORTD as output
    BCF     STATUS, RP0	; Select Bank0    
    CLRF    PORTB	; Turn off all LEDs connected to PORTB
    CLRF    PORTD	; Turn off all LEDs connected to PORTD
    
    count EQU 0x20
    MOVE_LEFT EQU 0x73
    MOVE_RIGHT EQU 0x74
    val EQU 0x75
    dir EQU 0x76
    ; ---------- Your code starts here --------------------------
    MOVLW d'0'
    MOVWF MOVE_LEFT
    MOVLW d'1'
    MOVWF MOVE_RIGHT
    CLRF count	;count = 0
    MOVLW 0x1	;Wreg = 1
    MOVWF val
    While_Loop
	MOVF val,W
	MOVWF PORTD ;portd = 1
	CALL Delay
	INCF count,F
	
	MOVLW d'15'
	SUBWF count,W
	BTFSS STATUS,Z	;Skip if zero bit is set.
	GOTO ELSE_BLOCK ;x!=15
	GOTO IF_BLOCK	;x==15
	
    
    
    
    ; ---------- Your code ends here ----------------------------    
    MOVWF   PORTD    	; Send the result stored in WREG to PORTD to display it on the LEDs
    
LOOP    GOTO    $	; Infinite loop

    
IF_BLOCK
    CLRF PORTD
    CALL Delay
    MOVLW 0xFF
    MOVWF PORTD
    CALL Delay
    CLRF PORTD
    CALL Delay
    MOVLW 0xFF
    MOVWF PORTD
    CALL Delay
    CLRF PORTD
    CALL Delay
    MOVLW 0x1
    MOVWF val
    CLRF count
    MOVF MOVE_LEFT,W
    MOVWF dir
    GOTO While_Loop
    
ELSE_BLOCK 
    ;if val = 0x80?
    MOVLW 0x80
    SUBWF val,W
    BTFSC STATUS,Z
    CALL INNER_IF_1 ; val = 0x80
    
    MOVLW d'0'
    SUBWF dir,W
    BTFSS STATUS,Z
    CALL INNER_ELSE
    CALL INNER_IF_2
    
INNER_IF_1
    MOVF MOVE_RIGHT,W
    MOVWF dir
    RETURN
INNER_IF_2
    MOVLW d'0'
    SUBWF dir,W
    BTFSS STATUS,Z
    GOTO INNER_ELSE
    BCF STATUS,C
    RLF val,F
    GOTO While_Loop
INNER_ELSE
    BCF STATUS,C
    RRF val,F
    GOTO While_Loop
Delay:
    CALL Delay250ms
    ;CALL Delay500ms
    RETURN
    
Delay250ms:
i	EQU	    0x70		    ; Use memory slot 0x70
j	EQU	    0x71		    ; Use memory slot 0x71
	MOVLW	    d'250'		    ; 
	MOVWF	    i			    ; i = 250
Delay250ms_OuterLoop
	MOVLW	    d'250'
	MOVWF	    j			    ; j = 250
Delay250ms_InnerLoop	
	NOP
	DECFSZ	    j, F		    ; j--
	GOTO	    Delay250ms_InnerLoop

	DECFSZ	    i, F		    ; i?
	GOTO	    Delay250ms_OuterLoop    
	RETURN

Delay500ms:
i	EQU	    0x70
j	EQU	    0x71
k	EQU	    0x72
	MOVLW	    d'2'
	MOVWF	    i			    ; i = 2
Delay500ms_Loop1_Begin
	MOVLW	    d'250'
	MOVWF	    j			    ; j = 250
Delay500ms_Loop2_Begin	
	MOVLW	    d'250'
	MOVWF	    k			    ; k = 250
Delay500ms_Loop3_Begin	
	NOP				    ; Do nothing
	DECFSZ	    k, F		    ; k--
	GOTO	    Delay500ms_Loop3_Begin

	DECFSZ	    j, F		    ; j--
	GOTO	    Delay500ms_Loop2_Begin

	DECFSZ	    i, F		    ; i?
	GOTO	    Delay500ms_Loop1_Begin    
	RETURN

    END