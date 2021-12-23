#define _CRT_SECURE_NO_DEPRECATE

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <malloc.h>
#include <math.h>
#include "constant.h"
#include "global.h"
#include "algo.h"

void main(int ac,char ** av)
{
	int erreur,iter,p;
	if(ac != 4)
		Erreur("Il faut 3 parametres",1);
	strncpy(noment,av[1],NOM-1);
	strncpy(nomsor,av[2],NOM-1);
	strncpy(nomcod,av[3],NOM-1);
	
	srand( (unsigned)time( NULL ) );
	
	if(erreur=LireVecteurs())
		Erreur("Erreur de lecture des vecteurs",erreur);
	fprintf(stderr,"nombre de vecteurs : %d\n",M);
	fprintf(stderr,"dimension des vecteurs : %d\n",dimvec);
	fprintf(stderr,"taille du dictionnaire : %d\n",dico);
	fprintf(stderr,"nombre d'iterations : %d\n",numiter);
	if(erreur=InitDictionnaire())
		Erreur("Erreur d'initialisation du dictionnaire",erreur);

	iter=0;
	if(erreur=CalculDictionnaire())
		Erreur("Erreur de calcul itératif du dictionnaire",erreur);
	energieminimale=energie;
	memcpy(index_final,index_classes,M*sizeof(int));
	memcpy(popul_final,popul_classes,dico*sizeof(int));
	for(p=0;p<dico;p++)
		memcpy(vecteurs_final[p],vecteurs_classes[p],dimvec*sizeof(float));
	fprintf(stderr,"iteration %d, distorsion %lf en %d etapes\n",iter,energie/((double)M*(double)dimvec),etape);

	for(iter=1;iter<numiter;iter++)
	{
		if(erreur=CalculDictionnaire())
			Erreur("Erreur de calcul itératif du dictionnaire",erreur);
		if(energie<energieminimale)
		{
			energieminimale=energie;
			memcpy(index_final,index_classes,M*sizeof(int));
			memcpy(popul_final,popul_classes,dico*sizeof(int));
			for(p=0;p<dico;p++)
				memcpy(vecteurs_final[p],vecteurs_classes[p],dimvec*sizeof(float));
		}
		fprintf(stderr,"iteration %d, distorsion %lf en %d etapes\n",iter,energie/((double)M*(double)dimvec),etape);
	}

	fprintf(stderr,"distorsion finale %lf\n",energieminimale/((double)M*(double)dimvec));
	if(erreur=SauveClasses())
		Erreur("Erreur de sauvegarde des classes",erreur);
	if(erreur=SauveCode())
		Erreur("Erreur de sauvegarde du code",erreur);
}