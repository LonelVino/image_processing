/**************************************
 *    fichier couleur.h               *
 **************************************/


typedef struct vecteur
{
unsigned char vec[3];
float proba;
int numero;
struct vecteur * suivant;
}
VECTEUR;

#define    distance(x,y) \
(abs((x)[0] - (y)[0]) + \
 abs((x)[1] - (y)[1]) + \
 abs((x)[2] - (y)[2]))

void       const_nom      (void);
void       taille_fichier (void);
void       erreur         (char *);
void *     alloue         (unsigned int,unsigned int);
VECTEUR *  nouveau        (void);
void       calcul_histo   (void);
void       init_repres    (void);
float      calcul_distors (void);
void       repres_optim   (void);
void       classe_optim   (void);
void       genere_fichier (void);