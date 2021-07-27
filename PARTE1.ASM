;=========================================================================
;					Proyecto Final ISE
;					"Sistema de Votacion"
; Por: 
;	* Alejandro Ballón
;	* Ricardo Temoche
;	* Mauricio Rivera
;	* Alex Rodríguez
;	* Eduardo Guerrero
; 
;==========================================================================
.CSEG
;.DEF Banderas=R16 --> [habilitar_votacion, escrutinio, habilitador_p0, condicion_display,0,0,veces_presionado_p0(1),veces_presionado_p0(0)]) <===CAMBIAR A ESTO
.DEF habilitar_votacion=R16
.DEF veces_presionado_p0=R17
.DEF escrutinio=R18
.DEF habilitador_p0=R19
; tiempo_p0 = R27 (Solo se utiliza al incio)
.DEF cont_timer_individual=R20
.DEF cont_timer_total=R21
.DEF valor_del_display=R22
.DEF DIG1=R23
.DEF DIG2=R24
.DEF DIG3=R25
;.DEF contA
;.DEF contB
;.DEF contblanco
;.DEF contn
;R26 = registro temporal
;total_de_votaciones=R27
;.DEF condicion_display
; ValorADC_HIGH=R29;(R28 y R29) 
; ValorADC_LOW=R28

;Vector de interrupciones
.ORG 0x00 
	JMP Inicio
.ORG 0x1A
   	JMP Timer_1s_ISR 
.ORG 0x0002
	JMP P0_ISR
.ORG 0x0004
	JMP SW_ISR
.ORG 0x0006; <===========================REVISAR ESTO
	JMP P1_ISR; Ver esto pq todos son PCINT0
	JMP P2_ISR
	JMP P3_ISR
	JMP P4_ISR
.ORG 0x002A
	JMP ISR_ADC

.ORG 0x0034

Inicio:
;================ Definiendo Pila ==================
	LDI R26, LOW(RAMEND)
	OUT SPL, R26 
	LDI R26, HIGH(RAMEND)
	OUT SPH, R26

;=========== Configuracion de Puertos ==============
;Puertos de Entrada: PD2, PD3, PB0, PB1, PB2, PB3, PC0
;Puertos de Salida: PD0, PD1, PD[4:7], PB[4:7]
	LDI R26,  0b11110011
	OUT DDRD, R26
	
	LDI R26, 0b11110000
	OUT DDRB, R26
	
	LDI R26, 0b00000000
	OUT DDRC, R26

;========== Inicialización de variables ============
Definicion_RAM_Display:
	LDI ZH, HIGH(0x100)
	LDI ZL, LOW(0x100)

Definicion_RAM_Timer_General:
	LDI R26, 60
	ST Z, R26	//R26="D"   guarda _ en 0x100

;=========Configuracion de Interrupciones===========
;P0_ISR

;P1_ISR

;P2_ISR

;P3_ISR

;P4_ISR

;SW_ISR

;--------------------ADC_ISR------------------------
;ADMUX: ADC Multiplexor Selection Register 
;	[REFS1, REFS2, ADLAR, - , MUX3, MUX2, MUX1, MUX0] 
;	* REFS[1:0]= 01 --> AVcc con capacitor en pin AREF
;	* ADLAR= 0 --> Se quiere 10 bits de presicion
;	* MUX[3:0]= 0000 --> Usar la entrada ADC0
	LDI R26, 0b01000000
	STS ADMUX, R26

;ADCSRA: ADC Control and Status Register A 
;	[ADEN, ADSC, ADATE, ADIF, ADIE, ADPS2, ADPS1, ADPS0] 
;	* ADEN= 1 --> Activar ADC
;	* ADSC= 1 --> Empezar Conversion
;	* ADATE= 1 --> Activar autotriggering
;	* ADIF --> Interrupt Flag (No se quiere escribir)
;	* ADIE = 1 -> Activar interrupcion
;	* ADPS[2:0] = 000 --> Factor de Prescaler=128
	LDI R26, 0b11101111
	STS ADCSRA, R26

;ADCSRB: ADC Control and Status Register B
;	[-, ACME , -, -, -, ADTS2, ADTS1, ADTS0] 
;	* ACME = 0
;	* ADTS[2:0] = 000 --> Free Running Mode
	LDI R26, 0b00000000; Porque el registro guarda el valor 0
	STS ADCSRB, R26 

	LDI R26,0b00000001; Para deshabilitar el Buffer para el ADC0
	STS DIDR0, R26

