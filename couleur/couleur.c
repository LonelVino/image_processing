/**************************************
 *    fichier couleur.c               *
 **************************************/

#include <stdio.h>
#include <conio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "couleur.h"

int N;
long n;
char racine   [100];
char nom_rouge[100];
char nom_vert [100];
char nom_bleu [100];
char nom_sortie[100];
char nom_palette[100];
FILE * fr,* fv,* fb,* fs,* fl;
long nombre_code;
VECTEUR * initial;
VECTEUR * courant;
float epsilon;
float *** histo;
int decr,decv,decb;
float ** repres;
int   ** repres_int;

int main (int ac,char * av[])
{
int i;
float distorsion,err,prec;
N = 256;
decr = 4;
decv = 4;
decb = 4;
epsilon = 1e-4;
for(i = 1;i < ac;i ++)
   {
   switch(av[i][0])
      {
      case '-':
	 switch(av[i][1])
	    {
	    case 'N':
	       sscanf(av[i] + 2,"%d",&N);
	       break;
	    case 'r':
	       sscanf(av[i] + 2,"%d",&decr);
	       break;
	    case 'v':
	       sscanf(av[i] + 2,"%d",&decv);
	       break;
	    case 'b':
	       sscanf(av[i] + 2,"%d",&decb);
	       break;
	    case 'f':
	       strncpy(racine,av[i] + 2,94);
	       break;
	    case 'E':
	       sscanf(av[i] + 2,"%f",&epsilon);
	       break;
	    }
	 break;
      default :
	 break;
      }
   }
const_nom ();
if(N == 0)
   erreur("N doit etre different de 0");
taille_fichier();
if(n == 0)
   erreur("fichier de taille nulle");
fprintf(stderr,"taille fichier %ld\n",n);
calcul_histo();
fprintf(stderr,"nombre code %ld\n",nombre_code);
init_repres();
prec = calcul_distors();
do
   {
   classe_optim();
   distorsion = calcul_distors();
   err = fabs(prec - distorsion)/distorsion;
   prec = distorsion;
   fprintf(stderr,"distorsion %e, erreur %e\n",distorsion,err);
   repres_optim();
   distorsion = calcul_distors();
   err = fabs(prec - distorsion)/distorsion;
   prec = distorsion;
   fprintf(stderr,"distorsion %e, erreur %e\n",distorsion,err);
   }
while((err > epsilon)&&(!kbhit()));
genere_fichier();
}

void const_nom()
{
strcpy(nom_rouge,racine);
strcpy(nom_vert,racine);
strcpy(nom_bleu,racine);
strcpy(nom_sortie,racine);
strcpy(nom_palette,racine);
strncat(nom_rouge,"r.ima",5);
strncat(nom_vert,"v.ima",5);
strncat(nom_bleu,"b.ima",5);
strncat(nom_sortie,"s.ima",5);
strncat(nom_palette,".lut",5);
}

void  taille_fichier()
{
long tr,tv,tb;
if((fr = fopen(nom_rouge,"rb")) == NULL)
   erreur("erreur ouverture fichier rouge");
if((fv = fopen(nom_vert,"rb")) == NULL)
   erreur("erreur ouverture fichier vert");
if((fb = fopen(nom_bleu,"rb")) == NULL)
   erreur("erreur ouverture fichier bleu");
fseek(fr,0L,SEEK_END);
tr = ftell(fr);
rewind(fr);
fseek(fv,0L,SEEK_END);
tv = ftell(fv);
rewind(fv);
fseek(fb,0L,SEEK_END);
tb = ftell(fb);
rewind(fb);
if((tr != tv)||(tr != tb)||(tv != tb))
   erreur("fichiers de taille differente");
n = tr;
}

void erreur (char * chaine)
{
fprintf(stderr,"\n\n%s\n\n",chaine);
exit(0);
}

void * alloue (unsigned int nombre,unsigned int taille)
{
void * pointeur;
if((pointeur = calloc(nombre,taille)) == NULL)
   erreur("erreur allocation");
return pointeur;
}

VECTEUR * nouveau()
{
VECTEUR * vect;
vect = (VECTEUR *)alloue(1,sizeof(VECTEUR));
return vect;
}

