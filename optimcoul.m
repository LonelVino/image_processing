% fichier optimcoul.m
% ligne de commande :
% [X,map]=optimcoul(nom,couleur,r,v,b)
% nom : nom du fichier � traiter
% couleur : nombre de couleur
% r,v,b : calcul histogramme couleur sur (256>>r)x(256>>v)x(256>>b)
% par d�faut : r=2,v=2,b=2

function [X,map]=optimcoul(nom,couleur,r,v,b)
if nargin == 2
    r=2;v=2;b=2;
end
[racine,taille]=ecrirec24(nom);
racine = strcat('.\img\', racine);
dos(['couleur -f' racine ...
' -N' int2str(couleur) ...
' -r' int2str(r) ...
' -v' int2str(v) ...
' -b' int2str(b)]);
[X,map]=lirec8(racine,taille);
dos(['del ' racine 's.ima']);
dos(['del ' racine 'r.ima']);
dos(['del ' racine 'v.ima']);
dos(['del ' racine 'b.ima']);
dos(['del ' racine '.lut']);

function [racine,taille]=ecrirec24(nom)
racine=nom(1:findstr(nom,'.')-1);
RVB=imread(nom);
if size(RVB,3) ~= 3
    error('format non reconnu');
end
fidr=fopen([racine 'r.ima'],'wb');
fidv=fopen([racine 'v.ima'],'wb');
fidb=fopen([racine 'b.ima'],'wb');
fwrite(fidr,RVB(:,:,1),'uint8');
fwrite(fidv,RVB(:,:,2),'uint8');
fwrite(fidb,RVB(:,:,3),'uint8');
fclose(fidr);
fclose(fidv);
fclose(fidb);

set(figure,...
'MenuBar','none',...
'Name','Image cod�e sur 24 bits')
image(RVB)
axis equal
set(gca,'Xtick',[],'Ytick',[])
zoom on
drawnow
taille=size(RVB(:,:,1));

function [X,map]=lirec8(nom,taille)
fidima=fopen([nom 's.ima'],'rb');
fidlut=fopen([nom '.lut'],'rt');
X=uint8(fread(fidima,taille,'uchar'));
lut=fscanf(fidlut,'%d',inf);
numcol=length(lut)/3;
map=[...
lut(1:numcol) ...
lut(numcol+1:2*numcol) ...
lut(2*numcol+1:3*numcol) ...
]/255.0;
numcol=sum(sum(map ~= 0))/3;
set(figure,...
'MenuBar','none',...
'Name',['Image cod�e avec ' int2str(numcol) ' couleurs'])
image(X)
colormap(map)
axis equal
set(gca,'Xtick',[],'Ytick',[])
zoom on
fclose(fidima);
fclose(fidlut);
