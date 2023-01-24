    LIST 	P=16F877A
    INCLUDE	P16F877.INC
    radix	dec
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF

; Static global variables
DATSEC1	udata
SSDCODES res 16
digit0	    EQU	    0x70
digit1	    EQU	    0x71
count	    EQU	    0x73		    
NO_ITERATIONS	   EQU	    0x72
control	    EQU	    0x74	   
    ; Reset vector
    org	    0x00
    GOTO MAIN
    ;;-----------------------------------------LAB07------------------------------------------------------------------------;;
    ;------------------------------------MUHAMMET EREN SÖME 152120201049----------------------------------------------------;;
    ;------------------------------------BENGISU SAHIN 152120191064---------------------------------------------------------;;
    #include <Delay.inc>	; Delay library (Copy the contents here)
    #include <LcdLib.inc>	; LcdLib.inc (LCD) utility routines
MAIN   
    BANKSEL TRISA
    CLRF    TRISA		; PortA --> Output
    BANKSEL TRISD
    CLRF    TRISD		; PortD --> Output
    BANKSEL PORTD
    CLRF    PORTD		; PORTD = 0
    CLRF	PORTA		; Deselect All SSDs
    BSF     STATUS, RP0
	
    MOVLW	0x0
    MOVWF	TRISD
    MOVWF	TRISE
    MOVLW	0x03		; Choose RA0 analog input and RA3 reference input
    MOVWF	ADCON1		; Register to configure PORTA's pins as analog/digital <11> means, all but one are analog
	
    BCF	STATUS, RP0	; Select Bank0
    CALL	LCD_Initialize	; Initialize the LCD    
	
    ;ASSIGNMENTS
    CLRF digit0
    CLRF digit1
    CLRF control
    MOVLW d'90'
    MOVWF NO_ITERATIONS
    CALL Init_SSDCODES
	
WHILE_LOOP  ;While(1)
    CLRF count ;count=0
    CALL DISPLAY_MESSAGE_1 
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
    INCF    digit0, F
IF_1	;if(digit0 == 10)	
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
    CLRF    digit0   ;digit0=0
    CLRF    digit1 ;digit1=0
    MOVLW   d'1'
    MOVWF   control 
INFINITE_LOOP
    GOTO WHILE_LOOP	
    
DISPLAY_MESSAGE_1		;Display counter value on LCD   
    CALL LCD_Clear
    MOVLW 'C'
    CALL LCD_Send_Char
    MOVLW 'o'
    CALL LCD_Send_Char
    MOVLW 'u'
    CALL LCD_Send_Char
    MOVLW 'n'
    CALL LCD_Send_Char
    MOVLW 't'
    CALL LCD_Send_Char
    MOVLW 'e'
    CALL LCD_Send_Char
    MOVLW 'r'
    CALL LCD_Send_Char
    CALL Display_Space
    CALL LCD_Send_Char
    MOVLW 'V'
    CALL LCD_Send_Char
    MOVLW 'a'
    CALL LCD_Send_Char
    MOVLW 'l'
    CALL LCD_Send_Char
    MOVLW ':'
    CALL LCD_Send_Char
    

    MOVF	digit1, W ; WREG == digit
    ADDLW	'0'	    ;WREG=digit1 + 0 
    CALL	LCD_Send_Char	
    
    MOVF	digit0, W   ; WREG == digit
    ADDLW	'0'	    ; WREG=digit0 + 0  
    CALL	LCD_Send_Char
    CALL	LCD_MoveCursor2SecondLine
    MOVLW	d'0'
    SUBWF	control,W   ;if (control==0)
    BTFSS	STATUS,Z
    GOTO	DISPLAY_MESSAGE_ROLLING_UP ;ROLL MESSAGE
    CALL	COUNTING_UP_MESSAGE ;Counting message
    GOTO	For_Loop_Body
    RETURN
Display_Space
    MOVLW ' '
    RETURN
COUNTING_UP_MESSAGE ;Display Counting Up message until counter bigger than 20
    MOVLW 'C'
    CALL LCD_Send_Char
    MOVLW 'o'
    CALL LCD_Send_Char
    MOVLW 'u'
    CALL LCD_Send_Char
    MOVLW 'n'
    CALL LCD_Send_Char
    MOVLW 't'
    CALL LCD_Send_Char
    MOVLW 'i'
    CALL LCD_Send_Char
    MOVLW 'n'
    CALL LCD_Send_Char
    MOVLW 'g'
    CALL LCD_Send_Char
    CALL Display_Space
    CALL LCD_Send_Char
    MOVLW 'U'
    CALL LCD_Send_Char
    MOVLW 'p'
    CALL LCD_Send_Char
    MOVLW '.'
    CALL LCD_Send_Char
    MOVLW '.'
    CALL LCD_Send_Char
    MOVLW '.'
    CALL LCD_Send_Char    
    RETURN
DISPLAY_MESSAGE_ROLLING_UP ;ROLL MESSAGE to display counter==20
    MOVLW 'R'
    call LCD_Send_Char
    MOVLW 'o'
    call LCD_Send_Char
    MOVLW 'l'
    CALL LCD_Send_Char
    MOVLW 'l'
    CALL LCD_Send_Char
    MOVLW 'e'
    CALL LCD_Send_Char
    MOVLW 'd'
    CALL LCD_Send_Char
    CALL Display_Space
    CALL LCD_Send_Char
    MOVLW 'O'
    CALL LCD_Send_Char
    MOVLW 'v'
    CALL LCD_Send_Char
    MOVLW 'e'
    CALL LCD_Send_Char
    MOVLW 'r'
    CALL LCD_Send_Char
    MOVLW' '
    CALL LCD_Send_Char
    MOVLW 'T'
    CALL LCD_Send_Char
    MOVLW 'o'
    CALL LCD_Send_Char
    CALL Display_Space
    CALL LCD_Send_Char
    MOVLW '0'
    CALL LCD_Send_Char 
    RETURN

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


