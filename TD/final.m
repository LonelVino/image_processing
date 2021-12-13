% fichier final.m
% final(nom,ld,lf,cd,cf)
% pour 2P3G.bmp (151,450,181,480)
% pour BV2.bmp  (251,550, 51,350)

function final(nom,ld,lf,cd,cf)
if nargin == 0
   nom='2P3G.bmp';
   ld=151;% premiere ligne de l'extrait
   lf=450;% derniere ligne de l'extrait
   cd=181;% premiere colonne de l'extrait
   cf=480;% derniere colonne de l'extrait
   % pour BV2.bmp (251,550,51,350)
end

iptsetpref('ImshowBorder', 'tight')
beta=15;% parametre de la fenetre de kaiser
ecart=30;% en dB pour calculer le seuil
seuilbin=0.25; % seuil pour la détection
NFFTL=512;% taille de la fft 2D en ligne
NFFTC=512;% taille de la fft 2D en colonne
N2L=floor(NFFTL/2);
N2C=floor(NFFTC/2);
voisl=floor(NFFTL/128);% pour définir la zone basse fréquence
voisc=floor(NFFTC/128);% pour définir la zone basse fréquence
ima=imread(nom);
imaext=ima(ld:lf,cd:cf);
imaext(5:10,200:210)=200+10*randn(size(imaext(5:10,200:210)));
% défaut artificiel
imaext(80:82,100:120)=200+5*randn(size(imaext(80:82,100:120)));
% défaut artificiel
figure
imshow(imaext)
zoom on
drawnow
taille=size(imaext);
L=taille(1);
C=taille(2);
fenetrel=kaiser(L,beta);
fenetrec=kaiser(C,beta);

transfext=fft2(double(imaext),NFFTL,NFFTC);
transffil=fft2(double(imaext).*(fenetrel*fenetrec'),NFFTL,NFFTC);

visufil=20*log10(abs(transffil));
minimum=min(min(visufil));
visufil=fftshift(visufil);
visufil(N2L+1-voisl:N2L+1+voisl,N2C+1-voisc:N2C+1+voisc)=minimum; 
visufil=fftshift(visufil);
maximum=max(max(visufil));
visufil=fftshift(visufil);
visufil(N2L+1-voisl:N2L+1+voisl,N2C+1-voisc:N2C+1+voisc)=maximum; 
visufil=fftshift(visufil);
figure
imagesc((-N2L:N2L-1)/NFFTL,(-N2C:N2C-1)/NFFTC,fftshift(visufil));
axis('square')
colormap(jet);
colorbar
zoom on 
grid on
drawnow
seuil=maximum-ecart;
visufil=(visufil<=seuil);
visufil=fftshift(visufil);
visufil(N2L+1-voisl:N2L+1+voisl,N2C+1-voisc:N2C+1+voisc)=1; 
visufil=fftshift(visufil);

figure
imagesc((-N2L:N2L-1)/NFFTL,(-N2C:N2C-1)/NFFTC,fftshift(visufil));
axis('square')
palette(1,:)=[0 0 0];
palette(2,:)=[1 1 1];
colormap(palette);
zoom on 
grid on
drawnow

imares=real(ifft2(visufil.*transfext));
figure
imshow(imares(1:L,1:C),[])
colormap(gray(256))
zoom on 
drawnow

figure
voismin=20;
disp(['dimension de l''image : ' ...
      int2str(L)...
      ' lignes, ' ...
      int2str(C) ...
      ' colonnes'])
disp(['voisinage pour le minimum : ' int2str(voismin)])
envmin=zeros(1,C);
imafin=zeros(L,C);
h=imshow(uint8(255-imafin));
drawnow;
for l=1:L
   lig=imares(l,1:C);
   ligmin=[lig(1)*ones(1,voismin) lig lig(C)*ones(1,voismin)];
   for c=1:C
      envmin(c)=min(ligmin(c:c+2*voismin));
   end
   imafin(l,:)=lig-envmin;
   if(rem(l,20)==0)
      set(h,'CData',uint8(255-imafin));
      drawnow
   end
end
set(h,'CData',uint8(255-imafin));
zoom on
drawnow

imabin=imbinarize(uint8(imafin),seuilbin);
figure
imshow(imabin)
zoom on
drawnow

imabin=bwmorph(imabin,'close');
imabin=bwmorph(imabin,'open');
figure
imshow(imabin)
zoom on
drawnow

[objets,num]=bwlabel(imabin);
figure
imshow(uint8(objets))
palette=zeros(256,3);
palette(1,:)=[0 0 0];
palette(2:num+1,:)=rand(num,3);
colormap(palette)
zoom on
drawnow

if num==0
   disp('pas de défauts détectés')
else
   for n=1:num
      [l,c,v]=find(objets==n);
      disp(['défaut numéro ' int2str(n)...
            '  position = (' ...
            int2str(round(sum(l)/length(v)))...
            ',' ...
            int2str(round(sum(c)/length(v)))...
            ')  surface = ' int2str(length(v))... 
         ])
   end
end

