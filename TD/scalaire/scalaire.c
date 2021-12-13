/**************************************
 *    fichier scalaire.c              *
 **************************************/

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "scalaire.h"

int N;
long n;
char nom_entree[100];
char nom_sortie[100];
long nombre_code;
VECTEUR * param;
VECTEUR * courant;
double epsilon;
int    type_dist;

void main (ac,av)
int ac;char * av[];
{
int i;
VECTEUR * vect;
double * repres;
double distorsion,preced,err;
N = 16;
epsilon = 1e-30;
type_dist = 0;
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
	    case 'n':
	       sscanf(av[i] + 2,"%ld",&n);
	       break;
	    case 'e':
	       strncpy(nom_entree,av[i] + 2,99);
	       break;
	    case 's':
	       strncpy(nom_sortie,av[i] + 2,99);
	       break;
	    case 'E':
	       sscanf(av[i] + 2,"%lf",&epsilon);
	       break;
	    case 't':
	       sscanf(av[i] + 2,"%d",&type_dist);;
	       break;
	    default :
	       break;
	    }
	 break;
      default :
	 break;
      }
   }
if(N == 0)
   erreur("N doit etre different de 0");
if((n > taille_fichier(nom_entree)) || (n == 0))
   n = taille_fichier(nom_entree);
fprintf(stderr,"taille fichier: %ld octets \n",n);
fprintf(stderr,"fichier traite: %s \n",nom_entree);
vect = init_vect(nom_entree,n);
fprintf(stderr,"nombre total = %ld\n",nombre_code);
repres = init_repres(vect,N);
preced = calcul_distors(vect,repres);
do
   {
   classe_optim(vect,repres,N);
   distorsion = calcul_distors(vect,repres);
   fprintf(stderr,"distorsion = %le  \n",distorsion);
   repres_optim(vect,repres,N);
   distorsion = calcul_distors(vect,repres);
   err = fabs(preced - distorsion)/distorsion;
   fprintf(stderr,"distorsion = %le, erreur = %le  \n",distorsion,err);
   preced = distorsion;
   }
while(err > epsilon);
fprintf(stderr,"\n**********\n");
fprintf(stderr,"fichier de sortie: %s \n",nom_sortie);
fprintf(stderr,"type de distance %d, epsilon = %le\n",type_dist,epsilon);
ecrit_result(nom_entree,nom_sortie,n,vect,repres);
}

void erreur (chaine)
char * chaine;
{
fprintf(stderr,"\n\n%s\n\n",chaine);
exit(0);
}

void * alloue (nombre,taille)
unsigned int nombre,taille;
{
void * pointeur;
if((pointeur = calloc(nombre,taille)) == NULL)
   erreur("erreur allocation");
return pointeur;
}

VECTEUR * nouveau()
{
VECTEUR * vect;
vect = alloue(1,sizeof(VECTEUR));
return vect;
}

VECTEUR * init_vect (nom,n)
char * nom;
long n;
{
FILE * fp;
int i,j;
unsigned char * buf;
unsigned int taille_buf;
VECTEUR * vect,* prec;
double * histo;
double somme;
int nombre_tranche,nombre_reste;
taille_buf = 16384;
if((fp = fopen(nom,"rb")) == NULL)
   erreur("fichier non ouvert");
if((buf = (unsigned char *)calloc(taille_buf,sizeof(unsigned char))) == NULL)
   erreur("erreur allocation");
if((histo = (double *)calloc(256,sizeof(double))) == NULL)
   erreur("erreur allocation");
nombre_tranche = (int)(n/taille_buf);
nombre_reste   = (int)(n%taille_buf);
for(i = 0;i < nombre_tranche;i ++)
   {
   fread(buf,sizeof(unsigned char),taille_buf,fp);
   for(j = 0;j < taille_buf;j ++)
      histo[buf[j]] += 1.0;
   }
fread(buf,sizeof(unsigned char),nombre_reste,fp);
for(j = 0;j < nombre_reste;j ++)
   histo[buf[j]] += 1.0;
vect = nouveau();
for(i = 0,courant=vect;i < 256;i ++)
   {
   if(histo[i] > 0.5)
      {
      courant->proba = histo[i];
      courant->vec = i;
      courant->suivant = nouveau();
      courant = courant->suivant;
      nombre_code ++;
      }
   }
for(courant=vect,prec=vect;courant->suivant;courant = courant->suivant)
   prec = courant;
if(prec->suivant)
   {
   free(prec->suivant);
   prec->suivant = NULL;
   }
free(buf);
free(histo);
fclose(fp);
somme = 0.0;
for(i = 0,courant = vect;i < nombre_code;i ++,courant = courant->suivant)
   {
   courant->proba /= (double)n;
   somme += courant->proba;
   }
return vect;
}

