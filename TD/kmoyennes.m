% kmoyennes.m
% [vecteursliste,code,occur]=kmoyennes(vecteurs,dico,numiter)
% vecteurs :  vecteurs de la base (rang�s en colonnes)
% dico : number of classes
% numiter : number of try to find in the dictionary
% vecteursliste : contain the prototype vectors
% code : contain the index of vectors
% occur : number of occurance of each classe

function [vecteursliste,code,occur]=kmoyennes(vecteurs,dico,numiter)

% nombre de lignes du tableau vecteurs : dimension des vecteurs
dimvec=size(vecteurs,1);
% nombre de colonnes du tableau vecteurs : nombre de vecteurs
M=size(vecteurs,2);

% ecriture des fichiers n�cessaires au fonctionnment du programme quantvec
fid=fopen('vecteurs','w');
fwrite(fid,M,'int');
fwrite(fid,dimvec,'int');
fwrite(fid,dico,'int');
fwrite(fid,numiter,'int');
fwrite(fid,vecteurs,'float');
fclose(fid);

% lancement du programme quantvec
dos('quantvec vecteurs dict code');

% lecture des fichiers r�sultat
fid=fopen('dict','r');
dimvec=fread(fid,1,'int');
dico=fread(fid,1,'int');
vecteursliste=fread(fid,[dimvec dico],'float');
occur=fread(fid,dico,'int');
fclose(fid);
disp('vecteurs dans la liste')
disp([dimvec dico])

fid=fopen('code','r');
code=fread(fid,M,'int');
fclose(fid);