void calcul_histo()
{
int i,j,k;
int nr,nv,nb;
unsigned char * bufr,* bufv,* bufb;
unsigned int taille_buf;
int nombre_tranche,nombre_reste;
VECTEUR * prec;
nr = 256 >> decr;
nv = 256 >> decv;
nb = 256 >> decb;
histo = (float ***)alloue(nr,sizeof(float **));
for(i = 0;i < nr;i ++)
   {
   histo[i] = (float **)alloue(nv,sizeof(float *));
   for(j = 0;j < nv;j ++)
      histo[i][j] = (float *)alloue(nb,sizeof(float));
   }
taille_buf = 16384;
if((bufr =
   (unsigned char *)calloc(taille_buf,sizeof(unsigned char))) == NULL)
   erreur("erreur allocation");
if((bufv =
   (unsigned char *)calloc(taille_buf,sizeof(unsigned char))) == NULL)
   erreur("erreur allocation");
if((bufb =
   (unsigned char *)calloc(taille_buf,sizeof(unsigned char))) == NULL)
   erreur("erreur allocation");
nombre_tranche = (int)(n/taille_buf);
nombre_reste   = (int)(n%taille_buf);
for(i = 0;i < nombre_tranche;i ++)
   {
   fread(bufr,sizeof(unsigned char),taille_buf,fr);
   fread(bufv,sizeof(unsigned char),taille_buf,fv);
   fread(bufb,sizeof(unsigned char),taille_buf,fb);
   for(j = 0;j < taille_buf;j ++)
      histo[bufr[j]>>decr][bufv[j]>>decv][bufb[j]>>decb] += 1.0;
   }
fread(bufr,sizeof(unsigned char),nombre_reste,fr);
fread(bufv,sizeof(unsigned char),nombre_reste,fv);
fread(bufb,sizeof(unsigned char),nombre_reste,fb);
for(j = 0;j < nombre_reste;j ++)
   histo[bufr[j]>>decr][bufv[j]>>decv][bufb[j]>>decb] += 1.0;

initial = nouveau();
courant = initial;
for(i = 0;i < nr;i ++)
   {
   for(j = 0;j < nv;j ++)
      {
      for(k = 0;k < nb;k ++)
	 {
	 if(histo[i][j][k] > 0.5)
	    {
	    courant->proba = histo[i][j][k]/n;
	    courant->vec[0] = (i << decr) + (1 << (decr - 1));
	    courant->vec[1] = (j << decv) + (1 << (decv - 1));
	    courant->vec[2] = (k << decb) + (1 << (decb - 1));
	    courant->suivant = nouveau();
	    courant = courant->suivant;
	    nombre_code ++;
	    }
	 }
      free(histo[i][j]);
      }
   free(histo[i]);
   }
free(histo);
for(courant=initial,prec=initial;courant->suivant;courant = courant->suivant)
   prec = courant;
if(prec->suivant)
   {
   free(prec->suivant);
   prec->suivant = NULL;
   }
free(bufr);free(bufv);free(bufb);
}

void init_repres ()
{
int i,j;
long ctr;
repres = (float **)alloue(N,sizeof(float *));
for(i = 0;i < N;i ++)
   repres[i] = (float *)alloue(3,sizeof(float));
repres_int = (int **)alloue(N,sizeof(int *));
for(i = 0;i < N;i ++)
   repres_int[i] = (int *)alloue(3,sizeof(int));
for(i = 0,ctr = 0,courant = initial;courant;courant = courant->suivant)
   {
   ctr += N;
   if(ctr >= nombre_code)
      {
      ctr -= nombre_code;
      if(i > N)
	 erreur("depassement");
      for(j = 0;j < 3;j ++)
	 {
	 repres[i][j] = courant->vec[j];
	 repres_int[i][j] = courant->vec[j];
	 }
      i ++;
      }
   }
if(i != N)
   erreur("initialisation mal faite");
}

float calcul_distors()
{
float distorsion;
distorsion = 0.0;
for(courant = initial;courant;courant = courant->suivant)
   distorsion += courant->proba*
   distance(repres_int[courant->numero],courant->vec);
return distorsion;
}

void repres_optim()
{
int i,j;
float * somme;
somme = (float *)alloue(N,sizeof(float));
for(courant = initial;courant;courant = courant->suivant)
    somme[courant->numero] += courant->proba;
for(i = 0;i < N;i ++)
   if(somme[i] != 0.0)
      memset(repres[i],0,3*sizeof(float));
for(courant = initial;courant;courant = courant->suivant)
   {
   if(somme[courant->numero] != 0.0)
      for(j = 0;j < 3;j ++)
	 repres[courant->numero][j] += courant->vec[j]*courant->proba;
   }
for(i = 0;i < N;i ++)
   {
   if(somme[i] != 0.0)
      for(j = 0;j < 3;j ++)
	 {
	 repres[i][j] /= somme[i];
	 repres_int[i][j] = floor(repres[i][j] + 0.5);
	 }
   }
free(somme);
}

