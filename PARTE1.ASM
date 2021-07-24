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



.DSEG
.ORG $100
LUT_display:	.BYTE 16
UNIDADES:		.BYTE 1
DECENAS:		.BYTE 1
CENTENAS:		.BYTE 1
.EQU CONT_TIMER_GENERAL=3600
.CSEG
.DEF valor_display=R22
.DEF habilitar_votacion=R16
.DEF habilitador_p0=R19
.DEF cronometro=R20
.DEF total_de_votaciones=R21
.DEF temp  = R24 ; Registro Temporal
.DEF aux   = r17 ; Registro Auxiliar
.DEF inout = r18 ; Registro de in/out para subrutinas
.DEF DUB   = r25 ; Registro alternador entre Centenas, Decenas y Unidades

.EQU  a = 7 ; PIND0
.EQU  b = 6 ; PIND1
.EQU  c = 5 ; PIND4
.EQU  d = 4 ; PINB4
.EQU  e = 3 ; PIND5
.EQU  f = 2 ; PIND6
.EQU  g = 1 ; PIND7


.EQU DIG3 = 2 ; PINB7
.EQU DIG2 = 1 ; PINB6
.EQU DIG1 = 0 ; PINB5

;.MACRO delay
;	LDI R26,0x7F		;Set Register 
;	LDI R27,0x3E		;Load immediate 
;	LDI R28,0x00		;Load immediate 
;	SUBI R26,0x01		;Subtract immediate 
;	SBCI R27,0x00		;Subtract immediate with carry 
;	SBCI R28,0x00		;Subtract immediate with carry 
;	BRNE PC-0x03		;Branch if not equal 
;	RJMP PC+0x0001		;Relative jump 
;	NOP 				;No operation
;.ENDMACRO

main:
	; Reiniciar SP
	LDI temp, LOW(RAMEND)
	OUT SPL, temp
	LDI temp, HIGH(RAMEND)
	OUT SPH, temp

	; Configurar I/O
	LDI temp, 0x0F
	OUT DDRB, temp
	; PINB0 <- P4
	; PINB1 <- P3
	; PINB2 <- P2
	; PINB3 <- P1
	; PINB4 -> display d
	; PINB5 -> display DIG1 
	; PINB6 -> display DIG2
	; PINB7 -> display DIG3

	LDI temp, 0xF3
	OUT DDRD, temp
	; PIND0 -> display a
	; PIND1 -> display b
	; PIND2 <- P0
	; PIND3 <- SW0
	; PIND4 -> display c
	; PIND5 -> display e
	; PIND6 -> display f
	; PIND7 -> display g

	CLR temp
	OUT PORTB, temp ; Set Outputs LOW, disable input pullups
	OUT PORTD, temp ; Set Outputs LOW, disable input pullups


	; Configurar Display 7 Segmentos
	CALL init_7SEGMENT
    
inicio:

	CALL disp_7SEGMENT
	CPI Veces_presionado,3
	BREQ loop
	RJMP inicio
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
loop: 
	SBI HabilitadorP0,0
	CPI total_de_votaciones,150
	BREQ loop_1
	RET
loop_1:
	SBI Escrutinio,0
	mov valor_display, 1 
RET

; SUBRUTINA init_7SEGMENT
init_7SEGMENT:
	; Guardar Registros y SREG
	PUSH temp
	IN temp, SREG
	PUSH temp

	; Cargar direccion del LUT en el puntero Z
	LDI ZL, LOW(LUT_display)
	LDI ZH, HIGH(LUT_display)
	
	; Guardar valores predefinidos del LUT en la RAM
	LDI temp, 0x40	; valor para 0
	ST Z+, temp
	LDI temp, 0x79	; valor para 1
	ST Z+, temp
	LDI temp, 0x24	; valor para 2
	ST Z+, temp
	LDI temp, 0x30	; valor para 3
	ST Z+, temp
	LDI temp, 0x19	; valor para 4
	ST Z+, temp
	LDI temp, 0x12	; valor para 5
	ST Z+, temp
	LDI temp, 0x02	; valor para 6
	ST Z+, temp
	LDI temp, 0x78	; valor para 7
	ST Z+, temp
	LDI temp, 0x00	; valor para 8 y B
	ST Z+, temp
	LDI temp, 0x10	; valor para 9
	ST Z+, temp
	LDI temp, 0x06	; valor para E
	ST Z+, temp
	LDI temp, 0x2B	; valor para N y nulo
	ST Z+, temp
	LDI temp, 0x21	; valor para D
	ST Z+, temp
	LDI temp, 0x3F	; valor para -
	ST Z+, temp
	LDI temp, 0x8	; valor para A
	ST Z+, temp
	LDI temp, 0x3	; valor para blanco
	ST Z+, temp
	; DUB = 0
	CLR DUB

	; Recuperar registros y SREG
	POP temp
	OUT SREG, temp
	POP temp

	; FIN
	RET

