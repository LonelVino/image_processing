#define _CRT_SECURE_NO_DEPRECATE

#include <stdio.h>
#include "constant.h"

char noment[NOM];
char nomsor[NOM];
char nomcod[NOM];
int dimvec,M,dico,numiter;

FILE * ent,* sor,* cod;

float ** vecteurs;
float ** vecteurs_classes;
int * index_classes;
int * popul_classes;
float ** vecteurs_final;
int * index_final;
int * popul_final;
int etape;
double energie;
double energieminimale;

TRI * buftri;

