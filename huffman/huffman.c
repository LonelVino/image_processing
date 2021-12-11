/**************************************
 *   fichier huffman.c                *
 **************************************/

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include "huffman.h"

char nom_entree[100];

void main (ac,av)
int ac;
char * av[];
{
int i;
CODE * tab;
long taille;
for(i = 1;i < ac;i ++)
	{
	switch(av[i][0])
		{
		case '-':
			switch(av[i][1])
				{
				case 'e':
					strncpy(nom_entree,av[i] + 2,99);
					break;
				default :
					break;
				}
			break;
		default :
			break;
		}
	}
tab = init_code();
taille = calcul_proba(nom_entree,tab);
genere_code (tab);
verif_code  (tab,taille);
}

void erreur (message)
char * message;
{
fprintf(stderr,"\n\n%s\n\n",message);
exit(0);
}

CODE * init_code ()
{
int i;
CODE * tableau;
if((tableau = (CODE *)calloc(256,sizeof(CODE))) == NULL)
	exit(0);
for(i = 0;i < 256;i ++)
	tableau[i].niveau = i;
return tableau;
}

long calcul_proba(nom,tab)
char * nom;
CODE * tab;
{
int i,j;
FILE * fp;
long taille;
unsigned char * buf;
unsigned int taille_buf;
int nombre_tranche,nombre_reste;
taille_buf = 16384;
if((fp = fopen(nom,"rb")) == NULL)
	erreur("fichier non ouvert");
fseek(fp,0L,SEEK_END);
taille = ftell(fp);
if(taille == 0)
	erreur("fichier de taille 0");
rewind(fp);
if((buf = (unsigned char *)calloc(taille_buf,sizeof(unsigned char))) == NULL)
	erreur("erreur allocation");
nombre_tranche = (int)(taille/taille_buf);
nombre_reste   = (int)(taille%taille_buf);
for(i = 0;i < nombre_tranche;i ++)
	{
	fread(buf,sizeof(unsigned char),taille_buf,fp);
	for(j = 0;j < taille_buf;j ++)
		tab[buf[j]].proba ++;
	}
fread(buf,sizeof(unsigned char),nombre_reste,fp);
for(j = 0;j < nombre_reste;j ++)
	tab[buf[j]].proba ++;
for(i = 0;i < 256;i ++)
	tab[i].init_proba = tab[i].proba;
free(buf);
fclose(fp);
return taille;
}

void genere_code (tab)
CODE * tab;
{
int i,j,k;
CODE temp;
CELL * buf0,* buf1, * code;
for(i = 0;i < 256;i ++)
	tab[i].code = alloue_cell();
for(i = 255;i > 0;i --)
	{
	for(k = 0;k < 2;k ++)
		for(j = 0;j < (i - k);j ++)
			if (tab[j].proba < tab[j + 1].proba)
				{
				temp = tab[j];
				tab[j] = tab[j+1];
				tab[j+1] = temp;
				}
	if(tab[i].init_proba)
		buf1 = suivre_cell(tab[i    ].code);
	else
		buf1 = NULL;
	if(tab[i - 1].init_proba)
		buf0 = suivre_cell(tab[i - 1].code);
	else
		buf0 = NULL;
	if(buf0&&buf1)
		{
		code = alloue_cell();
		buf1->bit1 = code;
		buf0->bit0 = code;
		}
	tab[i - 1].proba += tab[i].proba;
	}
}

void verif_code (tab,taille)
CODE * tab;
long taille;
{
int i;
CELL * buf;
float entropie,codage_moyen,proba;
qsort(tab,256,sizeof(CODE),compare);
entropie = 0.0;
codage_moyen = 0.0;
for(i = 0;i < 256;i ++)
	{
	fprintf(stdout,"%5ld % e   ",tab[i].niveau,
	tab[i].init_proba/(float)taille);
	buf = tab[i].code;
	while(buf)
		{
		if(buf->bit0)
			{
			buf = buf->bit0;
			tab[i].longueur_mot ++;
			}
		else if(buf->bit1)
			{
			buf = buf->bit1;
			tab[i].longueur_mot ++;
			}
		else
			buf = NULL;
		}
	fprintf(stdout," %5d ",tab[i].longueur_mot);
	buf = tab[i].code;
	while(buf)
		{
		if(buf->bit0)
			{
			fprintf(stdout,"0");
			buf = buf->bit0;
			}
		else if(buf->bit1)
			{
			fprintf(stdout,"1");
			buf = buf->bit1;
			}
		else
			buf = NULL;
		}
	fprintf(stdout,"\n");
	proba = tab[i].init_proba;
	proba /= taille;
	if(tab[i].init_proba != 0)
		entropie -=  (proba*log(proba)/log(2.0));
	codage_moyen += (proba*tab[i].longueur_mot);
	}
fprintf(stderr,"entropie = %e, codage moyen = %e\n",entropie,codage_moyen);
}

int compare (elem1,elem2)
const void * elem1,* elem2;
{
if(((CODE *)elem1)->init_proba < ((CODE *)elem2)->init_proba)
	return 1;
else if(((CODE *)elem1)->init_proba == ((CODE *)elem2)->init_proba)
	return 0;
else
	return -1;
}


CELL * alloue_cell()
{
CELL * pointeur;
if((pointeur = (CELL *)calloc(1,sizeof(CELL))) == NULL)
	erreur("erreur allocation");
return pointeur;
}

void libere_cell (pointeur)
CELL ** pointeur;
{
memset(*pointeur,0,sizeof(CELL));
free(*pointeur);
*pointeur = NULL;
}

CELL * suivre_cell (cellule)
CELL * cellule;
{
if(cellule == NULL)
  return NULL;
while (1)
  {
  if(cellule->bit0)
	  cellule = cellule->bit0;
  else if(cellule->bit1)
	  cellule = cellule->bit1;
  else
	  return cellule;
  }
return NULL;
}