.data  ; Segmento de datos
PEPE DW 0x123

.code  ; Segmento de código
MOV AX, [PEPE]
OUT 123, AX

.ports ; Definición de puertos
; 200: 1,2,3  ; Ejemplo puerto simple
; 201:(100h,10),(200h,3),(?,4)  ; Ejemplo puerto PDDV

.interrupts ; Manejadores de interrupciones
; Ejemplo interrupcion del timer
;!INT 8 1
;  iret
;!ENDINT