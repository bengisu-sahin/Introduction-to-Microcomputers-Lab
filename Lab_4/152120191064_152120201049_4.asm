    ;152120191064 - BENGISU SAHIN
    ;152120201049 - MUHAMMET EREN SÖME
    LIST 	P=16F877A
    INCLUDE	P16F877.INC
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF
    radix	dec

;--variables--        
A           EQU 0x20
x           EQU 0x60
y           EQU 0x61
N           EQU 0x62
noElements  EQU 0x63

i	EQU 0x64
k	EQU 0x65
m	EQU 0x66
temp	EQU 0x67
a	EQU 0x68

R_L         EQU 0x70
R_H         EQU 0x71
sum	    EQU 0x72
temp_mult   EQU 0x73
Q	    EQU 0x74
count       EQU 0x75
       
    org 0x00	;reset vector
; ---------- Your code starts here ---------------------------- 
main
    MOVLW d'112'
    MOVWF x
    MOVLW d'100'
    MOVWF y
    MOVLW d'125'
    MOVWF N
    CALL GenerateNumbers
    MOVWF noElements ;noElements = W
    CALL AddNumbers
    CALL DisplayNumbers
    GOTO LOOP ;Infinite Loop. While(1)
    
GenerateNumbers	;Generate Numbers Function
temp2 EQU 0x76
    CLRF count
    MOVLW A
    MOVWF FSR
Loop_Begin
    MOVF N,W
    SUBWF x,W 
    BTFSC STATUS, C ;Check for x<N
    GOTO Check_Y
Loop_Body
    MOVF x,W
    ADDWF y,W ;WREG=x+y
    MOVWF temp2
    BTFSC temp2,0 ;tek ya da cift kontrolü. 0 ise skip et(çiftse else git)
    GOTO IF_STATEMENT
    GOTO ELSE_STATEMENT
Loop_End
    MOVF count,W ;Return count value via WREG
    RETURN  
IF_STATEMENT
    CALL Mult8x8    
    MOVF temp_mult, W
    MOVWF INDF
    INCF FSR, F
    INCF x, F
    INCF count, F
    GOTO Loop_Begin
ELSE_STATEMENT
    CALL Divide
    MOVF Q,W
    MOVWF INDF
    INCF FSR, F
    INCF count, F
    MOVLW d'3'
    ADDWF y,F ;y=y+3
    GOTO Loop_Begin
Check_Y
    MOVF N,W
    SUBWF y,W 
    BTFSC STATUS, C ;Check for y<N while x>=N.
    GOTO Loop_End ;both x and y equal or greater than N
    GOTO Loop_Body  
    
    
Divide ;Divide Function
    tmp EQU 0x77
    MOVF x,W
    ADDWF y,W
    MOVWF tmp
    MOVLW d'3' 
    MOVWF a ;a=3
    MOVF a,F
    BTFSC   STATUS, Z		; Is a == 0?
    RETURN			; If (a == 0) RETURN  --> Check for divide by 0
    CLRF    Q			; Q = 0
Divide_Loop
    MOVF a, W		; WREG = a
    SUBWF tmp, W		; WREG = X - WREG
    BTFSS   STATUS, C		; Was the result of the previous subtraction less than 0?	
    GOTO Division_End	; If (X < Y) we are done.
    INCF Q, F		; Q++
    MOVWF tmp			; temp = WREG
    GOTO Divide_Loop    
Division_End
    RETURN
	    
	    
Mult8x8 ;Mult Function
mult_count EQU 0x78
    CLRF    mult_count	; COUNT = 0
    BSF	    mult_count, 3	; COUNT = 8  
    CLRF    R_H		; R_H = 0
    MOVFW y		; WREG = Y (Multiplier)
    MOVWF   R_L		; R_L = WREG
    MOVFW x		; WREG = X (Multiplicant)
    RRF	    R_L, F	; R_L = R_L >> 1
Mult8x8_Loop
    BTFSC   STATUS, C	; Is the least significant bit of Y equal to 1?
    ADDWF   R_H, F	; R_H = R_H + WREG
    RRF	    R_H, F	; R_H = R_H >> 1
    RRF	    R_L, F	; R_L = R_L >> 1
    
    DECFSZ  mult_count	; COUNT = COUNT-1       
    GOTO    Mult8x8_Loop
	    
    MOVF R_L ,W
    ADDWF R_L,W ;2*p[0]
    ADDWF R_H ,W
    MOVWF temp_mult
    RETURN
    
AddNumbers ;AddNumbers Function
    CLRF i
    MOVLW A
    MOVWF FSR
loop_begin
    MOVF noElements, W
    SUBWF i, W
    BTFSC STATUS,C
    GOTO loop_end
loop_body
    MOVF INDF, W ; Wreg = indf
    ADDWF sum, F
    INCF FSR, F
    DECF noElements, F
    GOTO loop_begin
loop_end 
    RETURN
	
DisplayNumbers ;DisplayNumbers Function
    BSF     STATUS, RP0	; Select Bank1
    MOVLW   0xff	; W=0xff
    MOVWF   TRISB	; Set all pins of PORTB as input?
    CLRF    TRISD	; Set all pins of PORTD as output
    BCF     STATUS, RP0	; Select Bank0    
    ;CLRF    PORTB	; Turn off all LEDs connected to PORTB
    CLRF    PORTD	; Turn off all LEDs connected to PORTD
    MOVF sum,W
    MOVWF PORTD
    CALL Button_Press
    MOVLW A
    MOVWF FSR
    CLRF k ;k=0
    MOVLW d'5'
    MOVWF m ;m=5
for_loop_begin
    MOVF m,W	;W = 5
    SUBWF k,W	;W = k - 5(WREG). k<m
    BTFSC STATUS,C
    GOTO for_loop_end
    GOTO for_loop_body
for_loop_body	
    MOVF INDF,W
    MOVWF PORTD
    INCF k,F
    INCF FSR,F
    CALL Delay250ms
    CALL Button_Press
    GOTO for_loop_begin
for_loop_end
    RETURN
    
    
Button_Press	;Button Press Function
    BTFSC PORTB,3
    GOTO Button_Press
    RETURN 
	
	
Delay250ms  ;Delay 250 ms
v	EQU	    0x79		    ; Use memory slot 0x76
j	EQU	    0x7A		    ; Use memory slot 0x77
	MOVLW	    d'250'		    ; 
	MOVWF	    v			    ; i = 250
Delay250ms_OuterLoop
	MOVLW	    d'250'
	MOVWF	    j			    ; j = 250
Delay250ms_InnerLoop	
	NOP
	DECFSZ	    j, F		    ; j--?
	GOTO	    Delay250ms_InnerLoop

	DECFSZ	    v, F		    ; v--?
	GOTO	    Delay250ms_OuterLoop    
    RETURN	    
; ---------- Your code ends here ----------------------------   
    LOOP GOTO $	    ; Infinite loop
	END