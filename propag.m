% fichier propag.m
% ligne de commande :
% propag(nom)
% nom : nom du fichier à traiter

function [X,map]=propag(nom)
[racine,taille]=ecrirec24(nom);
dos(['propag -f' racine ' -l' int2str(taille(1)) ' -c' int2str(taille(2))]);
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
'Name','Image codée sur 24 bits')
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
'Name',['Image codée avec ' int2str(numcol) ' couleurs'])
image(X)
colormap(map)
axis equal
set(gca,'Xtick',[],'Ytick',[])
zoom on
fclose(fidima);
fclose(fidlut);