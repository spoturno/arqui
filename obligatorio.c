#include <stdio.h>
#include <stdlib.h>

typedef struct Nodo
{
    int valor;
    struct Nodo *izq;
    struct Nodo *der;
} Nodo;

Nodo *crearNodo(int valor)
{
    Nodo *nuevo = (Nodo *)malloc(sizeof(Nodo));
    nuevo->valor = valor;
    nuevo->izq = NULL;
    nuevo->der = NULL;
    return nuevo;
}

Nodo *insertar(Nodo *raiz, int valor)
{
    if (raiz == NULL)
    {
        return crearNodo(valor);
    }
    if (valor < raiz->valor)
    {
        raiz->izq = insertar(raiz->izq, valor);
    }
    else if (valor > raiz->valor)
    {
        raiz->der = insertar(raiz->der, valor);
    }
    return raiz;
}

int altura(Nodo *raiz)
{
    if (raiz == NULL)
    {
        return 0;
    }
    int izq = altura(raiz->izq);
    int der = altura(raiz->der);
    return (izq > der ? izq : der) + 1;
}

int suma(Nodo *raiz)
{
    if (raiz == NULL)
    {
        return 0;
    }
    return raiz->valor + suma(raiz->izq) + suma(raiz->der);
}

void imprimir(Nodo *raiz)
{
    if (raiz != NULL)
    {
        imprimir(raiz->izq);
        printf("%d ", raiz->valor);
        imprimir(raiz->der);
    }
}

int main()
{
    Nodo *raiz = NULL;
    raiz = insertar(raiz, 3);
    raiz = insertar(raiz, 2);
    raiz = insertar(raiz, 5);
    raiz = insertar(raiz, 4);

    printf("Altura del árbol: %d\n", altura(raiz));
    printf("Suma de los valores del árbol: %d\n", suma(raiz));
    printf("Valores del árbol: ");
    imprimir(raiz);
    printf("\n");

    return 0;
}
