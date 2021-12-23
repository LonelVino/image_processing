% fichier lpe.m
% application de la ligne de partage des eaux
% ligne de commande
% [ima,res]=lpe(nom,seuil,sigma,contour,attribut)
% nom : nom du fichier d'entr�e
% seuil : seuil pour le tri des minima en fonction de leur dynamique
% sigma : �cart-type d'un bruit additif sur l'image
% contour : si contour=1, un calcul de norme du gradient est effectu�
% attribut : si attribut=1, on affecte � chaque r�gion son niveau de gris
% moyen
% ima : image initiale
% res : image de label

function [ima,res]=lpe(nom,seuil,sigma,contour,attribut)
close all
if nargin==0
    nom='.\img\extrait.ima';
    seuil=5;
    sigma=0;
    contour=0;
    attribut=0;
end
seuil=seuil-1;
imainit=lireimagenb(nom);
imabruit=imainit+sigma*randn(size(imainit));
imabruit=(imabruit>=0).*imabruit;
imabruit=(imabruit<=255).*imabruit+(imabruit>255)*255;
imabruit=uint8(imabruit);
h=figure;
set(h,...
    'MenuBar','none',...
    'NumberTitle','off',...
    'Name','Image initiale',...
    'Units','normal',...
    'Position',[0.1 0.5 0.5 0.5]...
    )
imshow(imabruit)
zoom on
drawnow
if contour==1
    h=figure;
    horiz=[-1 -1 -1;0 0 0;1 1 1]/3;
    verti=[-1 0 1;-1 0 1;-1 0 1]/3;
    ima=abs(filter2(verti,imabruit))+abs(filter2(horiz,imabruit));
    ima=(ima>=0).*ima;
    ima=(ima<=255).*ima+(ima>255)*255;
    ima=uint8(ima);
    set(h,...
        'MenuBar','none',...
        'NumberTitle','off',...
        'Name','Image de contours',...
        'Units','normal',...
        'Position',[0.1 0.0 0.5 0.5]...
        )
    imshow(ima)
    zoom on
    drawnow
else
    ima=imabruit;
end
disp(['maximum de l''image trait�e : ' int2str(double(max(ima(:))))])
ima_mini=imextendedmin(ima,seuil);
ima_imp = imimposemin(ima,ima_mini);
res=watershed(ima_imp);

h=figure;
set(h,...
    'MenuBar','none',...
    'NumberTitle','off',...
    'Name','Image de labels',...
    'Units','normal',...
    'Position',[0.6 0.5 0.5 0.5]...
    )
imshow(res,[])
map=[rand(256,1) rand(256,1) rand(256,1)];
map(1,:)=[0 0 0];
colormap(map)
zoom on
drawnow

minimum=1;
maximum=double(max(max(res)));
if attribut==1
    h=figure;
    ima=double(imabruit);
    imattrib=zeros(size(ima));
    set(h,...
        'MenuBar','none',...
        'NumberTitle','off',...
        'Name','Image des attributs (niv. de gris moyen)',...
        'Units','normal',...
        'Position',[0.6 0.0 0.5 0.5]...
        )
    h=imshow(uint8(imattrib));
    for label=minimum:maximum
        index=find(res==label);
        popul=length(index);
        moyen=sum(ima(index))/popul;
        imattrib(index)=imattrib(index)+moyen;
        set(h,'CData',uint8(imattrib));
        drawnow
    end
    zoom on
    drawnow
end
disp(['nombre de r�gions : ' int2str(maximum)])

function X=lireimagenb(nom)
extension=nom(strfind(nom,'.')+1:end);
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
                if isa(X,'double')
                    X=uint8(255*X);
                end
                disp('image initiale indexed')
        end
end
X=double(X);
