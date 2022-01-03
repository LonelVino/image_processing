% fichier propagation.m
% ligne de commande :
% [X,map]=propagation(nom,niveau)
% name : filename of the image
% niveau: level of restitution
% X : image d'index
% map : palette

function [X,map]=propagation(nom,niveau)
%% Draw Initial Image
niveau=niveau-1;
X=lireimagenb(nom);
% set(figure,...
% 'MenuBar','none',...
% 'NumberTitle','off',...
% 'Name','Image initiale')
% imshow(uint8(X)),zoom on
% drawnow

%% Error Propogation
I=X/255;  % nomarlized
clear X;
I_l=size(I,1); I_c=size(I,2);
ligne_prec=zeros(1,I_c);   % point precision of images, size: (1, columns number of image)
point_prec=0;
Icode=zeros(I_l,I_c);
q=(1/niveau);

for l=1:I_l
   for c=1:I_c
      xc=I(l,c)+0.5*(point_prec+ligne_prec(c)); % Original Image Gray Value + (h * error), h -- interpolation function
      xq=q*round(xc/q);  % final value of coded images
      Icode(l,c)=xq;
      point_prec=xc-xq;  % point precision (error) 
      ligne_prec(c)=xc-xq;         
   end
end

%% Restitution
X=uint8(255*Icode);  % [0,1] -> [0,255], integer
clear Icode

entree=0;  % the number of unique gray value in the quantized image
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

% set(figure,...
% 'MenuBar','none',...
% 'NumberTitle','off',...
% 'Name','Image cod�e')
% imshow(X,map),zoom on
% drawnow


function X=lireimagenb(nom)
extension=nom(strfind(nom,'.')+1:end);
switch extension
    case 'ima'
        fid=fopen(nom,'rb');
        X=fread(fid,[256 256],'uint8');
        fclose(fid);
    otherwise
        info=imfinfo(nom);  % information about the image
        switch info.ColorType
            case 'truecolor'  % if color image, convert it into gray scale
                X=imread(nom);
                X=rgb2gray(X);
                disp('image initiale truecolor')
            case 'grayscale'  % if gray scale, read image directly
                X=imread(nom);
                disp('image initiale grayscale')
            case 'indexed'   % if indexed image, convert it into gray scale
                [X,map]=imread(nom);
                X=ind2gray(X,map);
                if strcmp(class(X),'double')
                    X=uint8(255*X);
                end
                disp('image initiale indexed')
        end
end
X=double(X);