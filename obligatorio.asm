.data  ; Segmento de datos
#define ES 0x0240 ; cambio inicio de ES a siguiente pagina de direcciones

PUERTO_ENTRADA EQU 20
PUERTO_SALIDA EQU 21
PUERTO_LOG EQU 22

OFFSET_MAXIMO DW 198 ; OFFSET_MAXIMO = (AREA_MEMORIA - 1) * 2
AREA_MEMORIA DW 100
NODO_VACIO DW 0x8000

MODO_ESTATICO DW 0
MODO_DINAMICO DW 1


LECTURA_COMANDO EQU 64
EXITO EQU 0 ; si la operación se pudo realizar con éxito 
COMANDO_INVALIDO EQU 1 ; si no se reconoce el comando (comando inválido)
PARAMETRO_INVALIDO EQU 2 ; si el valor de algún parámetro recibido es inválido
FUERA_DE_RANGO EQU 4 ; si al agregar un nodo se intenta escribir fuera del área de memoria
NODO_YA_EXISTE EQU 8 ; si el nodo a agregar ya se encuentra en el árbol.

suma_total DW 22
modo_actual DW 0
index_siguiente DW 0
comando DW ?

.code  ; Segmento de código

; Inicialización del bucle
loop_start: 

	; Inicializacion de registros en 0
	XOR SI, SI
	
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

	CMP AX, 3
	JE calcularAlturaCase

	CMP AX, 4
	JE calcularSumaCase

	CMP AX, 5
	JE imprimirArbolCase

	CMP AX, 6
	JE imprimirMemoriaCase

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

calcularAlturaCase:
	XOR BX, BX ; Inicializo altura en BX en 0
	XOR SI, SI ; Inicializo SI en 0 por las dudas
	XOR DI, DI ; En DI se guardan valores temporales en las llamadas recursivas
	XOR DX, DX ; En DX se guardan valores temporales en las llamadas recursivas

	; Comprobamos el modo_actual y llamamos al procedimiento adecuado
	MOV DX, [modo_actual]	

    CMP DX, [MODO_ESTATICO]
    JE calcularAlturaEstatico

    CMP DX, [MODO_DINAMICO]
    JE calcularAlturaDinamico

    JMP endCase

calcularAlturaEstatico:
	CALL alturaEstatico

	MOV DX, PUERTO_SALIDA
	MOV AX, DI
	OUT DX, AX ; imprime la altura del arbol en el puerto salida

	MOV DX, PUERTO_LOG
	MOV AX, EXITO
	OUT DX, AX ; imprime el codigo 0 en puerto log

	JMP endCase

calcularAlturaDinamico:
	CALL alturaDinamico

	MOV DX, PUERTO_SALIDA
	MOV AX, DI
	OUT DX, AX ; imprime la altura del arbol en el puerto salida

	MOV DX, PUERTO_LOG
	MOV AX, EXITO
	OUT DX, AX ; imprime el codigo 0 en puerto log

	JMP endCase


calcularSumaCase:
	XOR BX, BX ; Inicializo altura en BX en 0
	XOR SI, SI ; Inicializo SI en 0 por las dudas
	XOR DI, DI ; En DI se guardan valores temporales en las llamadas recursivas
	XOR DX, DX ; En DX se guardan valores temporales en las llamadas recursivas

	MOV [suma_total], BX ; Inicializo Suma en 0

	; Comprobamos el modo_actual y llamamos al procedimiento adecuado
	MOV DX, [modo_actual]	

    CMP DX, [MODO_ESTATICO]
    JE calcularSumaEstatico

    CMP DX, [MODO_DINAMICO]
    JE calcularSumaDinamico

    JMP endCase
	
calcularSumaEstatico:
	CALL sumaEstatico
	
	; Imprimir en PUERTO_SALIDA valor de la suma
	MOV DX, PUERTO_SALIDA
	MOV AX, [suma_total]
	OUT DX, AX ; imprime la altura del arbol en el puerto salida

	; Imprimir en PUERTO_LOG codigo 0
	MOV DX, PUERTO_LOG
	MOV AX, EXITO
	OUT DX, AX ; imprime el codigo 0 en puerto log

	JMP endCase

