#include <stdio.h>

#define PUERTO_ENTRADA 20
#define PUERTO_SALIDA 21
#define PUERTO_LOG 22
#define AREA_MEMORIA 2048
#define NODO_VACIO 0x8000

typedef enum
{
    MODO_ESTATICO,
    MODO_DINAMICO
} ModoAlmacenamiento;

short in(unsigned short puerto);
void out(unsigned short puerto, short valor);

/* Metodo auxiliares */
void insertarDinamico(unsigned short index, short num);
void insertarEstatico(unsigned short index, short num);
unsigned short sumaEstatico(unsigned short index);
unsigned short sumaDinamico(unsigned short index);
unsigned short alturaEstatico(unsigned short index);
unsigned short alturaDinamico(unsigned short index);
void imprimirEstatico(unsigned short index, int orden);
void imprimirDinamico(unsigned short index, int orden);
void imprimirMemoriaEstatico(short N);
void imprimirMemoriaDinamico(short N);
void inicializarMemoria();

/* Funciones Principales */
void insertar(short num);
void cambiarModo(ModoAlmacenamiento modo);
void imprimir(int orden);
void imprimirMemoria(short N);
unsigned short suma();
unsigned short altura();

ModoAlmacenamiento modo_actual;
short arbol[AREA_MEMORIA];
unsigned short index_siguiente = 0;

int main() {
    short comando, parametro;

    while (1) {
        // Leer comando del PUERTO_ENTRADA
        comando = in(PUERTO_ENTRADA);
        out(PUERTO_LOG, 64);
        out(PUERTO_LOG, comando);

        switch (comando) {
            case 1: // Cambiar Modo
                parametro = in(PUERTO_ENTRADA);
                out(PUERTO_LOG, parametro);
                if (parametro == MODO_ESTATICO) {
                    cambiarModo(parametro);
                    out(PUERTO_LOG, 0);
                } else if (parametro == MODO_DINAMICO) {
                    cambiarModo(parametro);
                    out(PUERTO_LOG, 0);
                } else {
                    out(PUERTO_LOG, 2); // Parámetro inválido
                }
                break;

            case 2: // Agregar Nodo
                parametro = in(PUERTO_ENTRADA);
                out(PUERTO_LOG, parametro);
                if (parametro  <= NODO_VACIO) {
                    out(PUERTO_LOG, 3); // Parámetro inválido
                    break;
                }
                insertar(parametro);
                out(PUERTO_LOG, 0);
                break;

            case 3: // Calcular Altura
                out(PUERTO_SALIDA, altura());
                out(PUERTO_LOG, 0);
                break;

            case 4: // Calcular Suma
                out(PUERTO_SALIDA, suma());
                out(PUERTO_LOG, 0);
                break;

            case 5: // Imprimir Árbol
                parametro = in(PUERTO_ENTRADA);
                out(PUERTO_LOG, parametro);
                imprimir(parametro);
                out(PUERTO_LOG, 0);
                break;

            case 6: // Imprimir Memoria
                parametro = in(PUERTO_ENTRADA);
                out(PUERTO_LOG, parametro);
                imprimirMemoria(parametro);
                out(PUERTO_LOG, 0);
                break;

            case 255: // Detener programa
                out(PUERTO_LOG, 0);
                return 0;

            default:
                out(PUERTO_LOG, 1); // Comando inválido
                break;
        }
    }

    return 0;
}

void inicializarMemoria() {
    for (unsigned short i = 0; i < AREA_MEMORIA; i++) {
        arbol[i] = NODO_VACIO;
    }
    index_siguiente = 0;
}

void cambiarModo(ModoAlmacenamiento modo) {
    modo_actual = modo;
    inicializarMemoria();
}

short in(unsigned short puerto) {
    short valor;
    scanf("%d", &valor);
    return valor;
}

void out(unsigned short puerto, short valor) {
    printf("%d%d", puerto, valor);
}

void insertarEstatico(unsigned short index, short num) {
    if (index >= AREA_MEMORIA) {
        out(PUERTO_LOG, 4);
        return; // Fuera de rango
    }

    if (arbol[index] == NODO_VACIO) {
        arbol[index] = num;
        return;
    }

    if (num < arbol[index]) {
        insertarEstatico(2 * index + 1, num); // Hijo izquierdo
    } else if (num > arbol[index]) {
        insertarEstatico(2 * index + 2, num); // Hijo derecho
    }
}

void insertarDinamico(unsigned short index, short num) {
    if (3 * index_siguiente >= AREA_MEMORIA) {
        out(PUERTO_LOG, 4);
        return; // Fuera de rango
    }

    if (arbol[3 * index] == NODO_VACIO) {
        arbol[3 * index] = num;
        index_siguiente++;
        return;
    }

    if (num < arbol[3 * index]) {
        if (arbol[3 * index + 1] == NODO_VACIO) {
            arbol[3 * index + 1] = index_siguiente;
            insertarDinamico(index_siguiente, num);
        } else {
            insertarDinamico(arbol[3 * index + 1], num); // Hijo izquierdo
        }

    } else if (num > arbol[3 * index]) {
        if (arbol[3 * index + 2] == NODO_VACIO) {
            arbol[3 * index + 2] = index_siguiente;
            insertarDinamico(index_siguiente, num);
        } else {
            insertarDinamico(arbol[3 * index + 2], num); // Hijo derecho
        }
    }
    // Si el número ya existe, simplemente retornamos y no hacemos nada
}

