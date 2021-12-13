% fonction spiht
% [Y,PSNR,tX,tY]=spiht(X,prof,bitrate)
% X : image originale
% dist : distorsion � atteindre (en dB)
% prof : profondeur de d�composition en ondelette
% Y : image cod�e
% bitrate : nombre de bits par point atteint
% tX : transform�e en ondelette de X
% tY : transform�e en ondelette de Y

function [Y,PSNR,tX,tY]=spiht(X,prof,bitrate)
% dimension de l'image d'entr�e
[LIGT,COLT]=size(X);
% dimension de l'image basse r�solution
LIG=LIGT/(2^prof);
COL=COLT/(2^prof);
if rem(LIG,2)~=0
    error('le nombre de ligne de l''image basse r�solution doit etre pair')
end
if rem(COL,2)~=0
    error('le nombre de colonne de l''image basse r�solution doit etre pair')
end

% transformation en ondelettes
% [tX, compt] = Transform9_7c(X,prof);
tX=decomp_2d(X,prof);
tX=echelle_decomp_2d(tX,prof,1);

% �criture du r�sultat dans un fichier temporaire trans.res
fid=fopen('trans.res','w');
fwrite(fid,tX,'float');
fclose(fid);

% lancement du programme spihtdist 
ligcom=sprintf(...
    'spihtfonction %d %d %d %f < trans.res > transq.res',...
    LIG,COL,prof,bitrate*numel(X));
dos(ligcom);

% lecture du r�sultat dans le fichier temporaire transq.res
fid=fopen('transq.res','r');
tY=fread(fid,[LIGT COLT],'float');
fclose(fid);

% transformation en ondelettes inverse pour obtenir l'image cod�e
% Y = Transform9_7c_inv(tY,compt);
tYtemp=echelle_recomp_2d(tY,prof,1);
Y=recomp_2d(tYtemp,prof);

% effacement des fichiers temporaires
dos('del trans.res transq.res fbin.dat');

PSNR=psnr(X,Y);