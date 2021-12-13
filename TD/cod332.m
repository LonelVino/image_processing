% fichier cod332.m
% ligne de commande :
% [X,map]=cod332(nom)
% nom : nom du fichier � traiter

% .ima file:
% IMA 此种类型的图片文件，就以相当简单的方式，以数字阵列的形式保存图片。 
% 相比其他诸如 JPG、BMP，IMA 没有经过任何压缩，且可以记录非常宽的光谱各个波长组分的信息。 而且还可以直接作为矩阵或阵列直接在程式中使用，在 MATLAB、labview 等软件中可以直接获取数据进行傅里叶转换、滤波等处理。


function [X,map]=cod332(nom)
[racine,taille]=ecrirec24(nom);  % root, size
% dos: 执行 DOS 命令并返回输出
dos(['cod332 -f' racine ' -l' int2str(taille(1)) ' -c' int2str(taille(2))]);
[X,map]=lirec8(racine,taille);
dos(['del ' racine 's.ima']);
dos(['del ' racine 'r.ima']);
dos(['del ' racine 'v.ima']);
dos(['del ' racine 'b.ima']);
dos(['del ' racine '.lut']);

function [racine,taille]=ecrirec24(nom)
% Create 3 image, red, green, blue image of original image respetively
% Args:
%   nom: name of root image file
% Return:
%   root and size
racine=nom(1:strfind(nom,'.')-1);
RVB=imread(nom);
if size(RVB,3) ~= 3   % size(A,dim) 返回维度 dim 的长度, RGB -> length: 3
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