unsigned short alturaEstatico(unsigned short index) {
    if (index >= AREA_MEMORIA) {
        return 0;
    }

    if (arbol[index] == NODO_VACIO){
        return 0;
    }

    unsigned short izq = alturaEstatico(2 * index + 1);
    unsigned short der = alturaEstatico(2 * index + 2);

    return 1 + ((izq > der) ? izq : der);
}

unsigned short alturaDinamico(unsigned short index) {
    if (index == NODO_VACIO) {
        return 0;
    }
    
    if (3 * index >= AREA_MEMORIA) {
        return 0;
    }

    if (arbol[3 * index] == NODO_VACIO) {
        return 0;
    }

    unsigned short izq = alturaDinamico(arbol[3 * index + 1]);
    unsigned short der = alturaDinamico(arbol[3 * index + 2]);

    return 1 + ((izq > der) ? izq : der);
}

unsigned short sumaEstatico(unsigned short index) {
    if (index >= AREA_MEMORIA){
        return 0;
    }

    if (arbol[index] == NODO_VACIO) {
        return 0;
    }

    return arbol[index] + sumaEstatico(2 * index + 1) + sumaEstatico(2 * index + 2);
}

unsigned short sumaDinamico(unsigned short index) {
    if (3 * index >= AREA_MEMORIA) {
        return 0;
    }

    if (arbol[3 * index] == NODO_VACIO) {
        return 0;
    }

    unsigned short sumIzq = arbol[3 * index + 1] != NODO_VACIO ? sumaDinamico(arbol[3 * index + 1]) : 0;
    unsigned short sumDer = arbol[3 * index + 2] != NODO_VACIO ? sumaDinamico(arbol[3 * index + 2]) : 0;

    return arbol[3 * index] + sumIzq + sumDer;
}

void imprimirEstatico(unsigned short index, int orden) {
    if (index >= AREA_MEMORIA) {
        return;
    }

    if(arbol[index] == NODO_VACIO) {
        return;
    }

    if (orden == 0) {
        imprimirEstatico(2 * index + 1, orden);
        printf("%d ", arbol[index]);
        imprimirEstatico(2 * index + 2, orden);
    } else {
        imprimirEstatico(2 * index + 2, orden);
        printf("%d ", arbol[index]);
        imprimirEstatico(2 * index + 1, orden);
    }
}

void imprimirDinamico(unsigned short index, int orden) {
    if (3 * index >= AREA_MEMORIA) {
        return;
    }

    if (arbol[3 * index] == NODO_VACIO) {
        return;
    }

    if (orden == 0) {
        if (arbol[3 * index + 1] != NODO_VACIO) {
            imprimirDinamico(arbol[3 * index + 1], orden);
        }

        printf("%d ", arbol[3 * index]);

        if (arbol[3 * index + 2] != NODO_VACIO) {
            imprimirDinamico(arbol[3 * index + 2], orden);
        }
            
    } else {
        if (arbol[3 * index + 2] != NODO_VACIO) {
            imprimirDinamico(arbol[3 * index + 2], orden);
        }

        printf("%d ", arbol[3 * index]);

        if (arbol[3 * index + 1] != NODO_VACIO) {
            imprimirDinamico(arbol[3 * index + 1], orden);
        }
    }
}

/* Funciones Principales */

void insertar(short num) {
    if (modo_actual == MODO_ESTATICO) {
        insertarEstatico(0, num);
    } else {
        insertarDinamico(0, num);
    }
}

unsigned short altura() {
    if (modo_actual == MODO_ESTATICO) {
        return alturaEstatico(0);
    } else {
        return alturaDinamico(0);
    }
}

unsigned short suma() {
    if (modo_actual == MODO_ESTATICO) {
        return sumaEstatico(0);
    } else {
        return sumaDinamico(0);
    }
}

void imprimir(int orden) {
    if (modo_actual == MODO_ESTATICO) {
        imprimirEstatico(0, orden);
    } else {
        imprimirDinamico(0, orden);
    }
    printf("\n");
}

void imprimirMemoria(short N) {
    if (N > AREA_MEMORIA) {
        out(PUERTO_LOG, 4);
        return; // Fuera de rango
    }

    if (modo_actual == MODO_ESTATICO) {
        N = 1 * N; // en assembly seria N = 2 * N
    } else {
        N = 3 * N; // en assembly seria N = 6 * N
    }

    short index = 0;
    while (index < N) { // En 8086 seria index < 3*N
        printf("%d ", arbol[index]);
        index++;
    }
}