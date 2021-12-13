%fichier parbloc.m

function parbloc(nom,M)
Y=lireimagenb(nom);
Y=Y/255;
set(figure,...
'MenuBar','none',...
'Name','Image originale')
imshow(Y)
zoom on
drawnow
Ycod=zeros(size(Y));
N=512;
K=N/M;

for k=1:K
   for l=1:K
      bloc=Y(M*(k-1)+1:M*(k-1)+M,M*(l-1)+1:M*(l-1)+M);
      moy=sum(sum(bloc))/(M^2);
      ener=sum(sum(bloc.^2))/(M^2);
      sigma=sqrt(ener-(moy^2));
      blocbin=(bloc>=moy);
      q=sum(sum(blocbin));
      if q~=(M^2)
         A=moy-sigma*sqrt(q/((M^2)-q));   
         B=moy+sigma*sqrt(((M^2)-q)/q);   
      else
         A=moy;
         B=moy;
      end   
      Ycod(M*(k-1)+1:M*(k-1)+M,M*(l-1)+1:M*(l-1)+M)=...
      B*blocbin+A*(~blocbin);
   end
end
set(figure,...
'MenuBar','none',...
'Name','Image codée par bloc')
imshow(Ycod)
zoom on
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