;------------------Timer_1s_ISR------------------------
; Configuracion de registros del Timer_1

; Configuracion del Prescaler
LDI R26, 0b0000_0101
STS TCCR1B, R26		; Prescaler de 1024 (16 MHz/1024 = 15625 Hz = 64 us)

; Configuración del registro de cuenta
; MAX	= FFFF = 65535
; TCNT1 = C2F6 = 49910
; Tiempo antes del overflow = (65535 - 49910)*64 us = 1 s
LDI R26,0xC2
STS TCNT1H,R26
LDI R26,0xF6
STS TCNT1L,R26
 
; Configuracion de la mascara del Timer_1
LDI R26, 0b0000_0001
STS TIMSK1, R26		; Se habilita la interrupción por overflow del Timer_1


;-----------------Timer_P0_Presionado--------------------       		

	LDI R26, 0b0000_0001
	STS TIMSK1, R26                 		; Interrupción por Overflow
	
	;Overflow cada 10ms a una frecuencia de 1MHz
	;para 10ms -> 10=0x0A
	;valor_max=255, valor_10ms=10, valor_inicial=255-10=245
	LDI R26, 0xF5      ;valor_inicial
	STS TCNT1, R26

;========= Habilitacion de interrupcion global ============
	SEI

;==========================================================
;                       Subrutinas
;==========================================================

;------------------------ISR_P0---------------------------
;Registros Modificados =>
;Registros de Entrada =>

;------------------------ISR_P1---------------------------
;Registros Modificados =>
;Registros de Entrada =>

;------------------------ISR_P2---------------------------
;Registros Modificados =>
;Registros de Entrada =>

;------------------------ISR_P3---------------------------
;Registros Modificados =>
;Registros de Entrada =>

;------------------------ISR_P4---------------------------
;Registros Modificados =>
;Registros de Entrada =>

;------------------------ISR_SW---------------------------
;Registros Modificados =>
;Registros de Entrada =>

;------------------------ISR_ADC--------------------------
;Registros Modificados => ValorADC_HIGH, ValorADC_LOW
;Registros de Usados => R26

ISR_ADC	:
	PUSH R26
	IN R26, SREG
	PUSH R26

	LDS YL, ADCL ;R28 -> ValorADC_LOW
	LDS YH, ADCH ;R29 -> ValorADC_HIGH

    CPI YH, 0x01
	BRLO LED1
	CPI YH, 0x01
	BREQ ADC_LOOP1
	RJMP LED0

ADC_LOOP1:
	CPI YL, 0xD7
	BRLO LED1
	RJMP LED0

LED0:;SIST NO BLOQUEADO
	LDI R26, 0b00001111
	STS PCMSK0, R26; Habilitando interrupciones por PCINT00, PCINT01, PCINT02 y PCINT03 (P1, P2, P3, P4)
	LDI R26, 0b00000010
	OUT EIMSK, R26; Habilitando interrupciones por INT0 y INT1 (P0, SW)

	CPI escrutinio, 0
	BRNE deshabilitar_SW
	LDI R26, 0b00000011
	OUT EIMSK, R26;
	RJMP ISR_ADC_End

deshabilitar_SW:
	LDI R26, 0b00000010	 
	OUT EIMSK, R26;
	RJMP ISR_ADC_End

LED1:;SIST SI BLOQUEADO
	CLR R26
	STS PCMSK0, R26; Deshabilitando interrupciones por PCINT0, PCINT1, PCINT2 y PCINT3 (P1, P2, P3, P4)
	CLR R26
	OUT EIMSK, R26; Deshabilitando interrupciones por INT0 y INT1 (P0, SW)
	;falta agregar valor_display=8;
	RJMP ISR_ADC_End

ISR_ADC_End:
	POP R26
	OUT SREG, R26
	POP R26
	RETI

;---------------------ISR_Timer_1s------------------------
; Registros Modificados => cronomtero = cont_timer_individual, ZL, ZH
; Registros de Entrada => R26
; Obs => veces_presionado_p0 no está definido

