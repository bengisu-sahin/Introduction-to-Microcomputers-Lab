    ;152120191064 - BENGISU SAHIN
    ;152120201049 - MUHAMMET EREN SÖME
    
    LIST 	P=16F877A
    INCLUDE	P16F877.INC
    radix	dec
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF

; Static global variables
DATSEC1	udata
SSDCODES res 16

; Here is the number variable    
digit0	    EQU	    0x70
digit1	    EQU	    0x71
count	    EQU	    0x73		    
NO_ITERATIONS	   EQU	    0x72
	   
    ; Reset vector
    org	    0x00
    BSF	    STATUS, RP0		; Select Bank1
    CLRF    TRISA		; PortA --> Output
    CLRF    TRISD		; PortD --> Output
    BCF	    STATUS, RP0		; Select Bank0
    CLRF    PORTD		; PORTD = 0
    CLRF    PORTA		; Deselect all SSDs
    ;BSF	    PORTA, 4		;
    ;BSF	    PORTA, 5
    MOVLW   d'90'
    MOVWF   NO_ITERATIONS
    CLRF    digit0
    CLRF    digit1
    CALL    Init_SSDCODES
    
WHILE_LOOP  ;While(1)
    CLRF count
For_Loop_Begin ;(for (int i=0; i<NO_ITERATIONS; i++)
    MOVF NO_ITERATIONS,W
    SUBWF count ,W
    BTFSC STATUS,C
    GOTO  For_Loop_End
For_Loop_Body
    BSF	    PORTA, 5		
    BCF	    PORTA, 4		
    MOVF    digit0, W		
    CALL    GetCodeFromSSDCODES	   
    MOVWF   PORTD		
    CALL    Delay5ms		
    BCF	    PORTA, 5		
    BSF	    PORTA, 4		
    MOVF    digit1, W		
    CALL    GetCodeFromSSDCODES	    
    MOVWF   PORTD	
    CALL    Delay5ms		
    INCF    count, F		
    GOTO    For_Loop_Begin
For_Loop_End
IF_1	;if(digit0 == 10)
    INCF    digit0, F		
    MOVLW   d'10'		
    SUBWF   digit0, W		
    BTFSS   STATUS, Z		
    GOTO    IF_2
    CLRF    digit0		
    INCF    digit1, F
    GOTO    IF_2
IF_2	;if(digit1 == 2 && digit0 == 1)
    MOVLW   d'2'		; WREG = 2
    SUBWF   digit1,W		; WREG = digit1 - W
    BTFSS   STATUS,Z		; check if digit1 is 2, if its reset the counter
    GOTO    INFINITE_LOOP
    MOVLW   d'1'		; WREG = 1
    SUBWF   digit0,W		; WREG = digit0 - WREG
    BTFSS   STATUS,Z		; check if digit1 is 0, if its reset the counter
    GOTO    INFINITE_LOOP
    CLRF    digit0
    CLRF    digit1 
INFINITE_LOOP
    GOTO WHILE_LOOP
;------------------------------------------------------------------------------
; Get the code from the SSDCODES
;------------------------------------------------------------------------------
GetCodeFromSSDCODES
    MOVWF   FSR		; FSR = number
    MOVLW   SSDCODES	; WREG = &SSDCODES
    ADDWF   FSR, F	; FSR += &SSDCODES
    MOVF    INDF, W	; WREG = SSDCODES[number]
    RETURN    
 
;------------------------------------------------------------------------------
; Init_SSDCODES
;------------------------------------------------------------------------------
Init_SSDCODES
    MOVLW   B'00111111'		; 0
    MOVWF   SSDCODES		; SSDCODES[0] = WREG    
    MOVLW   B'00000110'		; 1
    MOVWF   SSDCODES+1		; SSDCODES[1] = WREG    
    MOVLW   B'01011011'		; 2
    MOVWF   SSDCODES+2		; SSDCODES[2] = WREG    
    MOVLW   B'01001111'		; 3
    MOVWF   SSDCODES+3		; SSDCODES[3] = WREG    
    MOVLW   B'01100110'		; 4
    MOVWF   SSDCODES+4		; SSDCODES[4] = WREG    
    MOVLW   B'01101101'		; 5
    MOVWF   SSDCODES+5		; SSDCODES[5] = WREG    
    MOVLW   B'01111101'		; 6
    MOVWF   SSDCODES+6		; SSDCODES[6] = WREG    
    MOVLW   B'00000111'		; 7
    MOVWF   SSDCODES+7		; SSDCODES[7] = WREG    
    MOVLW   B'01111111'		; 8
    MOVWF   SSDCODES+8		; SSDCODES[8] = WREG    
    MOVLW   B'01101111'		; 9
    MOVWF   SSDCODES+9		; SSDCODES[9] = WREG
   
    RETURN
    
;------------------------------------------------------------------------------
; Waste 5ms in a loop
;------------------------------------------------------------------------------    
Delay5ms
k	EQU	0x74
l	EQU	0x75

    MOVLW   d'5'
    MOVWF   k		; k = noIterations1
OuterLoop
    MOVLW   d'250'
    MOVWF   l		; l = noIterations2
InnerLoop
    NOP			; No operation	
    DECFSZ  l, F	; l--
    GOTO    InnerLoop
    DECFSZ  k, F	; k--
    GOTO    OuterLoop
    RETURN
    
    END