; SUBRUTINA disp_7SEGMENT
disp_7SEGMENT:
	; Guardar Registros y SREG
	PUSH temp
	IN temp, SREG
	PUSH temp
	PUSH ZH
	PUSH ZL
	PUSH inout

	; BIN2DEC
	CALL BIN2DEC
	
	; Cargar Puntero en el registro Z
	LDI ZL, LOW(LUT_display)
	LDI ZH, HIGH(LUT_display)

	; Determinar si se muestra centena, decena o unidad
	SBRC DUB, 7
	RJMP disp_centenas	; si DUB(7)=1				-> display centenas

	SBRC DUB, 6
	RJMP disp_decenas	; si DUB(7)=0 y DUB(6)=1	-> display decenas


disp_unidades:				; else						-> display unidades
	SBI PORTB, DIG3
	SBI PORTB, DIG2
	CBI PORTB, DIG1
	LDS inout, UNIDADES
	RJMP disp_mostrar

disp_decenas:
	SBI PORTB, DIG3
	CBI PORTB, DIG2
	SBI PORTB, DIG1
	LDS inout, DECENAS
	RJMP disp_mostrar

disp_centenas:
	CBI PORTB, DIG3
	SBI PORTB, DIG2
	SBI PORTB, DIG1
	LDS inout, CENTENAS
	RJMP disp_mostrar

	; Display numero en 7 segmentos
disp_mostrar:
	; Encontrar direccion en la RAM
	ANDI inout, 0x0F
	ADD ZL, inout
	
	; Cargar valor en temp
	LD temp, Z
	;COM temp
	
	; Si se prende el segmento d, prenderlo, sino apagarlo (para el puerto B)
	SBRC temp, d
	SBI PORTB, 3
	SBRS temp, d
	CBI PORTB, 3

	ANDI temp, 0xF3
	OUT PORTD, temp
	INC DUB

disp_salida:
	; Recuperar Registros y SREG
	POP inout
	POP ZL
	POP ZH
	POP temp
	OUT SREG, temp
	POP temp
	RET

; SUBRUTINA BIN2DEC
BIN2DEC:
	PUSH temp
	IN temp, SREG
	PUSH temp
	PUSH aux
	CPI Valor_display,1
	BREQ BCD2BIN7SEG_TIMER_GENERAL
	CPI Valor_display,2
	BREQ BCD2BIN7SEG_TIMER_INDIVIDUAL

	; Leer contador
	IN temp, TCNT0
	; Clear Centenas/Unidades
	CLR aux
	RET

BCD2BIN7SEG_TIMER_GENERAL:
BIN2DEC_centenas_general:
	; Contador menor a 100?
	CPI temp, 3600
	BRLO BIN2DEC_centenas_fin_general

	; Caso mayor a 100
	SUBI temp, 3600
	INC aux
	RJMP BIN2DEC_centenas_general

BIN2DEC_centenas_fin_general:
	; Caso menor a 100
	STS CENTENAS, aux
	CLR aux

BIN2DEC_decenas_general:
	; Contador menor a 10?
	CPI temp, 60
	BRLO BIN2DEC_decenas_fin_general

	; Caso mayor a 10
	SUBI temp, 60
	INC aux
	RJMP BIN2DEC_decenas_general

BIN2DEC_decenas_fin_general:
	; Caso menor a 10
	STS DECENAS, aux

BIN2DEC_unidades_general:	
	STS UNIDADES, temp

BIN2DEC_salida_general:
	POP aux
	POP temp
	OUT SREG, temp
	POP temp
	RET

	BCD2BIN7SEG_TIMER_INDIVIDUAL:
BIN2DEC_centenas_individual:
	; Contador menor a 100?
	CPI temp, 100
	BRLO BIN2DEC_centenas_fin_individual

	; Caso mayor a 100
	SUBI temp, 100
	INC aux
	RJMP BIN2DEC_centenas_individual

BIN2DEC_centenas_fin_individual:
	; Caso menor a 100
	STS CENTENAS, aux
	CLR aux

BIN2DEC_decenas_individual:
	; Contador menor a 10?
	CPI temp, 10
	BRLO BIN2DEC_decenas_fin_individual

	; Caso mayor a 10
	SUBI temp, 10
	INC aux
	RJMP BIN2DEC_decenas_individual

BIN2DEC_decenas_fin_individual:
	; Caso menor a 10
	STS DECENAS, aux

BIN2DEC_unidades_individual:	
	STS UNIDADES, temp

BIN2DEC_salida_individual:
	POP aux
	POP temp
	OUT SREG, temp
	POP temp
	RET

