% fichier propagation.m
% ligne de commande :
% [X,map]=propagation(nom,niveau)
% nom : nom du fichier image
% niveau : nombre de niveaux de restitution
% X : image d'index
% map : palette

function [X,map]=propagation(nom,niveau)
niveau=niveau-1;
X=lireimagenb(nom);
set(figure,...
'MenuBar','none',...
'NumberTitle','off',...
'Name','Image initiale')
imshow(uint8(X)),zoom on
drawnow

I=X/255;
clear X;
I_l=size(I,1);
I_c=size(I,2);
ligne_prec=zeros(1,I_c);
point_prec=0;
Icode=zeros(I_l,I_c);
q=(1/niveau);

for l=1:I_l
   for c=1:I_c
      xc=I(l,c)+0.5*(point_prec+ligne_prec(c));
      xq=q*round(xc/q);
      Icode(l,c)=xq;
      point_prec=xc-xq;
      ligne_prec(c)=xc-xq;         
   end
end

X=uint8(255*Icode);
clear Icode
entree=0;
for n=0:255
    index=find(X==n,1);
    if ~isempty(index)
        entree=entree+1;
    end
end
map=zeros(entree,3);
entree=0;
for n=0:255
    index=find(X==n);
    if ~isempty(index)
        X(index)=entree;
        entree=entree+1;
        map(entree,:)=[n n n]/255;
    end
end

set(figure,...
'MenuBar','none',...
'NumberTitle','off',...
'Name','Image codée')
imshow(X,map),zoom on
drawnow

function X=lireimagenb(nom)
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