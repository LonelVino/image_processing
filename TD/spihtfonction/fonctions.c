/* fichier fonctions.c */

#include <stdio.h>
#include <fcntl.h>
#include <io.h>
#include <stdlib.h>
#include <math.h>
#include <setjmp.h>
#include "mestypes.h"
#include "fonctions.h"
#include "global.h"

/*
La fonction "Init" initialise l'algorithme.
La signification des variables modifiées est
donnée dans le fichier "global.c".
*/
void Init(void)
{
	int n,k;
	LIG2=LIG*(1<<(EXPOS-1));
	COL2=COL*(1<<(EXPOS-1));
	LIGT=LIG*(1<<EXPOS);
	COLT=COL*(1<<EXPOS);
	coeff=CreerImage();
	coeffq=CreerImage();
	LireCoeff();
	if((Listes=calloc(LNB,sizeof(POINT*)))==NULL)
	{
		fprintf(stderr,"Init :1\n");
		exit(-1);
	}
	if((IndexListes=calloc(LNB,sizeof(int)))==NULL)
	{
		fprintf(stderr,"Init : 2\n");
		exit(-1);
	}
	for(n=0;n<LNB;n++)
	{
		if((Listes[n]=calloc(LTA,sizeof(POINT)))==NULL)
		{
			fprintf(stderr,"Init : 3\n");
			exit(-1);
		}
		IndexListes[n]=0;
		for(k=0;k<LTA;k++)
			Listes[n][k].nature=Na;
	}
}

/*
La fonction "Algorithme" réalise l'agorithme II
décrit à la page 246 de la publi.
Il faut au préalable appeler la fonction "Init"
pour initialiser correctement l'algorithme.
*/
void Algorithme(void)
{
	int n,ninit,k;
	int l,c,index;
	int Ol[4],Oc[4];
	IMAGE seuil,signe;
	POINT * elem;
	char test;

	/*
	1) Initialization (page 246)
	*/
	ninit=RechercheMax();
	/*
	Initialisation des listes
	*/
	for(l=0;l<LIG;l++)
		for(c=0;c<COL;c++)
			AjouterPoint(LIP,l,c,Ptcour);
	for(l=0;l<LIG;l++)
		for(c=0;c<COL;c++)
			if(RechercheO(Ol,Oc,l,c))
				AjouterPoint(LIS,l,c,SetA);
	/*
	boucle principale
	*/
	for(n=ninit;;n--)
	{
		seuil=(IMAGE)pow(2.0,n);
		fprintf(stderr,"n=%d seuil=%f\n",n,seuil);
		/*
		Parcours de la liste LIP
		*/
		for(index=0;index < IndexListes[LIP];index++)
		{
			elem=Listes[LIP]+index;
			if(elem->nature!=Na)
			{
				test=SPoint(elem->lig,elem->col,seuil);
				EcrireBit(test);
				if(test)
				{
					EcrireBit((char)(coeff[(elem->col)*LIGT+(elem->lig)]>=0));
					/*
					on modifie en conséquence le tableau "coeffq"
					comme dans le décodeur.
					*/
					signe=(IMAGE)(2.0*(double)(coeff[(elem->col)*LIGT+(elem->lig)]>=0)-1.0);
					coeffq[(elem->col)*LIGT+(elem->lig)]=(IMAGE)(signe*1.5*seuil);
					AjouterPoint(LSP,elem->lig,elem->col,Ptcour);
					SupprimerPoint(LIP,index);
				}
			}
		}
		/*
		Parcours de la liste LIS
		*/
		for(index=0;index < IndexListes[LIS];index++)
		{
			elem=Listes[LIS]+index;
			if(elem->nature!=Na)
			{
			    /*
			    Traitement des sets de type A
			    */
				if(elem->nature==SetA)
				{
					test=SSetA(elem->lig,elem->col,seuil);
					EcrireBit(test);
					if(test)
					{
						if(RechercheO(Ol,Oc,elem->lig,elem->col)==0)
						{
							fprintf(stderr,"erreur algo\n");
							exit(-1);
						}
						for(k=0;k<4;k++)
						{
							test=SPoint(Ol[k],Oc[k],seuil);
							EcrireBit(test);
							if(test)
							{
								AjouterPoint(LSP,Ol[k],Oc[k],Ptcour);
								EcrireBit((char)(coeff[(Oc[k])*LIGT+(Ol[k])]>=0));
							    /*
							    on modifie en conséquence le tableau "coeffq"
							    comme dans le décodeur.
							    */
								signe=(IMAGE)(2.0*(double)(coeff[(Oc[k])*LIGT+(Ol[k])]>=0)-1.0);
								coeffq[(Oc[k])*LIGT+(Ol[k])]=(IMAGE)(signe*1.5*seuil);
							}
						    else
							    AjouterPoint(LIP,Ol[k],Oc[k],Ptcour);
						}
					    if(TestLNonVide(elem->lig,elem->col))
						{
							test=SSetB(elem->lig,elem->col,seuil);
							EcrireBit(test);
							if(test)
							{
								if(RechercheO(Ol,Oc,elem->lig,elem->col)==0)
								{
									fprintf(stderr,"erreur algo\n");
									exit(-1);
								}
								for(k=0;k<4;k++)
								{
									AjouterPoint(LIS,Ol[k],Oc[k],SetA);
								}
								SupprimerPoint(LIS,index);
							}
							else
							{
								AjouterPoint(LIS,elem->lig,elem->col,SetBcour);
								SupprimerPoint(LIS,index);
							}
						}
					    else
						{
						    SupprimerPoint(LIS,index);
						}
					}
				}
			    /*
			    Traitement des sets de type B inclus dans le "sorting pass" précédent
			    */
			    else if(elem->nature==SetBprec)
				{
				    test=SSetB(elem->lig,elem->col,seuil);
				    EcrireBit(test);
				    if(test)
					{
					    if(RechercheO(Ol,Oc,elem->lig,elem->col)==0)
						{
						    fprintf(stderr,"erreur algo\n");
						    exit(-1);
						}
					    for(k=0;k<4;k++)
						{
						    AjouterPoint(LIS,Ol[k],Oc[k],SetA);
						}
					    SupprimerPoint(LIS,index);
					}
				}
			}
		}
		/*
		Les sets de type B inclus dans le "sorting pass" courant
		sont préparés pour le "sorting pass" suivant
		*/
		for(index=0;index < IndexListes[LIS];index++)
		{
			elem=Listes[LIS]+index;
			if(elem->nature!=Na)
			{
				if(elem->nature==SetBcour)
					elem->nature=SetBprec;
			}
		}
		/*
		étape 3) de l'algo
		*/
		RefinementPass(n);
	}
	//longjmp(retour,1);
}


