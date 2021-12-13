/**************************************
 *   fichier huffman.h                *
 **************************************/

typedef struct cell
{
struct cell * bit0;
struct cell * bit1;
}
CELL;

typedef struct code
{
unsigned long niveau;
unsigned long proba;
unsigned long init_proba;
unsigned long longueur_mot;
CELL * code;
}
CODE;

void   erreur    (char *);
CODE * init_code (void);
long	 calcul_proba (char *,CODE *);
void   genere_code  (CODE *);
void   verif_code   (CODE *,long);
int 	 compare      (const void *,const void *);
CELL * alloue_cell  (void);
void   libere_cell  (CELL **);
CELL * suivre_cell  (CELL *);