void classe_optim()
{
int i;
char test;
int min,dist;
//long ctr;
//int pourcent;
//pourcent = 0;
//ctr = 0;
for(courant = initial;courant;courant = courant->suivant)
   {
//   ctr += 101;
//   if(ctr >= nombre_code)
//      {
//      ctr -= nombre_code;
//      fprintf(stderr,"%3d%%\r",pourcent);
//      pourcent ++;
//      }
   min = distance(courant->vec,repres_int[0]);
   for(i = 1,test = 1;i < N;i ++)
      {
      dist = distance(courant->vec,repres_int[i]);
      if(dist < min)
	 {
	 min = dist;
	 courant->numero = i;
	 test = 0;
	 }
      }
   if(test)
      courant->numero = 0;
   }
//fprintf(stderr,"\n");
}

void genere_fichier()
{
int i,j,k;
int nr,nv,nb;
unsigned char * bufr,* bufv,* bufb,* bufs;
unsigned int taille_buf;
int nombre_tranche,nombre_reste;
unsigned char *** corresp;
unsigned char ** palette;
if((fs = fopen(nom_sortie,"wb")) == NULL)
   erreur("fichier de sortie non ouvert");
if((fl = fopen(nom_palette,"w")) == NULL)
   erreur("fichier de sortie non ouvert");
rewind(fr);rewind(fv);rewind(fb);
nr = 256 >> decr;
nv = 256 >> decv;
nb = 256 >> decb;
taille_buf = 16384;
if((bufr =
   (unsigned char *)calloc(taille_buf,sizeof(unsigned char))) == NULL)
   erreur("erreur allocation");
if((bufv =
   (unsigned char *)calloc(taille_buf,sizeof(unsigned char))) == NULL)
   erreur("erreur allocation");
if((bufb =
   (unsigned char *)calloc(taille_buf,sizeof(unsigned char))) == NULL)
   erreur("erreur allocation");
if((bufs =
   (unsigned char *)calloc(taille_buf,sizeof(unsigned char))) == NULL)
   erreur("erreur allocation");
corresp = (unsigned char ***)alloue(nr,sizeof(unsigned char **));
for(i = 0;i < nr;i ++)
   {
   corresp[i] = (unsigned char **)alloue(nv,sizeof(unsigned char *));
   for(j = 0;j < nv;j ++)
      corresp[i][j] = (unsigned char *)alloue(nb,sizeof(unsigned char));
   }
palette = (unsigned char **)alloue(N,sizeof(unsigned char *));
for(i = 0;i < N;i ++)
   palette[i] = (unsigned char *)alloue(3,sizeof(unsigned char));

for(courant = initial;courant;courant = courant->suivant)
   {
   corresp[courant->vec[0]>>decr]
	  [courant->vec[1]>>decv]
	  [courant->vec[2]>>decb]
   =  courant->numero;
   for(k = 0;k < 3;k ++)
      palette[courant->numero][k] = repres_int[courant->numero][k];
   }

nombre_tranche = (int)(n/taille_buf);
nombre_reste   = (int)(n%taille_buf);
for(i = 0;i < nombre_tranche;i ++)
   {
   fread(bufr,sizeof(unsigned char),taille_buf,fr);
   fread(bufv,sizeof(unsigned char),taille_buf,fv);
   fread(bufb,sizeof(unsigned char),taille_buf,fb);
   for(j = 0;j < taille_buf;j ++)
      bufs[j] = corresp[bufr[j]>>decr][bufv[j]>>decv][bufb[j]>>decb];
   fwrite(bufs,sizeof(unsigned char),taille_buf,fs);
   }
fread(bufr,sizeof(unsigned char),nombre_reste,fr);
fread(bufv,sizeof(unsigned char),nombre_reste,fv);
fread(bufb,sizeof(unsigned char),nombre_reste,fb);
for(j = 0;j < nombre_reste;j ++)
   bufs[j] = corresp[bufr[j]>>decr][bufv[j]>>decv][bufb[j]>>decb];
fwrite(bufs,sizeof(unsigned char),nombre_reste,fs);
for(k = 0;k < 3;k ++)
   for(i = 0;i < 256;i ++)
      {
      if(i < N)
	 fprintf(fl,"%d\n",palette[i][k]);
      else
	 fprintf(fl,"0\n");
      }
free(bufr);free(bufv);free(bufb);free(bufs);
}