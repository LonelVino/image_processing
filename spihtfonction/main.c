/* fichier main.c */

#include <stdio.h>
#include <stdlib.h>
#include <setjmp.h>
#include "mestypes.h"
#include "fonctions.h"
#include "global.h"

void main (int ac,char ** av)
{
	int n,numLISTE;
	/*
	Lecture des paramètres sur la ligne de commande
	*/
	if(ac!=5)
	{
		fprintf(stderr,"usage : algoc <LIG> <COL> <EXPOS> <longueur>\n");
		fprintf(stderr,"< fichier entree > fichier sortie");
		return;
	}
	//LongueurTrainBinaire=atoi(av[1]);
	LIG=atoi(av[1]);
	COL=atoi(av[2]);
	EXPOS=atoi(av[3]);
	LongueurTrainBinaire=atoi(av[4]);
	/*
	On quitte le programme selon une condition
	imposée dans la fonction "EcrireBit".
	Les coefficients quantifiés sont alors sauvegardés
	avec les mêmes valeurs que celles qui seraient obtenues
	avec un décodeur.
	La fonction "setjmp" permet le retour au programme principal
	après appel de la fonction "longjmp" dans la fonction "EcrireBit".
	*/
	if(setjmp(retour))
	{
		fprintf(stderr,"\nnombre de bits : %d\n",Compteur);
		for(n=0,numLISTE=0;n < IndexListes[LSP];n++)
			if(Listes[LSP][n].nature!=Na)
				numLISTE++;
		fprintf(stderr,"LSP : %d %d\n",numLISTE,IndexListes[LSP]);
		for(n=0,numLISTE=0;n < IndexListes[LIP];n++)
			if(Listes[LIP][n].nature!=Na)
				numLISTE++;
		fprintf(stderr,"LIP : %d %d\n",numLISTE,IndexListes[LIP]);
		for(n=0,numLISTE=0;n < IndexListes[LIS];n++)
			if(Listes[LIS][n].nature!=Na)
				numLISTE++;
		fprintf(stderr,"LIS : %d %d\n",numLISTE,IndexListes[LIS]);
		fclose(fbin);
		SauveCoeffQ();
		return;
	}
	/*
	Lancement de l'algorithme
	*/
	Init();
	Algorithme();
}