calcularSumaDinamico:
	CALL sumaDinamico

	; Imprimir en PUERTO_SALIDA valor de la suma
	MOV DX, PUERTO_SALIDA
	MOV AX, [suma_total]
	OUT DX, AX ; imprime la altura del arbol en el puerto salida

	; Imprimir en PUERTO_LOG codigo 0
	MOV DX, PUERTO_LOG
	MOV AX, EXITO
	OUT DX, AX ; imprime el codigo 0 en puerto log

	JMP endCase
	
imprimirArbolCase:
	IN AX, PUERTO_ENTRADA ; leo parametro de orden
    MOV DX, PUERTO_LOG
    OUT DX, AX ; imprime el parametro en puerto log

	MOV DX, [modo_actual]	

    CMP DX, [MODO_ESTATICO]
    JE imprimirArbolEstatico

    CMP DX, [MODO_DINAMICO]
    JE imprimirArbolDinamico

    JMP endCase

imprimirArbolEstatico:
	CMP AX, 0
	JE imprimirArbolEstaticoAscendente

	CMP AX, 1
	JE imprimirArbolEstaticoDescendente

	; Si no es ninguno de los modos válidos, envía error
	MOV DX, PUERTO_LOG
    MOV AX, PARAMETRO_INVALIDO ; guardo en AX valor actual de arbol[index]
    OUT DX, AX
    JMP endCase
	
imprimirArbolEstaticoAscendente:
	CALL imprimirEstaticoAscendente
	MOV DX, PUERTO_LOG
    MOV AX, EXITO ; guardo en AX valor actual de arbol[index]
    OUT DX, AX
	JMP endCase

imprimirArbolEstaticoDescendente:
	CALL imprimirEstaticoDescendente
	MOV DX, PUERTO_LOG
    MOV AX, EXITO ; guardo en AX valor actual de arbol[index]
    OUT DX, AX
	JMP endCase

imprimirArbolDinamico:
	CMP AX, 0
	JE imprimirArbolDinamicoAscendente

	CMP AX, 1
	JE imprimirArbolDinamicoDescendente

	; Si no es ninguno de los modos válidos, envía error
	MOV DX, PUERTO_LOG
    MOV AX, PARAMETRO_INVALIDO ; guardo en AX valor actual de arbol[index]
    OUT DX, AX
    JMP endCase

imprimirArbolDinamicoAscendente:
	CALL imprimirDinamicoAscendente
	MOV DX, PUERTO_LOG
    MOV AX, EXITO ; guardo en AX valor actual de arbol[index]
    OUT DX, AX
	JMP endCase

imprimirArbolDinamicoDescendente:
	CALL imprimirDinamicoDescendente
	MOV DX, PUERTO_LOG
    MOV AX, EXITO ; guardo en AX valor actual de arbol[index]
    OUT DX, AX
	JMP endCase
	
imprimirMemoriaCase:
	IN AX, PUERTO_ENTRADA ; leo parametro - valor de nodo a insertar
	MOV CX, AX ; utilizo CX para guardar parametro
    MOV DX, PUERTO_LOG
    OUT DX, AX ; imprime el parametro en puerto log

    ; Comprobamos el modo_actual y llamamos al procedimiento adecuado
	MOV DX, [modo_actual]	

    CMP DX, [MODO_ESTATICO]
    JE imprimirMemoriaEstaticoCase

    CMP DX, [MODO_DINAMICO]
    JE imprimirMemoriaDinamicoCase

    JMP endCase

imprimirMemoriaEstaticoCase:
	ADD CX, CX ; CX = 2 * N para saber hasta donde imprimir
	SUB CX, 2 ; Ahora CX vale 2*N - 2 que es el index maximo
	CALL imprimirMemoria
	JMP endCase

imprimirMemoriaDinamicoCase:
	MOV AX, 6
	MUL CX ; AX = 6 * N para saber hasta donde imprimir
	MOV CX, AX ; CX = AX * 6
	SUB CX, 2 ; Ahora CX vale 6*N - 2 que es el index maximo
	CALL imprimirMemoria
	JMP endCase


defaultCase:
	MOV AX, COMANDO_INVALIDO
	MOV DX, PUERTO_LOG
	OUT DX, AX
	JMP endCase

