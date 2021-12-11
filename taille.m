% taille.m
% fonction taille
% S=taille(nom)
% nom : nom du fichier
% taille : taille du fichier en octets

function S=taille(nom)
fid=fopen(nom,'r');
fseek(fid,0,'eof');
S=ftell(fid);
fclose(fid);
disp(['le fichier ' nom ' a ' int2str(S) ' octets'])