/*
La fonction "SauveCoeffQ" sauvegarde le tableau des coefficients 
quantifiés à une étape arbitraire de l'algorithme
*/
void SauveCoeffQ (void)
{
	setmode(fileno(stdout),O_BINARY);
	fwrite(coeffq,sizeof(IMAGE),LIGT*COLT,stdout);
}

/*
La fonction "LireCoeff" lit les valeurs initiales des coefficients
à quantifier.
*/
void LireCoeff (void)
{
	setmode(fileno(stdin),O_BINARY);
	fread(coeff,sizeof(IMAGE),LIGT*COLT,stdin);
}

/*
La fonction "RefinementPass" réalise l'étape 3)
de l'algorithme II 
*/
void RefinementPass (int n)
{
	POINT * elem;
	IMAGE signe,ampl;
	int index;

	/*
	La variable "ampl" vaut 2^(n-1) et correspond au pas
	à retrancher ou à ajouter afin d'augmenter la précision
	sur la représentation du tableau "coeff" à l'étape "n".
	*/
	ampl=(IMAGE)pow(2.0,n-1);
	for(index=0;index < IndexListes[LSP];index++)
	{
		elem=Listes[LSP]+index;
		if(elem->nature!=Na)
		{
			/*
			Si le type du point est "Ptprec", son signe a déjà été
			transmis.
			*/
			if(elem->nature == Ptprec)
			{
				/*
				Comme le signe a déjà été transmis et le tableau "coeffq"
				modifié en conséquence, on peut récupérer ce signe dans
				le tableau "coeffq" comme le ferait le décodeur.
				*/
				signe=(IMAGE)(2.0*(double)(coeffq[(elem->col)*LIGT+(elem->lig)]>=0)-1.0);
				if((fabs(coeff[(elem->col)*LIGT+(elem->lig)])-
					fabs(coeffq[(elem->col)*LIGT+(elem->lig)]))>=0)
				{
					EcrireBit(1);
					coeffq[(elem->col)*LIGT+(elem->lig)]+=(IMAGE)(signe*ampl);
				}
				else
				{
					EcrireBit(0);
					coeffq[(elem->col)*LIGT+(elem->lig)]-=(IMAGE)(signe*ampl);
				}
			}
			/*
			Si le type du point est "Ptcour", il
			vient d'être inséré à l'étape 2) donc
			il ne doit pas être pris en compte dans cette étape 3).
			On lui donne le type "Ptprec" pour qu'il soit traité lors
			de l'appel suivant à la fonction "RefinementPass".
			*/
			else if(elem->nature == Ptcour)
			{
				elem->nature = Ptprec;
			}
			else
			{
				fprintf(stderr,"erreur de type point\n");
				exit(-1);
			}
		}
	}
}

