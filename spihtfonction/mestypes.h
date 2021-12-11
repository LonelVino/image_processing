/* fichier mestypes.h */


typedef struct point
{
	int lig,col;
	char nature;  /*vaut une des constantes définies à la fin de ce fichier*/
}
POINT;

typedef float IMAGE;

/*
les différents types de points :
Na : non affecté
Ptprec : point isolé insére lors du passage précédent au tri
Ptcour : point isolé inséré lors du dernier passage au tri
(sorting pass de l'algo II)
SetA : point au sommet de l'arbre correspondant au set O
SetBprec  : point au sommet de l'arbre correspondant au set L
ajouté dans le "sorting pass" précédent --> à traiter
SetBcour : point au sommet de l'arbre correspondant au set L
ajouté dans le "sorting pass" courant --> ne traiter qu'au 
"sorting pass" suivant
*/
#define  Na          0
#define  Ptprec      1
#define  Ptcour      2
#define  SetA        3
#define  SetBprec    4
#define  SetBcour    5

/* nombre de listes (LSP, LIP, LIS) */
#define LNB 3
/* taille maximum d'une liste */
#define LTA 1000000
/* "List of Significant Pixels"*/
#define LSP 0
/* "List of Insignificant Pixels"*/
#define LIP 1
/* "List of Insignificant Set" */
#define LIS 2

