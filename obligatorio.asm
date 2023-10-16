.data  ; Segmento de datos
#define ES 0x0240 ; cambio inicio de ES a siguiente pagina de direcciones

PUERTO_ENTRADA EQU 20
PUERTO_SALIDA EQU 21
PUERTO_LOG EQU 22

AREA_MEMORIA DW 3
NODO_VACIO DW 0x8000

MODO_ESTATICO DW 0
MODO_DINAMICO DW 1


LECTURA_COMANDO EQU 64
EXITO EQU 0 ; si la operación se pudo realizar con éxito 
COMANDO_INVALIDO EQU 1 ; si no se reconoce el comando (comando inválido)
PARAMETRO_INVALIDO EQU 2 ; si el valor de algún parámetro recibido es inválido
FUERA_DE_RANGO EQU 4 ; si al agregar un nodo se intenta escribir fuera del área de memoria
NODO_YA_EXISTE EQU 8 ; si el nodo a agregar ya se encuentra en el árbol.

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
	MOV AX, LECTURA_COMANDO
	OUT DX, AX ; imprime el codigo 64 en puerto log

	MOV AX, [comando]
	OUT DX, AX ; imprime el comando en puerto log

	; Comenzar a procesar el switch case

    CMP AX, 1
    JE cambiarModoCase

	CMP AX, 2
	JE insertarNodoCase

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
	MOV AX, PARAMETRO_INVALIDO
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


insertarNodoCase:
    IN AX, PUERTO_ENTRADA ; leo parametro - valor de nodo a insertar
	MOV CX, AX ; utilizo CX para guardar parametro
    MOV DX, PUERTO_LOG
    OUT DX, AX ; imprime el parametro en puerto log

    ; Comprobamos el modo_actual y llamamos al procedimiento adecuado
	MOV DX, [modo_actual]	

    CMP DX, [MODO_ESTATICO]
    JE insertarNodoEstaticoCase

    CMP DX, [MODO_DINAMICO]
    JE insertarNodoDinamicoCase

    JMP endCase

insertarNodoEstaticoCase:
	CALL insertarEstatico
	JMP endCase

insertarNodoDinamicoCase:
	CALL insertarDinamico
	JMP endCase

defaultCase:
	;MOV DX, COD_UNO
    ;OUT [PUERTO_LOG], COD_UNO

endCase:
    JMP loop_start ; Terminar el bucle y volver a empezar

stopCase:
	RET

; ... otras rutinas ...

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

insertarEstatico PROC ; CX es el valor del numero nuevo a insertar
    PUSH BX
    PUSH SI
    PUSH DX
    PUSH AX

    XOR SI, SI ; SI será nuestro índice actual en el árbol

insertarEstaticoLoop:
    ; Comprobación de si el índice está fuera del rango de AREA_MEMORIA
    CMP SI, [AREA_MEMORIA]
    JAE fueraDeRango

    ; Cargamos el valor actual en el árbol en DX
    MOV DX, ES:[SI]

    ; Si el nodo actual está vacío, insertamos el valor y salimos
    CMP DX, [NODO_VACIO]
    JE insertarAqui

    ; Si el valor es menor que el actual, vamos al hijo izquierdo
    CMP CX, DX
    JB hijoIzquierdo

    ; Si el valor es mayor que el actual, vamos al hijo derecho
    JA hijoDerecho

    ; Si no es menor ni mayor, es igual. En ese caso, el valor ya está en el árbol. Salimos
    POP AX
    POP DX
    POP SI
    POP BX
    RET

hijoIzquierdo:
    ; Calculamos la dirección para el hijo izquierdo: 2*SI + 2
    MOV AX, 2
    MUL SI
    ADD AX, 2 ; Sumamos 2 pues es nodo izquierdo
    MOV SI, AX
    JMP insertarEstaticoLoop

hijoDerecho:
    ; Calculamos la dirección para el hijo derecho: 2*SI + 4
    MOV AX, 2
    MUL SI
    ADD AX, 4 ; Sumamos 2 pues es nodo derecho
    MOV SI, AX
    JMP insertarEstaticoLoop

insertarAqui:
    ; Insertamos el valor en el árbol
    MOV ES:[SI], CX
    POP AX
    POP DX
    POP SI
    POP BX
    RET

fueraDeRango:
    ; Manejo de error: intento de escribir fuera de AREA_MEMORIA
    MOV DX, PUERTO_LOG
    MOV AX, FUERA_DE_RANGO
    OUT DX, AX
    POP AX
    POP DX
    POP SI
    POP BX
    RET

insertarEstatico ENDP


insertarDinamico PROC
	RET
insertarDinamico ENDP


.ports 	; Definición de puertos
20: 1, 0, 2, 7

; 200: 1,2,3  ; Ejemplo puerto simple
; 201:(100h,10),(200h,3),(?,4)  ; Ejemplo puerto PDDV

.interrupts ; Manejadores de interrupciones