long taille_fichier (nom)
char * nom;
{
long taille;
FILE * fp;
if((fp = fopen(nom,"rb")) == NULL)
   erreur("fichier non ouvert");
fseek(fp,0L,SEEK_END);
taille = ftell(fp);
if(taille == 0)
   erreur("fichier de taille 0");
rewind(fp);
fclose(fp);
return taille;
}

double * init_repres (vect,N)
VECTEUR * vect;
int N;
{
int i;
double * tab;
unsigned char min,max;
min = 255;
max = 0;
for(courant = vect;courant;courant = courant->suivant)
   {
   if(courant->vec < min)
      min = courant->vec;
   if(courant->vec > max)
      max = courant->vec;
   }
fprintf(stderr,"min = %d, max = %d\n",(int)min,(int)max);
tab = alloue(N,sizeof(double));
for(i = 0;i < N;i ++)
   tab[i] = min + ((max - min)*i)/N;
return tab;
}

void classe_optim(vect,repres,N)
VECTEUR * vect;
double * repres;
int N;
{
int i;
char test;
double min,dist;
for(courant = vect;courant;courant = courant->suivant)
   {
   min = distance(courant->vec,repres[0]);
   for(i = 1,test = 1;i < N;i ++)
      {
      dist = distance(courant->vec,repres[i]);
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
}

double distance (double x,double y)
{
double val;
switch(type_dist)
   {
   case  0 :
      val = (x - y)*(x - y);
      break;
   case  1 :
      x = log(x);
      y = log(y);
      val = (x - y)*(x - y);
      break;
   case  2 :
      x = pow(x,0.1);
      y = pow(y,0.1);
      val = (x - y)*(x - y);
      break;
   default :
      erreur("selection distance incorrecte");
      break;
   }
return val;
}

void repres_optim(vect,repres,N)
VECTEUR * vect;
double * repres;
int N;
{
int i;
double * somme;
double * compos;
somme = alloue(N,sizeof(double));
compos = alloue(N,sizeof(double));
for(courant = vect;courant;courant = courant->suivant)
    somme[courant->numero] += courant->proba;
for(courant = vect;courant;courant = courant->suivant)
   compos[courant->numero] += courant->vec*courant->proba;
for(i = 0;i < N;i ++)
   {
   if(somme[i] == 0.0)
      erreur("pas de representant");
   compos[i] /= somme[i];
   repres[i] = compos[i];
   }
free(somme);
free(compos);
}

double calcul_distors(vect,repres)
VECTEUR * vect;
double * repres;
{
double distorsion;
distorsion = 0.0;
for(courant = vect;courant;courant = courant->suivant)
   distorsion += courant->proba*
   distance(repres[courant->numero],courant->vec);
return distorsion;
}

void ecrit_result(nom_entree,nom_sortie,n,vect,repres)
char * nom_entree,* nom_sortie;
long n;
VECTEUR * vect;
double * repres;
{
FILE * fpe,* fps;
int i,j;
unsigned char * bufe,* bufs;
unsigned char * tableau;
unsigned int taille_buf;
int nombre_tranche,nombre_reste;
taille_buf = 16384;
if((fpe = fopen(nom_entree,"rb")) == NULL)
   erreur("fichier non ouvert");
if((fps = fopen(nom_sortie,"wb")) == NULL)
   erreur("fichier non ouvert");
if((bufe =
   (unsigned char *)calloc(taille_buf,sizeof(unsigned char))) == NULL)
   erreur("erreur allocation");
if((bufs =
   (unsigned char *)calloc(taille_buf,sizeof(unsigned char))) == NULL)
   erreur("erreur allocation");
if((tableau =
   (unsigned char *)calloc(256,sizeof(unsigned char))) == NULL)
   erreur("erreur allocation");
nombre_tranche = (int)(n/taille_buf);
nombre_reste   = (int)(n%taille_buf);
for(courant = vect;courant;courant = courant->suivant)
   tableau[courant->vec] = floor(repres[courant->numero] + 0.5);
for(i = 0;i < nombre_tranche;i ++)
   {
   fread(bufe,sizeof(unsigned char),taille_buf,fpe);
   for(j = 0;j < taille_buf;j ++)
      bufs[j] = tableau[bufe[j]];
   fwrite(bufs,sizeof(unsigned char),taille_buf,fps);
   }
fread(bufe,sizeof(unsigned char),nombre_reste,fpe);
for(j = 0;j < nombre_reste;j ++)
   bufs[j] = tableau[bufe[j]];
fwrite(bufs,sizeof(unsigned char),nombre_reste,fps);
free(bufe);
free(bufs);
free(tableau);
fclose(fpe);
fclose(fps);
}