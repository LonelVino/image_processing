% fonction visu_base(base,arretimage)
% base : nom du répertoire contenant la base d'images
% type_image_base : type des images dans la base
% arretimage : si 0, le défilement est continu, si 1, il faut appuyer sur
% une touche pour obtenir le défilement image par image.
function visu_base(base,type_image_base,arretimage)
if nargin==0
    base='appr';
    type_image_base='png';
    arretimage=0;
end
close all
liste=dir(fullfile(base,['*.' type_image_base]));
set(figure,'Units','normalized','Position',[5 5 90 85]/100)
for n=1:length(liste)
    nom=liste(n).name;
    Y=double(imread(fullfile(base,nom)))/255;
    fid=fopen(fullfile(base,[nom(1:strfind(nom,'.')-1) '.txt']),'r');
    classe=fscanf(fid,'%d');
    fclose (fid);
    subplot(1,2,1)
    imshow(Y),title(['fichier ' nom ', classe ' int2str(classe)]),drawnow
    subplot(1,2,2)
    % on peut ici rajouter le code associé à différents traitements
    imshow(Y),title('image noir et blanc'),drawnow
    if arretimage
        pause()
    end
end