endCase:
    JMP loop_start ; Terminar el bucle y volver a empezar

stopCase:
	MOV AX, EXITO
	MOV DX, PUERTO_LOG
	OUT DX, AX
	HLT



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
	MOV DX, PUERTO_LOG
	MOV AX, EXITO
	OUT DX, AX ; imprime el codigo EXITO en puerto log	
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

	XOR AX, AX
    XOR SI, SI ; SI será nuestro índice actual en el árbol
	XOR BX, BX ; BX sera nuestro comparador con AREA_MEMORIA

insertarEstaticoLoop:
    CMP BX, [AREA_MEMORIA] ; Comprobación de si el índice está fuera del rango de AREA_MEMORIA
    JAE fueraDeRangoEstatico

    
    MOV DX, ES:[SI] ; Cargamos el valor actual en el árbol en DX

    
    CMP DX, [NODO_VACIO] ; Si el nodo actual está vacío, insertamos el valor y salimos
    JE insertarAquiEstatico

    
    CMP CX, DX ; Si el valor es menor que el actual, vamos al hijo izquierdo
    JL hijoIzquierdoEstatico

    JG hijoDerechoEstatico ; Si el valor es mayor que el actual, vamos al hijo derecho

    ; Si no es menor ni mayor, es igual. En ese caso, el valor ya está en el árbol. Salimos
	MOV DX, PUERTO_LOG
    MOV AX, NODO_YA_EXISTE
    OUT DX, AX

    POP AX
    POP DX
    POP SI
    POP BX
    RET

hijoIzquierdoEstatico:
    ; Calculamos la dirección para el hijo izquierdo: 2*SI + 2
    MOV AX, 2
    MUL SI ; AX = SI*2
    ADD AX, 2 ; Sumamos 2 ya que es nodo izquierdo en memoria
    MOV SI, AX ; Asigno SI = 2*SI + 2

	MOV AX, 2
	MUL BX ; AX = BX * 2 
	ADD AX, 1 ; AX = AX + 1
	MOV BX, AX ; index real en array BX = BX*2 + 1 
	JMP insertarEstaticoLoop

hijoDerechoEstatico:
   ; Calculamos la dirección para el hijo izquierdo: 2*SI + 4
    MOV AX, 2
    MUL SI ; AX = SI*2
    ADD AX, 4 ; Sumamos 4 ya que es nodo izquierdo en memoria
    MOV SI, AX ; Asigno SI = 2*SI + 4

	MOV AX, 2
	MUL BX ; AX = BX * 2 
	ADD AX, 2 ; AX = BX*2 + 2
	MOV BX, AX ; index real en array BX = BX*2 + 2
    JMP insertarEstaticoLoop

insertarAquiEstatico:
    ; Insertamos el valor en el árbol
    MOV ES:[SI], CX

	MOV DX, PUERTO_LOG
	MOV AX, EXITO
	OUT DX, AX ; imprime el codigo EXITO en puerto log	

    POP AX
    POP DX
    POP SI
    POP BX
    RET

fueraDeRangoEstatico:
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
	PUSH BX
    PUSH SI
    PUSH DX
    PUSH AX

	XOR AX, AX
    XOR SI, SI ; SI será nuestro index actual en el árbol
	XOR BX, BX ; BX sera nuestro comparador con OFFSET_MAXIMO

insertarDinamicoLoop:
	; Comprobacion de si el index_siguiente esta fuera de rango de OFFSET_MAXIMO
	MOV BX, [index_siguiente]
	MOV AX, BX
	MOV DX, 6
	MUL DX ; Multiplico AX por DX = 6
	MOV BX, AX ; BX = 6 * index_siguiente
	CMP BX, [OFFSET_MAXIMO] 
    JAE fueraDeRangoDinamico

    ; Cargo en DX el valor del padre ES[6*SI]
	MOV AX, SI
	MOV BX, 6 ; Guardo en BX el valor 6 para multiplicar
	MUL BX ; Multiplico AX por 6
	MOV SI, AX ; Asigno SI = 6*SI
	
    MOV DX, ES:[SI] ; Cargamos el valor actual en el árbol en DX

    
    CMP DX, [NODO_VACIO] ; Si el nodo actual está vacío, insertamos el valor y salimos
    JE insertarAquiDinamico

    
    CMP CX, DX ; Si el valor es menor que el actual, vamos al hijo izquierdo
    JL hijoIzquierdoDinamico

    JG hijoDerechoDinamico ; Si el valor es mayor que el actual, vamos al hijo derecho

    ; Si no es menor ni mayor, es igual. En ese caso, el valor ya está en el árbol. Salimos
	MOV DX, PUERTO_LOG
    MOV AX, NODO_YA_EXISTE
    OUT DX, AX

    POP AX
    POP DX
    POP SI
    POP BX
    RET

