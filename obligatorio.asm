.data  ; Segmento de datos
#define ES 0x0240 ; cambio inicio de ES a siguiente pagina de direcciones

PUERTO_ENTRADA EQU 20
PUERTO_SALIDA EQU 21
PUERTO_LOG EQU 22

AREA_MEMORIA DW 3
NODO_VACIO DW 0x8000

MODO_ESTATICO DW 0
MODO_DINAMICO DW 1


COD_CERO EQU 0 ; si la operación se pudo realizar con éxito 
COD_UNO EQU 1 ; si no se reconoce el comando (comando inválido)
COD_DOS EQU 2 ; si el valor de algún parámetro recibido es inválido
COD_CUATRO EQU 4 ; si al agregar un nodo se intenta escribir fuera del área de memoria

modo_actual DW 0
arbol DW 0
index_siguiente DW 0
comando DW ?

.code  ; Segmento de código

; Inicialización del bucle
loop_start: 
	
	; Leer comando del PUERTO_ENTRADA
    IN  AX, PUERTO_ENTRADA
    MOV [comando], AX

   	MOV DX, PUERTO_LOG
	MOV AX, COD_CERO
	OUT DX, AX ; imprime el codigo cero en puerto log

	MOV AX, [comando]
	OUT DX, AX ; imprime el comando en puerto log

	; Comenzar a procesar el switch case

    CMP AX, 1
    JE cambiarModoCase

	CMP AX, 255
	JE stopCase
   
    ; Caso predeterminado si no se cumple ninguna condición anterior
    JMP defaultCase

cambiarModoCase:
    IN AX, PUERTO_ENTRADA ; leo parametro
    MOV DX, PUERTO_LOG
    OUT DX, AX ; imprime el parametro en puerto log
    CMP AX, [MODO_ESTATICO]
    JE setModoEstatico
    CMP AX, [MODO_DINAMICO]
    JE setModoDinamico

    ; Si no es ninguno de los modos válidos, envía error
	MOV AX, [COD_DOS]
    OUT DX, AX
    JMP endCase

setModoEstatico:
	MOV DX, [MODO_ESTATICO]
    MOV [modo_actual], DX
    CALL inicializarMemoria
    JMP endCase

setModoDinamico:
	MOV DX, [MODO_DINAMICO]
    MOV [modo_actual], DX
    CALL inicializarMemoria
    JMP endCase

defaultCase:
	;MOV DX, COD_UNO
    ;OUT [PUERTO_LOG], COD_UNO

endCase:
    JMP loop_start ; Terminar el bucle y volver a empezar

stopCase:


; ... otras funciones ...

inicializarMemoria PROC
	PUSH BX	; preservo valores anteriores de registros
	PUSH CX
	PUSH DX
	XOR BX, BX
	XOR CX, CX
initLoop:
	CMP CX, [AREA_MEMORIA]	; Comprueba si el índice ha llegado al final del área.
	JE endLoop 				; Si ha llegado, salta a postWhile.
	MOV DX, [NODO_VACIO]	; Carga el valor NODO_VACIO en el registro DX.
	MOV ES:[BX], DX			; Escribe el valor del registro DX en la dirección apuntada por BX.
	ADD BX, 2				; Incrementa el índice en 2 (porque es un DW).
	INC CX
	JMP initLoop
endLoop:
	POP DX
	POP CX
	POP BX
	RET
inicializarMemoria ENDP


.ports 	; Definición de puertos
20: 1, 0, 255

; 200: 1,2,3  ; Ejemplo puerto simple
; 201:(100h,10),(200h,3),(?,4)  ; Ejemplo puerto PDDV

.interrupts ; Manejadores de interrupciones