Timer_1s_ISR:
	PUSH R26
	IN R26, SREG
	PUSH R26

	PUSH ZH
	PUSH ZL

	DEC cont_timer_individual ; cont_timer_individual--; 

	CPI habilitador_p0, 0	; if (habilitadorP0==0)
	BREQ habilitador_p0_ES_0 
	; habilitador_p0 ES DIFERENTE A 0

	LDI ZH, 0x01
	LDI ZL, 0x00
	LD R26, Z; Extrae el valor 60 (1 minuto) de 0x0100
	DEC R26

	CPI R26, 0
	BRNE No_ha_pasado_1min
		LDI R26, 60
		DEC cont_timer_total

No_ha_pasado_1min:
	ST Z, R26 ;Z mantiene el valor 0x0112
	CPI cont_timer_total, 0	; if (cont_timer_total == 0) ////////////
	BREQ cont_timer_total_ES_0	
	; cont_timer_total ES DIFERENTE A 0

	CPI cont_timer_individual, 0	; if(cont_timer_individual == 0)
	BREQ cont_individual_ES_0
	; cont_individual ES DIFERENTE DE 0
	; valor_del_display=7; <-----

	cont_individual_ES_0:
		INC contn 
		LDI cont_timer_individual, 30
		LDI habilitador, 0 ;///////////////////////

	cont_timer_total_ES_0:
		LDI escrutinio, 1
		; Timer_1s_Stop();
		LDI R26, 0b0000_0000
   	    ;STS TCCR1B, R26 ; No clock source (Timer/Counter stopped)
		; valor_del_display=4; <-----


	habilitador_p0_ES_0:
		CPI cont_timer_individual, 0	; if(cont_timer_individual == 0) 1ro
		BREQ  cont_timer_individual_ES_0
		; cont_timer_individual ES DIFERENTE A 0

		; valor_del_display=7; <-----

		cont_timer_individual_ES_0:
			LDI veces_presionado_p0, 0 /////////////////
			LDI cont_timer_individual, 30

			; valor_del_display=7; <-----

; Se reinicia el Timer_1
LDI R26,0xC2
STS TCNT1H,R26
LDI R26,0xF6
STS TCNT1L,R26
	
	POP ZL
	POP ZH

	POP R26
	OUT SREG, R26
	POP R26
RETI

;-----------------ISR_Timer_P0_Presionado----------------- 
;Registros de Usados => (registro que tome tiempo_p0), R26 y TCNT
;Registros Modificados =>  (registro que tome tiempo_p0)

	PUSH R26
	IN R26, SREG
	PUSH R26
	INC R27; R27 -> tiempo_p0 (Al inicio)

	;Se reinicia el valor inicial del timer
	;valor_max=255, valor_10ms=10, valor_inicial=255-10=245
	;LDI R26, 0xF5      ;valor_inicial
	;STS TCNT1, R26
	

	POP R26
	OUT SREG, R26
	POP R26
	RETI


;------------------------BCD2BIN7SEG----------------------
;Registros Modificados =>
;Registros de Entrada =>
BIN2BCD7SEG:
	PUSH R26
	IN R26, SREG
	PUSH R26

CPI escrutinio, 0
BRNE Esc_es_1
no_valido:
	CPI valor_del_display, 0
	BRNE A
	LDI DIG1, 0x77//n
	LDI DIG2, 0xFF
	LDI DIG3, 0xFF
	RJMP DISP
A:
	CPI valor_del_display, 1
	BRNE B
	LDI DIG1, 0x08//A
	LDI DIG2, 0xFF
	LDI DIG3, 0xFF
	RJMP DISP

B:
	CPI valor_del_display, 2
	BRNE blanco
	LDI DIG1, 0x00//B
	LDI DIG2, 0xFF
	LDI DIG3, 0xFF
	RJMP DISP

blanco:
	CPI valor_del_display, 3
	BRNE n
	LDI DIG1, 0x03//blanco
	LDI DIG2, 0xFF
	LDI DIG3, 0xFF	
	RJMP DISP

n:
	CPI valor_del_display, 4
	BRNE no_elecciones
	LDI DIG1, 0x2B//n
	LDI DIG2, 0xFF
	LDI DIG3, 0xFF
	RJMP DISP

no_elecciones:
	CPI valor_del_display, 5
	BRNE Cronometro_total
	LDI DIG1, 0xFF//n
	LDI DIG2, 0xFF
	LDI DIG3, 0xFF
	RJMP DISP