hijoIzquierdoDinamico:
	ADD SI, 2 ; actualmente SI es para acceder arbol[6*index+2]
	MOV DX, ES:[SI] ; guardo el valor del indice del izquierdo del padre
	
	CMP DX, [NODO_VACIO]
	JE hijoIzquierdoVacio

	MOV SI, ES:[SI] ; index = arbol[6*index + 2] para llamada recursiva
	JMP insertarDinamicoLoop

hijoIzquierdoVacio:
	MOV AX, [index_siguiente]
	MOV ES:[SI], AX
	MOV SI, AX ; index = index_siguiente para llamada recursiva
	JMP insertarDinamicoLoop
	
hijoDerechoDinamico:
	ADD SI, 4 ; actualmente SI es para acceder arbol[6*index + 4]
	MOV DX, ES:[SI]

	CMP DX, [NODO_VACIO]
	JE hijoDerechoVacio

	MOV SI, ES:[SI] ; index = arbol[6*index + 4] para llamada recursiva
	JMP insertarDinamicoLoop

hijoDerechoVacio:
	MOV AX, [index_siguiente]
	MOV ES:[SI], AX
	MOV SI, AX ; index = index_siguiente para llamada recursiva
	JMP insertarDinamicoLoop

insertarAquiDinamico:
	MOV ES:[SI], CX ; Cargo el valor del nuevo nodo en ES
	MOV AX, [index_siguiente] ; Obtengo el valor de index_siguiente actual
	INC AX ; index_siguiente++
	MOV [index_siguiente], AX ; guardo el nuevo valor de index_siguiente

	MOV DX, PUERTO_LOG
	MOV AX, EXITO
	OUT DX, AX ; imprime el codigo EXITO en puerto log	

    POP AX
    POP DX
    POP SI
    POP BX
    RET

fueraDeRangoDinamico:
	; Manejo de error: intento de escribir fuera de OFFSET_MAXIMO
    MOV DX, PUERTO_LOG
    MOV AX, FUERA_DE_RANGO
    OUT DX, AX

    POP AX
    POP DX
    POP SI
    POP BX
    RET
insertarDinamico ENDP


imprimirMemoria PROC
	PUSH SI
	PUSH AX
	PUSH DX
	
	ADD CX, CX ; CX = 2 * N para saber hasta donde imprimir
	SUB CX, 2 ; Ahora CX vale 2*N - 2 que es el index maximo
	XOR SI, SI ; inicializo SI en 0 para direccionar
	
imprimirMemLoop:
	CMP SI, CX
	JE imprimirMemEnd
	
    MOV DX, PUERTO_SALIDA
    MOV AX, ES:[SI] ; guardo en AX valor actual de arbol[index]
    OUT DX, AX
	
	ADD SI, 2 ; index = index + 2
	JMP imprimirMemLoop

imprimirMemEnd:
	MOV DX, PUERTO_LOG
    MOV AX, EXITO ; guardo en AX valor actual de arbol[index]
    OUT DX, AX

	POP DX
	POP AX
	POP SI
	RET
imprimirMemoria ENDP


alturaEstatico PROC
	CMP SI, [AREA_MEMORIA]
	JAE retornoCeroEstatico

	MOV DX, ES:[SI]
	
	CMP DX, [NODO_VACIO]
	JE retornoCeroEstatico

	MOV AX, 2
	MUL SI
	MOV SI, AX

	; Obtener altura de hijo izquierdo
	PUSH SI 
	ADD SI, 2
	CALL alturaEstatico
	POP SI
	PUSH DI
	
	; Obtener altura de hijo derecho
	ADD SI, 4
	CALL alturaEstatico
	POP BX

	; Comprobar cual es la altura mayor y sumar
	CMP DI, BX
	JGE alturaIzqEsMayorOIgual
	MOV DI, BX