/*
La fonction "EcrireBit" inscrit l'information
bit à bit dans un fichier.
Les données sont inscrites dans un fichier "fbin.dat".
La condition d'arrêt de l'algorithme est ici le
nombre de bits inscrits dans le fichier
(variable "LongueurTrainBinaire").
*/
void EcrireBit(char bit)
{
	static char Octet;
	static int PosOctet;
	/*
	Ouverture du fichier au premier appel à la
	fonction "EcrireBit"
	*/
	if(fbin == NULL)
		fbin=fopen("fbin.dat","wb");
	Compteur++;
	if(bit)
	{
		Octet|=(1<<PosOctet);
	}
	PosOctet++;
	if(PosOctet==8)
	{
		PosOctet=0;
		fwrite(&Octet,sizeof(char),1,fbin);
		Octet=0;
	}
	/*
	Lorsque la condition d'arrêt de l'algorithme est
	atteinte, on ferme le fichier "fbin.dat" et on réalise
	un saut vers le programme principal avec la fonction
	"longjmp".
	*/
	if(Compteur >= LongueurTrainBinaire)
		longjmp(retour,1);
}

/*
La fonction "RechercheMax" calcule le maximum
de la valeur absolue des coefficients c(lig,col).
Elle retourne un entier N tel que max(c(lig,col))>= 2^n
*/
int RechercheMax(void)
{
	int lig,col;
	maxcoeff=0;
	for(lig=0;lig<LIGT;lig++)
		for(col=0;col<COLT;col++)
			if(fabs(coeff[col*LIGT+lig])>maxcoeff)
				maxcoeff=(IMAGE)fabs(coeff[col*LIGT+lig]);
	return (int)(log(maxcoeff)/log(2));
}

/*
La fonction "SPoint" réalise l'opération "Sn"
(voir page 245 de la publi) sur un point isolé
(voir le paragraphe IV) de la publi.
Le point considéré est de coordonnées ("lig","col")
et "seuil" vaut 2^n où n intervient dans
le Quantization-Step Update de l'algorithme 2. 
*/
char SPoint(int lig,int col,IMAGE seuil)
{
	if(fabs(coeff[col*LIGT+lig])>=seuil)
		return 1;
	else
		return 0;
}

/*
La fonction "SSetA" réalise l'opération "Sn"
(voir page 245 de la publi) sur un set de type "A"
(voir le paragraphe IV) de la publi.
Le set considéré est D("lig","col")
et "seuil" vaut 2^n où n intervient dans
le Quantization-Step Update de l'algorithme 2. 
*/
char SSetA(int lig,int col,IMAGE seuil)
{
	maxcoeff=0;
	RechercheD(lig,col);
	if(maxcoeff>=seuil)
		return 1;
	else
		return 0;
}

/*
La fonction "SSetB" réalise l'opération "Sn"
(voir page 245 de la publi) sur un set de type "B"
(voir le paragraphe IV) de la publi.
Le set considéré est L("lig","col")
et "seuil" vaut 2^n où n intervient dans
le Quantization-Step Update de l'algorithme 2. 
*/
char SSetB(int lig,int col,IMAGE seuil)
{
	int Ol[4],Oc[4];
	if(RechercheO(Ol,Oc,lig,col)==0)
	{
		fprintf(stderr,"SSetB erreur\n");
		exit(-1);
	}
	maxcoeff=0;
	RechercheD(Ol[0],Oc[0]);
	RechercheD(Ol[1],Oc[1]);
	RechercheD(Ol[2],Oc[2]);
	RechercheD(Ol[3],Oc[3]);
	if(maxcoeff>=seuil)
		return 1;
	else
		return 0;
}

