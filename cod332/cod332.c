/* fichier cod332.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>

#define min(a,b) (a<=b?a:b)

FILE *fpr,*fpv,*fpb;
FILE *fpp,* fps;

char nom[99];
char nomr[104];
char nomv[104];
char nomb[104];
char noms[104];
char nomp[104];
unsigned char * ligr,* ligv,* ligb,* ligs;
int LIG=512,COL=512;

void couleur(void);
void palette(void);

int main(int ac,char *av[])
{
int i;
if(ac==1)
	{
	fprintf(stderr,"cod332 -f<nom de fichier sans l'extension>\n");
	return -1;
	}
for(i=1;i<ac;i++)
	{
	switch(av[i][0])
		{
		case '-':
			switch(av[i][1])
				{
				case 'f':
					strncpy(nom,av[i]+2,98);
					strcpy(nomr,nom);
					strcpy(nomv,nom);
					strcpy(nomb,nom);
					strcpy(noms,nom);
					strcpy(nomp,nom);
					strcat(nomr,"r.ima");
					strcat(nomv,"v.ima");
					strcat(nomb,"b.ima");
					strcat(nomp,".lut");
					strcat(noms,"s.ima");
					break;
				case 'l':
					LIG=atoi(av[i]+2);
					break;
				case 'c':
					COL=atoi(av[i]+2);
					break;
				default :
					break;
				}
			break;
		default :
			break;
		}
	}

if((fpr=fopen(nomr,"rb"))==NULL)
	{perror("erreur fichier rouge\n");exit(errno);}
if((fpv=fopen(nomv,"rb"))==NULL)
	{perror("erreur fichier rouge\n");exit(errno);}
if((fpb=fopen(nomb,"rb"))==NULL)
	{perror("erreur fichier rouge\n");exit(errno);}
if((fpp=fopen(nomp,"wt"))==NULL)
	{perror("erreur fichier rouge\n");exit(errno);}
if((fps=fopen(noms,"wb"))==NULL)
	{perror("erreur fichier sortie\n");exit(errno);}

if((ligr=calloc(COL,sizeof(unsigned char)))==NULL)
	{perror("erreur ligne rouge\n");exit(errno);}
if((ligv=calloc(COL,sizeof(unsigned char)))==NULL)
	{perror("erreur ligne verte\n");exit(errno);}
if((ligb=calloc(COL,sizeof(unsigned char)))==NULL)
	{perror("erreur ligne bleue\n");exit(errno);}

if((ligs=calloc(COL,sizeof(unsigned char)))==NULL)
	{perror("erreur ligne sortie\n");exit(errno);}

couleur();
palette();

fclose(fpr);
fclose(fpv);
fclose(fpb);
fclose(fpp);
fclose(fps);

}

void couleur (void)
{
int x,y;
int valeur_rouge,valeur_vert,valeur_bleu;
int rbit,vbit,bbit;

for(x = 0;x < LIG;x ++)
	{
	fread(ligr,sizeof(unsigned char),COL,fpr);
	fread(ligv,sizeof(unsigned char),COL,fpv);
	fread(ligb,sizeof(unsigned char),COL,fpb);
	for(y = 0;y < COL;y ++)
      {
		valeur_rouge = ligr[y];
		valeur_vert  = ligv[y];
		valeur_bleu  = ligb[y];
		rbit = (valeur_rouge+18)/36;
		vbit = (valeur_vert+18)/36;
		bbit = (valeur_bleu+42)/85;
      rbit = min(rbit,7);
      vbit = min(vbit,7);
      bbit = min(bbit,3);
		ligs[y] = (rbit<<5)|(vbit<<2)|bbit;
		}
	fwrite(ligs,sizeof(unsigned char),COL,fps);
   }
}

void palette()
{
int x;
for(x=0;x<256;x++)
	fprintf(fpp,"%d\n",(x>>5)*36);
for(x=0;x<256;x++)
	fprintf(fpp,"%d\n",((x&0x1C)>>2)*36);
for(x=0;x<256;x++)
	fprintf(fpp,"%d\n",(x&0x03)*85);
}