alturaIzqEsMayorOIgual:
	INC DI
	RET

retornoCeroEstatico:
	XOR DI, DI
	RET	

alturaEstatico ENDP



alturaDinamico PROC
	
	CMP SI, [NODO_VACIO]
	JE retornoCeroDinamico

	MOV AX, 6
	MUL SI
	MOV SI, AX

	CMP SI, [AREA_MEMORIA]
	JAE retornoCeroDinamico

	MOV DX, ES:[SI]
	
	CMP DX, [NODO_VACIO]
	JE retornoCeroDinamico

	; Obtener altura de hijo izquierdo
	PUSH SI 
	MOV SI, ES:[SI+2]
	CALL alturaDinamico
	POP SI
	PUSH DI
	
	; Obtener altura de hijo derecho
	MOV SI, ES:[SI+4]
	CALL alturaDinamico
	POP BX

	; Comprobar cual es la altura mayor y sumar
	CMP DI, BX
	JGE alturaIzqEsMayorOIgualDinamico
	MOV DI, BX

alturaIzqEsMayorOIgualDinamico:
	INC DI
	RET

retornoCeroDinamico:
	XOR DI, DI
	RET	

alturaDinamico ENDP



imprimirEstaticoAscendente PROC
	CMP SI, [AREA_MEMORIA]
	JAE endImprimirArbolEA
	
	MOV DX, ES:[SI]
	CMP DX, [NODO_VACIO]
	JE endImprimirArbolEA

	PUSH SI ; Preservo valor de SI

	; Viajo hacia el nodo izquierdo (2*SI + 2)
	MOV AX, 2
	MUL SI
	MOV SI, AX
	ADD SI, 2
	CALL imprimirEstaticoAscendente
	POP SI ; Recupero valor anterior de SI
	
	MOV DX, PUERTO_SALIDA
    MOV AX, ES:[SI] ; guardo en AX valor actual de arbol[index]
    OUT DX, AX

	PUSH SI ; Preservo valor de SI

	; Viajo hacia el nodo izquierdo (2*SI + 4)
	MOV AX, 2
	MUL SI
	MOV SI, AX
	ADD SI, 4
	CALL imprimirEstaticoAscendente
	POP SI ; Recupero valor anterior de SI

endImprimirArbolEA:
	RET
imprimirEstaticoAscendente ENDP


imprimirEstaticoDescendente PROC
	CMP SI, [AREA_MEMORIA]
	JAE endImprimirArbolED
	
	MOV DX, ES:[SI]
	CMP DX, [NODO_VACIO]
	JE endImprimirArbolED

	PUSH SI ; Preservo valor de SI

	; Viajo hacia el nodo izquierdo (2*SI + 2)
	MOV AX, 2
	MUL SI
	MOV SI, AX
	ADD SI, 4
	CALL imprimirEstaticoDescendente
	POP SI ; Recupero valor anterior de SI
	
	MOV DX, PUERTO_SALIDA
    MOV AX, ES:[SI] ; guardo en AX valor actual de arbol[index]
    OUT DX, AX

	PUSH SI ; Preservo valor de SI

	; Viajo hacia el nodo izquierdo (2*SI + 4)
	MOV AX, 2
	MUL SI
	MOV SI, AX
	ADD SI, 2
	CALL imprimirEstaticoDescendente
	POP SI ; Recupero valor anterior de SI

endImprimirArbolED:
	RET
imprimirEstaticoDescendente ENDP


