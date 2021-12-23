function ima = lireima(nom)
if nargin ~= 1
   error('usage : ima=lireima(''nom image'')');
end
fid=fopen(nom,'rb');
fseek(fid,0,'eof');
taille=ftell(fid);
if taille==128^2
   dim=128;
   disp('image 128x128')
elseif taille==256^2
   dim=256;
   disp('image 256x256')
elseif taille==512^2
   dim=512;
   disp('image 512x512')
else
   error('image de dimension 256 ou 512');
end
fseek(fid,0,'bof');
ima=uint8(fread(fid,[dim dim],'uchar'));
fclose(fid);
set(figure,...
'MenuBar','none',...
'NumberTitle','off',...
'Name','Image')
image(ima)
set(gca,'Xtick',[],'Ytick',[])
zoom on
colormap(gray(256))