Cronometro_total:
	CPI valor_del_display,6
	BRNE Cronometro_individual
	MOV DIG1, cont_timer_total
    CLR DIG2 ; Decenas =0
	CLR DIG3 ; Centenas = 0

CG_Loop1:
    CPI DIG1, 10    ;Comprueba valor menor a 10
    BRLO CG_Loop2		; Si ya no se tiene mas decenas procede a guardar los valores
    SUBI DIG1,10
    INC DIG2 ; Cuenta las decenas
    RJMP CG_Loop1

CG_Loop2: 
    CPI DIG2, 10    ;Comprueba valor menor a 10
    BRLO End_CG		; Si ya no se tiene mas centenas procede a guardar los valores
    SUBI DIG2,10
    INC DIG3 ; Cuenta las centenas
	RJMP CG_Loop2
End_CG:
	RCALL Valores_BCD2SEG7 
	RJMP DISP

Cronometro_individual:
	CPI valor_del_display,7
	BRNE Sist_Bloqueado
	MOV DIG1, cont_timer_individual
    CLR DIG2 ; Decenas =0
	CLR DIG3 ; Centenas = 0

CI_Loop1:
    CPI DIG1, 10    ;Comprueba valor menor a 10
    BRLO CI_Loop2		; Si ya no se tiene mas decenas procede a guardar los valores
    SUBI DIG1,10
    INC DIG2 ; Cuenta las decenas
    RJMP CI_Loop1

CI_Loop2: 
    CPI DIG2, 10    ;Comprueba valor menor a 10
    BRLO End_CI		; Si ya no se tiene mas centenas procede a guardar los valores
    SUBI DIG2,10
    INC DIG3 ; Cuenta las centenas
	RJMP CI_Loop2
End_CI:
	RCALL Valores_BCD2SEG7 
	RJMP DISP

Sist_Bloqueado:
	CPI valor_del_display, 8
	BRNE DISP
	LDI DIG3, 0x3F//E
	LDI DIG2, 0x3F//n
	LDI DIG1, 0x3F//d
	RJMP DISP

Esc_es_1:
Valor_ContA:
	CPI valor_del_display, 0
	BRNE Valor_ContB
	MOV DIG1, contA
    CLR DIG2 ; Decenas =0
	CLR DIG3 ; Centenas = 0

VCA_Loop1:
    CPI DIG1, 10    ;Comprueba valor menor a 10
    BRLO VCA_Loop2		; Si ya no se tiene mas decenas procede a guardar los valores
    SUBI DIG1,10
    INC DIG2 ; Cuenta las decenas
    RJMP VCA_Loop1

VCA_Loop2: 
    CPI DIG2, 10    ;Comprueba valor menor a 10
    BRLO End_VCA		; Si ya no se tiene mas centenas procede a guardar los valores
    SUBI DIG2,10
    INC DIG3 ; Cuenta las centenas
	RJMP VCA_Loop2
End_VCA:
	RCALL Valores_BCD2SEG7 
	RJMP DISP

Valor_ContB:
	CPI valor_del_display, 1
	BRNE Valor_Contblanco
	MOV DIG1, contB
    CLR DIG2 ; Decenas =0
	CLR DIG3 ; Centenas = 0

VCB_Loop1:
    CPI DIG1, 10    ;Comprueba valor menor a 10
    BRLO VCB_Loop2		; Si ya no se tiene mas decenas procede a guardar los valores
    SUBI DIG1,10
    INC DIG2 ; Cuenta las decenas
    RJMP VCB_Loop1

VCB_Loop2: 
    CPI DIG2, 10    ;Comprueba valor menor a 10
    BRLO End_VCB		; Si ya no se tiene mas centenas procede a guardar los valores
    SUBI DIG2,10
    INC DIG3 ; Cuenta las centenas
	RJMP VCB_Loop2
End_VCB:
	RCALL Valores_BCD2SEG7 
	RJMP DISP

Valor_Contblanco:
	CPI valor_del_display, 2
	BRNE Valor_Contn
	MOV DIG1, contblanco
    CLR DIG2 ; Decenas =0
	CLR DIG3 ; Centenas = 0

