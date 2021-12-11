/**************************************
 *    fichier scalaire.h              *
 **************************************/


typedef struct vecteur
{
unsigned char vec;
double proba;
int numero;
struct vecteur * suivant;
}
VECTEUR;

void       erreur         (char *);
void *     alloue         (unsigned int,unsigned int);
VECTEUR *  nouveau        (void);
VECTEUR *  init_vect      (char *,long);
long       taille_fichier (char *);
/*
void       liste          (unsigned char);
*/
double   * init_repres    (VECTEUR *,int);
void       classe_optim   (VECTEUR *,double *,int);
double     distance       (double,double);
void       repres_optim   (VECTEUR *,double *,int);
double     calcul_distors (VECTEUR *,double *);
void       ecrit_result   (char *,char *,long,VECTEUR *,double *);