imprimirDinamicoDescendente PROC
	CMP SI, [NODO_VACIO]
	JE endImprimirArbolDD

	MOV AX, 6
	MUL SI
	MOV SI, AX

	CMP SI, [AREA_MEMORIA]
	JAE endImprimirArbolDD

	MOV DX, ES:[SI]
	CMP DX, [NODO_VACIO]
	JE endImprimirArbolDA

	PUSH SI ; Preservo valor de SI

	; Viajo hacia el nodo izquierdo (6*SI + 4)
	MOV SI, ES:[SI+4]
	CALL imprimirDinamicoDescendente
	POP SI ; Recupero valor anterior de SI
	
	MOV DX, PUERTO_SALIDA
    MOV AX, ES:[SI] ; guardo en AX valor actual de arbol[index]
    OUT DX, AX

	PUSH SI ; Preservo valor de SI

	; Viajo hacia el nodo izquierdo (2*SI + 2)
	MOV SI, ES:[SI+2]
	CALL imprimirDinamicoDescendente
	POP SI ; Recupero valor anterior de SI

endImprimirArbolDD:
	RET
imprimirDinamicoDescendente ENDP



imprimirDinamicoAscendente PROC
	CMP SI, [NODO_VACIO]
	JE endImprimirArbolDA

	MOV AX, 6
	MUL SI
	MOV SI, AX

	CMP SI, [AREA_MEMORIA]
	JAE endImprimirArbolDA

	MOV DX, ES:[SI]
	CMP DX, [NODO_VACIO]
	JE endImprimirArbolDA

	PUSH SI ; Preservo valor de SI

	; Viajo hacia el nodo izquierdo (6*SI + 4)
	MOV SI, ES:[SI+2]
	CALL imprimirDinamicoAscendente
	POP SI ; Recupero valor anterior de SI
	
	MOV DX, PUERTO_SALIDA
    MOV AX, ES:[SI] ; guardo en AX valor actual de arbol[index]
    OUT DX, AX

	PUSH SI ; Preservo valor de SI

	; Viajo hacia el nodo izquierdo (2*SI + 2)
	MOV SI, ES:[SI+4]
	CALL imprimirDinamicoAscendente
	POP SI ; Recupero valor anterior de SI

endImprimirArbolDA:
	RET
imprimirDinamicoAscendente ENDP


sumaEstatico PROC
	CMP SI, [AREA_MEMORIA]
	JAE retornoSumaCeroEstatico

	MOV DX, ES:[SI]
	
	CMP DX, [NODO_VACIO]
	JE retornoSumaCeroEstatico

	MOV AX, [suma_total]
	ADD AX, ES:[SI]
	MOV [suma_total], AX

	MOV AX, 2
	MUL SI
	MOV SI, AX

	; Obtener altura de hijo izquierdo
	PUSH SI 
	ADD SI, 2
	CALL sumaEstatico
	POP SI
	
	PUSH SI
	; Obtener altura de hijo derecho
	ADD SI, 4
	CALL sumaEstatico
	POP SI

	RET

retornoSumaCeroEstatico:
	RET	

sumaEstatico ENDP

sumaDinamico PROC
	CMP SI, [NODO_VACIO]
	JE retornoSumaCeroDinamico

	MOV AX, 6
	MUL SI
	MOV SI, AX

	CMP SI, [AREA_MEMORIA]
	JAE retornoSumaCeroDinamico

	MOV DX, ES:[SI]
	CMP DX, [NODO_VACIO]
	JE retornoSumaCeroDinamico

	; Sumo el valor actual del arbol[index] a suma_total
	MOV AX, [suma_total] ; guardo la suma_total actual
	ADD AX, ES:[SI] ; suma_total + arbol[index]
	MOV [suma_total], AX ; reasigno suma_total

	; Obtener altura de hijo izquierdo
	PUSH SI 
	MOV SI, ES:[SI+2]
	CALL sumaDinamico
	POP SI
	
	PUSH SI
	; Obtener altura de hijo derecho
	MOV SI, ES:[SI+4]
	CALL sumaDinamico
	POP SI

	RET

retornoSumaCeroDinamico:
	RET	

sumaDinamico ENDP
	


.ports 	; Definición de puertos
20: 1,0,2,100,2,200,2,50,2,30,2,150,4,1,1,2,102,2,202,2,52,2,32,2,152,4,255

; 200: 1,2,3  ; Ejemplo puerto simple
; 201:(100h,10),(200h,3),(?,4)  ; Ejemplo puerto PDDV

.interrupts ; Manejadores de interrupciones
