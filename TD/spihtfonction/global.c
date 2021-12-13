/* fichier global.c  */
#include <stdio.h>
#include <setjmp.h>
#include "mestypes.h"

/*
LIG,COL dimension de l'image basse r�solution (nombres pairs)
*/
int LIG,COL;
/*
dimension de l'image compl�te : LIGT=LIG*2^EXPOS  COLT=COL*2^EXPOS 
dimension de l'image moiti� : LIG2=LIG*2^(EXPOS-1)  COL2=COL*2^(EXPOS-1)
*/
int EXPOS;
int LIGT,COLT,LIG2,COL2;
/*
Pointeurs sur les listes d�crites dans la publi :
LIP : list of insignificant pixels
LIS : list of insignificant sets
LSP : list of significant pixels
*/ 
POINT ** Listes;
int * IndexListes;
/*
coeff : coefficients initiaux
coeffq : coefficients quantifi�s
*/
IMAGE * coeff;
IMAGE * coeffq;
/*
la variable maxcoeff sert � calculer le maximum
de la valeur absolue des coefficients pour un set donn�
*/
IMAGE maxcoeff;
/*
valeur le la longueur de train binaire
arbitrairement fix�.
*/
int LongueurTrainBinaire;				   
jmp_buf retour;
int Compteur;
FILE * fbin;