VCblanco_Loop1:
    CPI DIG1, 10    ;Comprueba valor menor a 10
    BRLO VCblanco_Loop2		; Si ya no se tiene mas decenas procede a guardar los valores
    SUBI DIG1,10
    INC DIG2 ; Cuenta las decenas
    RJMP VCblanco_Loop1

VCblanco_Loop2: 
    CPI DIG2, 10    ;Comprueba valor menor a 10
    BRLO End_VCblanco		; Si ya no se tiene mas centenas procede a guardar los valores
    SUBI DIG2,10
    INC DIG3 ; Cuenta las centenas
	RJMP VCblanco_Loop2
End_VCblanco:
	RCALL Valores_BCD2SEG7 
	RJMP DISP

Valor_Contn:
	CPI valor_del_display, 3
	BRNE End
	MOV DIG1, contn
    CLR DIG2 ; Decenas =0
	CLR DIG3 ; Centenas = 0

VCn_Loop1:
    CPI DIG1, 10    ;Comprueba valor menor a 10
    BRLO VCn_Loop2		; Si ya no se tiene mas decenas procede a guardar los valores
    SUBI DIG1,10
    INC DIG2 ; Cuenta las decenas
    RJMP VCn_Loop1

VCn_Loop2: 
    CPI DIG2, 10    ;Comprueba valor menor a 10
    BRLO End_VCn		; Si ya no se tiene mas centenas procede a guardar los valores
    SUBI DIG2,10
    INC DIG3 ; Cuenta las centenas
	RJMP VCn_Loop2
End_VCn:
	RCALL Valores_BCD2SEG7 
	RJMP DISP

End:
	CPI valor_del_display, 4
	BRNE Sist_Bloqueado_Esc1
	LDI DIG3, 0x06//E
	LDI DIG2, 0x2B//n
	LDI DIG1, 0x21//d
	RJMP DISP
	
Sist_Bloqueado_Esc1:
	CPI valor_del_display, 8
	BRNE DISP
	LDI DIG3, 0x3F//E
	LDI DIG2, 0x3F//n
	LDI DIG1, 0x3F//d
	RJMP DISP

DISP:
;Puertos de Salida: PD0, PD1, PD[4:7], PB[4:7]
;PUERTO D[SegG, SegF, SegE, SegC, -, -, SegB, SegA]
;PUERTO B[COM3, COM2, COM1, SegD, -, -, -, -]  

;Mandando DIG1 al Display y habilitandolo
	LDI R26, 0b01110000; Extraynedo los valores para SegG, SegF, SegE
	AND R26, DIG1
	LSL R26
	LDI R30, 0b00000100; Extraynedo los valores para SegC
	AND R30, DIG1
	LSL R30
	LSL R30
	LDI R31, 0b00000011; Extraynedo los valores para SegB, SegA
	AND R31, DIG1
	ADD R26,R30 ;Juntando Valores extraidos
	ADD R26,R31
	OUT PORTD, R26; Mandando [SegG, SegF, SegE, SegC, 0, 0, SegB, SegA]
	LDI R26, 0b00001000; Extrayendo valor de SegC 
	AND R26, DIG1
	LSL R26
	LDI R30, 0b11000000; Para habilitar COM1 (Con 0 se habilita COM1 por los transistores)
	ADD R26, R30
	OUT PORTB, R26; Mandando [1,1,0,SegD,0,0,0,0]

;Mandando DIG2 al Display y habilitandolo
	LDI R26, 0b01110000; Extraynedo los valores para SegG, SegF, SegE
	AND R26, DIG2
	LSL R26
	LDI R30, 0b00000100; Extraynedo los valores para SegC
	AND R30, DIG2
	LSL R30
	LSL R30
	LDI R31, 0b00000011; Extraynedo los valores para SegB, SegA
	AND R31, DIG2
	ADD R26,R30 ;Juntando Valores extraidos
	ADD R26,R31
	OUT PORTD, R26; Mandando [SegG, SegF, SegE, SegC, 0, 0, SegB, SegA]
	LDI R26, 0b00001000; Extrayendo valor de SegC 
	AND R26, DIG2
	LSL R26
	LDI R30, 0b10100000; Para habilitar COM2 (Con 0 se habilita COM2 por los transistores)
	ADD R26, R30
	OUT PORTB, R26; Mandando [1,0,1,SegD,0,0,0,0]

