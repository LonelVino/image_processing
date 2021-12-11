/* fichier fonctions.h */

void Init(void);
void Algorithme(void);
void SauveCoeffQ(void);
void LireCoeff (void);
void RefinementPass (int);
void EcrireBit(char);
int RechercheMax(void);
char SPoint(int,int,IMAGE);
char SSetA(int lig,int col,IMAGE seuil);
char SSetB(int lig,int col,IMAGE seuil);
IMAGE * CreerImage(void);
void AjouterPoint(int,int,int,char);
void SupprimerPoint(int,int);
int  RechercheO(int *,int *,int,int);
void RechercheD(int,int);
char TestLNonVide(int,int);

