#define _CRT_SECURE_NO_DEPRECATE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include <math.h>
#include "constant.h"
#include "global.h"
#include "algo.h"

void Erreur(char * chaine,int numero)
{
	fprintf(stderr,chaine);
	fprintf(stderr,"\nerreur %d\n",numero);
	exit(numero);
}

int LireVecteurs (void)
{
	int k;
	if((ent=fopen(noment,"rb"))==NULL)
		return 1;
	fread(&M,sizeof(int),1,ent);
	fread(&dimvec,sizeof(int),1,ent);
	fread(&dico,sizeof(int),1,ent);
	fread(&numiter,sizeof(int),1,ent);
	if((vecteurs=calloc(M,sizeof(float *)))==NULL)
		return 3;
	for(k=0;k<M;k++)
	{
		if((vecteurs[k]=calloc(dimvec,sizeof(float)))==NULL)
			return 4;
	}
	for(k=0;k<M;k++)
		fread(vecteurs[k],sizeof(float),dimvec,ent);
	fclose(ent);
	return 0;
}

int InitDictionnaire(void)
{
	int k;
	if((vecteurs_classes=calloc(dico,sizeof(float *)))==NULL)
		return 1;
	for(k=0;k<dico;k++)
	{
		if((vecteurs_classes[k]=calloc(dimvec,sizeof(float)))==NULL)
			return 2;
	}
	if((vecteurs_final=calloc(dico,sizeof(float *)))==NULL)
		return 3;
	for(k=0;k<dico;k++)
	{
		if((vecteurs_final[k]=calloc(dimvec,sizeof(float)))==NULL)
			return 4;
	}
	if((index_final=calloc(M,sizeof(int)))==NULL)
		return 5;
	if((popul_final=calloc(dico,sizeof(int)))==NULL)
		return 6;
	if((index_classes=calloc(M,sizeof(int)))==NULL)
		return 7;
	if((popul_classes=calloc(dico,sizeof(int)))==NULL)
		return 8;
	return 0;
}

int CalculDictionnaire(void)
{
	int n,k,p,index;
	double energie_prec,distance,distancemin;
	char fini;
	for(k=0;k<dico;k++)
	{
		index=(int)floor(((double)(M-1)*(double)(rand()))/(double)RAND_MAX);
		for(n=0;n<dimvec;n++)
			vecteurs_classes[k][n]=vecteurs[index][n];
	}
	energie=0.0;
	etape=0;
	fini=0;
	while(!fini)
	{
		memset(popul_classes,0,dico*sizeof(int));
		energie_prec=energie;
		energie=0.0;
		for(k=0;k<M;k++)
		{
			index=0;
			distancemin=0.0;
			for(n=0;n<dimvec;n++)
			{
				distancemin+=
					(vecteurs[k][n]-vecteurs_classes[0][n])*
					(vecteurs[k][n]-vecteurs_classes[0][n]);
			}
			for(p=1;p<dico;p++)
			{
				distance=0.0;
				for(n=0;n<dimvec;n++)
				{
					distance+=
						(vecteurs[k][n]-vecteurs_classes[p][n])*
						(vecteurs[k][n]-vecteurs_classes[p][n]);
				}
				if(distance<distancemin)
				{
					distancemin=distance;
					index=p;
				}
			}
			index_classes[k]=index;
			popul_classes[index]+=1;
			energie+=distancemin;
		}
		for(p=0;p<dico;p++)
		{
			if(popul_classes[p])
			{
				memset(vecteurs_classes[p],0,dimvec*sizeof(float));
			}
		}
		for(k=0;k<M;k++)
		{
			index=index_classes[k];
			if(popul_classes[index])
			{
				for(n=0;n<dimvec;n++)
				{
					vecteurs_classes[index][n]+=vecteurs[k][n];
				}
			}
		}
		for(p=0;p<dico;p++)
		{
			if(popul_classes[p])
			{
				for(n=0;n<dimvec;n++)
				{
					vecteurs_classes[p][n]/=popul_classes[p];
				}
			}
		}
		if(etape!=0)
		{
			if(((energie_prec-energie)/energie)<SEUIL)
				fini=1;
		}
		etape++;
	}
	return 0;
}

int SauveClasses(void)
{
	int k;
	if((sor=fopen(nomsor,"wb"))==NULL)
		return 1;
	fwrite(&dimvec,sizeof(int),1,sor);
	fwrite(&dico,sizeof(int),1,sor);
	for(k=0;k<dico;k++)
		fwrite(vecteurs_final[k],sizeof(float),dimvec,sor);
	fwrite(popul_final,sizeof(int),dico,sor);
	fclose(sor);
	return 0;
}

int SauveCode(void)
{
	if((cod=fopen(nomcod,"wb"))==NULL)
		return 1;
	fwrite(index_final,sizeof(int),M,sor);
	fclose(sor);
	return 0;
}