;Mandando DIG3 al Display y habilitandolo
	LDI R26, 0b01110000; Extraynedo los valores para SegG, SegF, SegE
	AND R26, DIG3
	LSL R26
	LDI R30, 0b00000100; Extraynedo los valores para SegC
	AND R30, DIG3
	LSL R30
	LSL R30
	LDI R31, 0b00000011; Extraynedo los valores para SegB, SegA
	AND R31, DIG3
	ADD R26,R30 ;Juntando Valores extraidos
	ADD R26,R31
	OUT PORTD, R26; Mandando [SegG, SegF, SegE, SegC, 0, 0, SegB, SegA]
	LDI R26, 0b00001000; Extrayendo valor de SegC 
	AND R26, DIG3
	LSL R26
	LDI R30, 0b01100000; Para habilitar COM1 (Con 0 se habilita COM1 por los transistores)
	ADD R26, R30
	OUT PORTB, R26; Mandando [0,1,1,SegD,0,0,0,0]

	POP R26
	OUT SREG, R26
	POP R26

	RET

;----------------Valores_BCD2SEG7---------------
;Contiene los valores necesarios para mostrar numeros en el display
	Valores_BCD2SEG7: 
	PUSH R26
	IN R26, SREG
	PUSH R26
	 
   DIG1_0:
	   CPI  DIG1, 0
	   BRNE	DIG1_1
	   LDI  DIG1, 0x40
	   RJMP	DIG2_0
   DIG1_1:
	   CPI	DIG1, 1
	   BRNE	DIG1_2
	   LDI	DIG1, 0x79
	   RJMP	DIG2_0
   DIG1_2:
	   CPI	DIG1, 2
	   BRNE	DIG1_3
	   LDI	DIG1, 0x24
	   RJMP	DIG2_0
   DIG1_3:
	   CPI	DIG1, 3
	   BRNE	DIG1_4
	   LDI	DIG1, 0x30
	   RJMP	DIG2_0
	DIG1_4:
	   CPI	DIG1, 4
	   BRNE	DIG1_5
	   LDI	DIG1,  0x19
	   RJMP	DIG2_0
	DIG1_5:
	   CPI	DIG1, 5
	   BRNE	DIG1_6
	   LDI	DIG1, 0x12
	   RJMP	DIG2_0
	DIG1_6:
	   CPI	DIG1, 6
	   BRNE	DIG1_7
	   LDI	DIG1, 0x02
	   RJMP	DIG2_0
	DIG1_7:
	   CPI	DIG1, 7
	   BRNE	DIG1_8
	   LDI	DIG1, 0x78
	   RJMP	DIG2_0
	DIG1_8:
	   CPI	DIG1, 8
	   BRNE	DIG1_9
	   LDI	DIG1, 0x00
	   RJMP	DIG2_0
	DIG1_9:
	   CPI	DIG1, 9
	   BRNE	DIG2_0
	   LDI	DIG1, 0x10
	   RJMP	DIG2_0

	DIG2_0:
	   CPI  DIG2, 0
	   BRNE	DIG2_1
	   LDI  DIG2, 0x40
	   RJMP	DIG3
   DIG2_1:
	   CPI	DIG2, 1
	   BRNE	DIG2_2
	   LDI	DIG2, 0x79
	   RJMP	DIG3
   DIG2_2:
	   CPI	DIG2, 2
	   BRNE	DIG2_3
	   LDI	DIG2, 0x24
	   RJMP	DIG3
   DIG2_3:
	   CPI	DIG2, 3
	   BRNE	DIG2_4
	   LDI	DIG2, 0x30
	   RJMP	DIG3
	DIG2_4:
	   CPI	DIG2, 4
	   BRNE	DIG2_5
	   LDI	DIG2,  0x19
	   RJMP	DIG3
	DIG2_5:
	   CPI	DIG2, 5
	   BRNE	DIG2_6
	   LDI	DIG2, 0x12
	   RJMP	DIG3
	DIG2_6:
	   CPI	DIG2, 6
	   BRNE	DIG2_7
	   LDI	DIG2, 0x02
	   RJMP	DIG3
	DIG2_7:
	   CPI	DIG2, 7
	   BRNE	DIG2_8
	   LDI	DIG2, 0x78
	   RJMP	DIG3
	DIG2_8:
	   CPI	DIG2, 8
	   BRNE	DIG2_9
	   LDI	DIG2, 0x00
	   RJMP	DIG3
	DIG2_9:
	   CPI	DIG2, 9
	   BRNE	DIG3
	   LDI	DIG2, 0x10
	   RJMP	DIG3

	DIG3_0:
	   CPI  DIG3, 0
	   BRNE	DIG3_1
	   LDI  DIG3, 0x40
	   RJMP	Final_BCD2SEG7
   DIG3_1:
	   CPI	DIG3, 1
	   BRNE	DIG3_2
	   LDI	DIG3, 0x79
	   RJMP	Final_BCD2SEG7
   DIG3_2:
	   CPI	DIG3, 2
	   BRNE	DIG3_3
	   LDI	DIG3, 0x24
	   RJMP	Final_BCD2SEG7
   DIG3_3:
	   CPI	DIG3, 3
	   BRNE	DIG3_4
	   LDI	DIG3, 0x30
	   RJMP	Final_BCD2SEG7
	DIG3_4:
	   CPI	DIG3, 4
	   BRNE	DIG3_5
	   LDI	DIG3,  0x19
	   RJMP	Final_BCD2SEG7
	DIG3_5:
	   CPI	DIG3, 5
	   BRNE	DIG3_6
	   LDI	DIG3, 0x12
	   RJMP	Final_BCD2SEG7
	DIG3_6:
	   CPI	DIG3, 6
	   BRNE	DIG3_7
	   LDI	DIG3, 0x02
	   RJMP	Final_BCD2SEG7
	DIG3_7:
	   CPI	DIG3, 7
	   BRNE	DIG3_8
	   LDI	DIG3, 0x78
	   RJMP	Final_BCD2SEG7
	DIG3_8:
	   CPI	DIG3, 8
	   BRNE	DIG3_9
	   LDI	DIG3, 0x00
	   RJMP	Final_BCD2SEG7
	DIG3_9:
	   CPI	DIG3, 9
	   BRNE	Final_BCD2SEG7
	   LDI	DIG3, 0x10
	   RJMP	Final_BCD2SEG7

 Final_BCD2SEG7:
	   POP R26
	   OUT SREG, R26
	   POP R26

	   RET
