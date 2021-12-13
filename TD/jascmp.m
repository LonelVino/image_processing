% fichier jascmp.m

function jascmp(nom,qual)
if nargin==0
    nom='avion.bmp';
    qual=50;
end

racine=nom(1:strfind(nom,'.')-1);
Info=imfinfo(nom);
if(~strcmp(Info.Format,'bmp'))
    disp('l''image doit etre au format BMP')
    return
end
if(Info.BitDepth~=24)
    disp('l''image doit etre au format BMP 24 bits')
    return
end
taillebmp=Info.FileSize;
X=imread(nom);
imwrite(X,[racine '.jpg'],'Quality',qual);
Info=imfinfo([racine '.jpg']);
taillejpg=Info.FileSize;
ratio=taillejpg/taillebmp;
ligcom=['jasper -f ' nom ' -F ' racine '.jp2 -O rate=' num2str(ratio)];
disp(ligcom);
dos(ligcom);
ligcom=['jasper -f ' racine '.jp2 -F ' racine 'jp2.bmp'];
disp(ligcom);
dos(ligcom);
Xjpg=imread([racine '.jpg']);
Xjp2=imread([racine 'jp2.bmp']);
figure
imshow(X)
title('Image originale')
position=get(gcf,'Position');
set(gcf,'Position',[position(1) position(2)-50 position(3:4)]);
figure
imshow(Xjpg)
title(['Image JPEG : qualite=' int2str(qual)])
position=get(gcf,'Position');
set(gcf,'Position',[position(1)-200 position(2)-200 position(3:4)]);
figure
imshow(Xjp2)
title(['Image JPEG2000 : ratio=' num2str(ratio)])
position=get(gcf,'Position');
set(gcf,'Position',[position(1)+200 position(2)-200 position(3:4)]);
