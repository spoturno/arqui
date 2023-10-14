.data  ; Segmento de datos
PUERTO_ENTRADA DW 20
PUERTO_SALIDA DW 21
PUERTO_LOG DW 22
AREA_MEMORIA DW 2048
NODO_VACIO DW 0x8000

modo_actual DW ?
arbol DW 2048 DUP(0x8000)
index_siguiente DW 0

.code  ; Segmento de código
loop_start: ;Inicialización del bucle
	; Leer comando del PUERTO_ENTRADA
    CALL in
    MOV comando, BX
    MOV DX, PUERTO_LOG
    OUT DX, AX
    OUT DX, BX

    ; Comenzar a procesar el switch case
    CMP BX, 1
    JE cambiarModoCase
    CMP BX, 2
    JE agregarNodoCase
    ; ... agregar todos los otros casos del switch aquí ...

    ; Caso predeterminado si no se cumple ninguna condición anterior
    JMP defaultCase

cambiarModoCase:
    CALL in
    MOV parametro, BX
    MOV DX, PUERTO_LOG
    OUT DX, AX
    OUT DX, BX
    CMP BX, MODO_ESTATICO
    JE setModoEstatico
    CMP BX, MODO_DINAMICO
    JE setModoDinamico
    ; Si no es ninguno de los modos válidos, envía error
    MOV AX, 2
    OUT PUERTO_LOG, AX
    JMP endCase

setModoEstatico:
    MOV modo_actual, MODO_ESTATICO
    CALL inicializarMemoria
    JMP endCase

setModoDinamico:
    MOV modo_actual, MODO_DINAMICO
    CALL inicializarMemoria
    JMP endCase

agregarNodoCase:
    ; Implementar lógica similar aquí

defaultCase:
    MOV AX, 1
    OUT PUERTO_LOG, AX

endCase:
    ; Terminar el bucle y volver a empezar
    JMP loop_start

in PROC
    ; Implementación simplificada de la función in
    MOV AH, 01h ; Función para leer carácter
    INT 21h     ; Interrupción de DOS
    SUB AL, '0' ; Convertir de char a int
    MOV BX, AX  ; Supongamos que BX será el registro de retorno
    RET
in ENDP

; ... otras funciones ...

.ports ; Definición de puertos
; 200: 1,2,3  ; Ejemplo puerto simple
; 201:(100h,10),(200h,3),(?,4)  ; Ejemplo puerto PDDV

.interrupts ; Manejadores de interrupciones
; Ejemplo interrupcion del timer
;!INT 8 1
;  iret
;!ENDINT