;===================================================================================
;                       PROGRAMA PRINCIPAL (MAIN LOOP)
;===================================================================================
Main:
    CPI veces_presionado_p0, 3
	BRNE No_se_presiono_3_veces_p0
		LDI habilitador_p0, 1
		CPI XH, 150 ; XH = R27 -> total_de_votaciones
		BRNE No_llego_a_XH
			LDI escrutinio,1
			LDI valor_del_display, 4
			INC XH
			LDI R26, 0b00000010
			OUT EIMSK, R26; Deshabilitando interrupciones por SW
			;Deshabilitar Timer_1s <=======================================================RIVERA
		No_llego_a_XH:
		CPI escrutinio, 0
		BRNE escrutinio_no_es_igual_a_0
			IN R26, PINB
			LDI R30, 0b00001111
			AND R26, R30 ; Para leer el valor de los puertos conectados a P1, P2, P3, P4
			CPI R26, 0
			BRNE R26, Hay_pulsadores_presionados;Pregunta si no hay pulsadores presionados
				;condicion_display=0 <====================================================Falta Registro
				CPI votacion, 0
				BRNE habilitar_votacion_es_1
					LDI valor_del_display, 6
					RCALL BIN2BCD7SEG
					RJMP escrutinio_no_es_igual_a_0
				habilitar_votacion_es_1:
					LDI valor_del_display, 7
					RCALL BIN2BCD7SEG
					RJMP Main

			Hay_pulsadores_presionados:
				CPI habilitar_votacion, 0
				BRNE habilitador_vot_es_1
					LDI valor_del_display, 0
					RCALL BIN2BCD7SEG
				habilitador_vot_es_1:
				CPI condicion_display, 1
				BRNE condicion_disp_no_es_1
					RJMP Main
				condicion_disp_no_es_1:
					INC condicion_display
					RCALL BIN2BCD7SEG.
		escrutinio_no_es_igual_a_0:
			RCALL BIN2BCD7SEG
			RJMP Main
	No_se_presiono_3_veces_p0:
		RCALL BIN2BCD7SEG
		RJMP Main
