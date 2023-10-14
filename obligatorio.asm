.data  ; Segmento de datos
PUERTO_ENTRADA DW 20
PUERTO_SALIDA DW 21
PUERTO_LOG DW 22
AREA_MEMORIA DW 2048
NODO_VACIO DW 0x8000

MODO_ESTATICO DW 0
MODO_DINAMICO DW 1


COD_CERO DW 0 ; si la operación se pudo realizar con éxito 
COD_UNO DW 1 ; si no se reconoce el comando (comando inválido)
COD_DOS DW 2 ; si el valor de algún parámetro recibido es inválido
COD_CUATRO DW 4 ; si al agregar un nodo se intenta escribir fuera del área de memoria

modo_actual DW 0
arbol DW 0
index_siguiente DW 0
comando DW ?
parametro DW ?

.code  ; Segmento de código
loop_start: 
	; Inicialización del bucle
	; Leer comando del PUERTO_ENTRADA
    IN  BX, [PUERTO_ENTRADA]
    MOV [comando], BX
    OUT [PUERTO_LOG], [COD_CERO]
    OUT [PUERTO_LOG], BX

    ; Comenzar a procesar el switch case
    CMP BX, 1
    JE cambiarModoCase
    CMP BX, 2
    JE agregarNodoCase
    ; ... agregar todos los otros casos del switch aquí ...

    ; Caso predeterminado si no se cumple ninguna condición anterior
    JMP defaultCase

cambiarModoCase:
    IN [parametro], [PUERTO_ENTRADA]
    MOV BX, [parametro]
    MOV DX, [PUERTO_LOG]
    OUT DX, AX
    OUT DX, BX
    CMP BX, [MODO_ESTATICO]
    JE setModoEstatico
    CMP BX, [MODO_DINAMICO]
    JE setModoDinamico
    ; Si no es ninguno de los modos válidos, envía error
    OUT [PUERTO_LOG], [COD_DOS]
    JMP endCase

setModoEstatico:
    MOV [modo_actual], [MODO_ESTATICO]
    CALL inicializarMemoria
    JMP endCase

setModoDinamico:
    MOV [modo_actual], [MODO_DINAMICO]
    CALL inicializarMemoria
    JMP endCase

agregarNodoCase:
    ; Implementar lógica similar aquí

defaultCase:
    OUT [PUERTO_LOG], [COD_UNO]

endCase:
    ; Terminar el bucle y volver a empezar
    JMP loop_start

; ... otras funciones ...

inicializarMemoria PROC
	RET
inicializarMemoria ENDP

.ports ; Definición de puertos
20: 1,2,3

; 200: 1,2,3  ; Ejemplo puerto simple
; 201:(100h,10),(200h,3),(?,4)  ; Ejemplo puerto PDDV

.interrupts ; Manejadores de interrupciones