/*
La fonction "CreerImage" alloue de la mémoire
pour stocker un tableau de coefficients de
type "IMAGE" défini dans "mestypes.h".
*/
IMAGE * CreerImage(void)
{
	IMAGE * image;
	if((image=calloc(LIGT*COLT,sizeof(IMAGE)))==NULL)
		exit(-1);
	return image;
}

void AjouterPoint(int numero,int lig,int col,char nature)
{
	if(IndexListes[numero] >= LTA)
	{
		fprintf(stderr,"AjouterPoint : 1\n");
		exit(-1);
	}
	Listes[numero][IndexListes[numero]].lig=lig;
	Listes[numero][IndexListes[numero]].col=col;
	Listes[numero][IndexListes[numero]].nature=nature;
	IndexListes[numero]++;
}

void SupprimerPoint(int numero,int index)
{
	Listes[numero][index].nature=Na;
}

/*
La fonction "RechercheO"  recherche les fils du point ("lig","col")
(le set O("lig","col") de la publi page 245)
Si le point n'a pas de fils, la fonction retourne 0.
Si le point a des fils, la fonction retourne 1 et
les coordonnees des 4 fils sont stockées dans les tableaux
"Ol" (lignes)  et "Oc" (colonnes) qui sont de dimension 4.
*/
int RechercheO(int * Ol,int * Oc,int lig, int col)
{
	if((lig>=0)&&(lig<LIG)&&(col>=0)&&(col<COL))
	{
		if((lig%2==0)&&(col%2==0))
		{
			return 0;
		}
		if((lig%2==0)&&(col%2==1))
		{
			Ol[0]=lig;  Oc[0]=COL+col-1;
			Ol[1]=lig;  Oc[1]=COL+col;
			Ol[2]=lig+1;Oc[2]=COL+col-1;
			Ol[3]=lig+1;Oc[3]=COL+col;
		}
		if((lig%2==1)&&(col%2==1))
		{
			Ol[0]=LIG+lig-1;Oc[0]=COL+col-1;
			Ol[1]=LIG+lig-1;Oc[1]=COL+col;
			Ol[2]=LIG+lig;  Oc[2]=COL+col-1;
			Ol[3]=LIG+lig;  Oc[3]=COL+col;
		}
		if((lig%2==1)&&(col%2==0))
		{
			Ol[0]=LIG+lig-1;Oc[0]=col;
			Ol[1]=LIG+lig-1;Oc[1]=col+1;
			Ol[2]=LIG+lig;  Oc[2]=col;
			Ol[3]=LIG+lig;  Oc[3]=col+1;
		}
	}
	else if((lig<LIG2)&&(col<COL2))
	{
		Ol[0]=2*lig;  Oc[0]=2*col;
		Ol[1]=2*lig;  Oc[1]=2*col+1;
		Ol[2]=2*lig+1;Oc[2]=2*col;
		Ol[3]=2*lig+1;Oc[3]=2*col+1;
	}
	else
		return 0;
	return 1;
}


/*
La fonction RechercheD recherche l'arborescence associée au
point de coordonnées (lig,col) 
(le set D(lig,col) défini à la page 245 de la publi)
Cette fonction est récursive.
En même temps, le maximum de la valeur absolue
des coefficients pour le set D(lig,col) 
est stocké dans la variable globale "maxcoeff"
*/
void RechercheD(int lig, int col)
{
	int Ol[4],Oc[4];
	int n;
	if(RechercheO(Ol,Oc,lig,col))
	{
		for(n=0;n<4;n++)
		{
			RechercheD(Ol[n],Oc[n]);
			if(fabs(coeff[Oc[n]*LIGT+Ol[n]])>maxcoeff)
				maxcoeff=(IMAGE)fabs(coeff[Oc[n]*LIGT+Ol[n]]);
		}
	}
}

/*
La fonction TestLNonVide vérifie si le set L(lig,col)
(voir page 245 de la publi) est vide ou non.
La fonction retourne 1 si le set est non vide,
elle retourne 0 si le set est vide
*/
char TestLNonVide(int lig,int col)
{
	int Ol[4],Oc[4];
	int Ols[4],Ocs[4];
	int n;
	char test;
	test=0;
	if(RechercheO(Ol,Oc,lig,col))
	{
		for(n=0;n<4;n++)
		{
			if(RechercheO(Ols,Ocs,Ol[n],Oc[n]))
				test=1;
		}
	}
	return test;
}