;=========================================================================
;			Proyecto Final ISE
;			"Sistema de Votacion"
; Por: 
;	* Alejandro Ballón
;	* Ricardo Temoche
;	* Mauricio Rivera
;	* Alex Rodríguez
;	* Eduardo Guerrero
; 
;==========================================================================

.DEF habilitar_votacion=R16
.DEF valor_display=R17 
.DEF escrutinio=R18
.DEF habilitador_p0=R19
;.DEF tiempo_p0
.DEF cronometro=R20
.DEF total_de_votaciones=R21
;.DEF veces_presionado_p0
.DEF contA=R22
.DEF contB=R23
.DEF contb=R24
.DEF contn=R25
.DEF cronometro_general_HIGH=R31
.DEF cronometro_general_LOW=R30
;.DEF condicion_display
;.DEF Volt
.DEF Valor_ADC_HIGH=R29;(R28 y R29)
.DEF Valor_ADC=R28

;Vector de interrupciones
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
	

;========== Inicialización de variables ============
	
	
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
;	* REFS[1:0]= 11 --> Volt Interno 1.1V con capacitor en pin AREF
;	* ADLAR= 0 --> Se quiere 10 bits de presicion
;	* MUX[3:0]= 0000 --> Usar la entrada ADC0
	LDI R16, 0b11000000
	STS ADMUX, R16

;ADCSRA: ADC Control and Status Register A 
;	[ADEN, ADSC, ADATE, ADIF, ADIE, ADPS2, ADPS1, ADPS0] 
;	* ADEN= 1 --> Activar ADC
;	* ADSC= 1 --> Empezar Conversion
;	* ADATE= 1 --> Activar autotriggering
;	* ADIF --> Interrupt Flag (No se quiere escribir)
;	* ADIE = 1 -> Activar interrupcion
;	* ADPS[2:0] = 000 --> Factor de Prescaler=2
	LDI R16, 0b11101000
	STS ADCSRA, R16

;ADCSRB: ADC Control and Status Register B
;	[-, ACME , -, -, -, ADTS2, ADTS1, ADTS0] 
;	* ACME = 1 --> Nose si esta bien PREGUNTAR
;	* ADPS[2:0] = 000 --> Free Running Mode
	LDI R16, 0b01000000; Porque el registro guarda el valor 0
	STS ADCSRB, R16  

;Timer_1s_ISR

;Timer_P0_Presionado

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

	LDS ValorADC_HIGH, ADCH
	LDS ValorADC_LOW, ADCL
	
	CPI ValorADC_HIGH, 0x01
	BRSH MayorA2V
	CPI ValorADC_LOW, 0xAF
	BRSH MayorA2V

	CLR R26
	STS PCMSK0, R26; Deshabilitando interrupciones por PCINT0, PCINT1, PCINT2 y PCINT3 (P1, P2, P3, P4)
	CLR R26
	OUT EIMSK, R26; Deshabilitando interrupciones por INT0 y INT1 (P0, SW)
	;falta agregar valor_display=8;
	RJMP ISR_ADC_End

MayorA2V:
	LDI R26, 0b00001111
	STS PCMSK0, R26; Deshabilitando interrupciones por PCINT0, PCINT1, PCINT2 y PCINT3 (P1, P2, P3, P4)
	LDI R26, 0b00000010
	OUT EIMSK, R26; Deshabilitando interrupciones por INT0 y INT1 (P0, SW)

	CPI escrutinio, 0
	BRNE deshabilitar_SW
	LDI R26, 0b00000011
	OUT EIMSK, R26;
	RJMP ISR_ADC_End

deshabilitar_SW:
	LDI R26, 0b00000010	 
	OUT EIMSK, R26;

ISR_ADC_End:
	POP R26
	OUT SREG, R26
	POP R26
	RETI
;---------------------ISR_Timer_1s------------------------
;Registros Modificados =>
;Registros de Entrada =>

;-----------------ISR_Timer_P0_Presionado-----------------
;Registros Modificados =>
;Registros de Entrada =>

;------------------------BCD2BIN7SEG----------------------
;Registros Modificados =>
;Registros de Entrada =>

Main:
    inc r16
    rjmp Main

