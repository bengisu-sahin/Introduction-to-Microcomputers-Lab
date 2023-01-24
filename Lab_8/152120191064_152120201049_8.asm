    ;152120191064 BENGISU SAHIN
    ;152120201049 MUHAMMET EREN SÖME
    LIST 	P=16F877A
    INCLUDE	P16F877.INC
    radix	dec
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF    
    ;reset vector
    org 0x0
    counter EQU 0x20
 
main
    ;setup
    BSF STATUS, RP0 ; SELECT BANK1 
    MOVLW 0xFF
    MOVWF TRISB	    ; TRISB = 0xFF. All PORTB pins: Input  
    CLRF TRISD	    ; ALL PORTD pins: Output
    CLRF TRISA	    ; ALL PORTA: Output
  
    BCF STATUS, RP0 ; SELECT BANK0
    CLRF PORTD	    ; Turn off all LEDs
    CLRF PORTA	    
    BSF PORTA, 5    ; Select SSD DISP4
    
    CLRF counter    ; Counter = 0
        
WHILE_LOOP		;Infinite While(1) Loop    
    GOTO IF_1

IF_1			;if (button3 == pressed) increment button
    BTFSS PORTB, 3	
    GOTO BTN3_PRESSED
    GOTO IF_2
IF_2			;if (button4 == pressed) decrement button
    BTFSS PORTB, 4	
    GOTO BTN4_PRESSED
    GOTO IF_3
IF_3			;if (button5 == pressed) reset button
    BTFSS PORTB, 5	
    GOTO BTN5_PRESSED 
    GOTO DISPLAY_SSD

BTN3_PRESSED
    MOVLW d'9'
    SUBWF counter, W	;W = counter - 9(W)
    BTFSS STATUS, Z	;if(counter==9) then counter = 0
    GOTO C_NOT_EQU_9	;else
    CLRF counter	;counter = 0
    GOTO DISPLAY_SSD
    
BTN4_PRESSED		;if (button4 == pressed) decrement button
    MOVF counter, W	;Check if counter equals zero.
    BTFSS STATUS, Z	;if(counter == 0) then counter = 9
    GOTO C_NOT_EQU_0	;else 
    MOVLW d'9'
    MOVWF counter	;Counter = 9(W)
    GOTO DISPLAY_SSD
    
BTN5_PRESSED		;if (button5 == pressed) reset button
    CLRF counter	;counter = 0
    GOTO DISPLAY_SSD
           
C_NOT_EQU_9
    INCF counter, F	;counter++
    GOTO DISPLAY_SSD
C_NOT_EQU_0
    DECF counter, F	;counter--
    GOTO DISPLAY_SSD
       
DISPLAY_SSD	
    MOVF    counter, W	;W = counter
    CALL    GetCode	
    MOVWF   PORTD	;PORTD = counter
    CALL Delay100ms
    GOTO WHILE_LOOP  
    
GetCode
    ADDWF   PCL, F		
    RETLW   B'00111111'		
    RETLW   B'00000110'		
    RETLW   B'01011011'		
    RETLW   B'01001111'		
    RETLW   B'01100110'		
    RETLW   B'01101101'		
    RETLW   B'01111101'		
    RETLW   B'00000111'		
    RETLW   B'01111111'		
    RETLW   B'01101111'	    
;------------------------------------------------------------------------------
; Waste 100ms in a loop
;------------------------------------------------------------------------------
Delay100ms:
i	EQU	    0x70		    ; Use memory slot 0x70
j	EQU	    0x71		    ; Use memory slot 0x71
	MOVLW	    d'100'		    ; 
	MOVWF	    i			    ; i = 100
Delay100ms_OuterLoop
	MOVLW	    d'250'
	MOVWF	    j			    ; j = 250
Delay100ms_InnerLoop	
	NOP
	DECFSZ	    j, F		    ; j--
	GOTO	    Delay100ms_InnerLoop

	DECFSZ	    i, F		    ; i?
	GOTO	    Delay100ms_OuterLoop    
	RETURN
LOOP GOTO $	
    END