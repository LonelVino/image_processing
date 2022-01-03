% fichier optimnb.m
% ligne de commande :
% X=optimnb(nom,niveau)
% X : image r�sultat
% nom : nom du fichier � traiter
% niveau : nombre de niveaux

function [X,map]=optimnb(nom,niveau)

[ima,racine]=lireimagenb(nom)
% racine = strcat('.\img\', racine);
disp(racine)
figure,image(ima),axis equal,colormap(gray(256)),drawnow

fid=fopen([racine 'ent.ima'],'wb');
fwrite(fid,ima,'uint8');
fclose(fid);

dos(['scalaire -e' racine 'ent.ima -s' racine 'sor.ima -N' int2str(niveau)]);

fid = fopen([racine 'sor.ima'], 'rb');
X=uint8(fread(fid,size(ima),'uint8'));
fclose(fid);

dos(['del ' racine 'ent.ima']);
dos(['del ' racine 'sor.ima']);

entree=0;
map=[];
for n=0:255
    index=find(X==n);
    if ~isempty(index)
        X(index)=entree;
        entree=entree+1;
        map=[map;[n n n]/255];
    end
end

figure,image(X),axis equal,colormap(map)

function [X,racine]=lireimagenb(nom)
racine=nom(1:findstr(nom,'.')-1);
extension=nom(findstr(nom,'.')+1:end);
switch extension
    case 'ima'
        fid=fopen(nom,'rb');
        X=fread(fid,[256 256],'uint8');
        fclose(fid);
    otherwise
        info=imfinfo(nom);
        switch info.ColorType
            case 'truecolor'
                X=imread(nom);
                X=rgb2gray(X);
                disp('image initiale truecolor')
            case 'grayscale'
                X=imread(nom);
                disp('image initiale grayscale')
            case 'indexed'
                [X,map]=imread(nom);
                X=ind2gray(X,map);
                if strcmp(class(X),'double')
                    X=uint8(255*X);
                end
                disp('image initiale indexed')
        end
end
X=double(X);

