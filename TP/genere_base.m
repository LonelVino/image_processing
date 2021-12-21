% function genere_base(reference,base,N)
% reference : Name of the directory containing the initial forms
% base : Name of the directory storing the initial forms
% type_image_ref : type des images de reference
% type_image_base : type des images generees dans la base
% N : nombre d'images generees
function genere_base(reference,base,type_image_ref,type_image_base,N)
if nargin == 0
    reference = 'reference';
    base = 'appr';
    type_image_ref = 'bmp';
    type_image_base = 'png';
    N = 100;
end

close all
% dos(['del /q .\' base '\*.*']);
dos(['rm -f /' base '/*.*']);  % Delete all file in folder 'appr'
sigma=0.05;  % the amplitude of the noise
DeltaX=22; DeltaY=22; 
NX=10; NY=10;
liste=dir(fullfile(reference,['*.' type_image_ref])); % list of reference images
Nfile=length(liste);  % number of reference images

% Generate N training images based on all the reference images by selecting randomly
for n=1:N
    classe=randi(Nfile,1);
    nom=fullfile(reference,liste(classe).name); % full path of reference file
    ima=~imread(nom);
    [L,C]=size(ima);
    rota=pi*rand(1);  % random rotate angle
    ech=0.4+0.6*rand(1);  % sampling size
    R=[cos(rota) -sin(rota);sin(rota) cos(rota)];
    M=ech*R;  
    U0=[C/2;L/2]; X0=[C/2;L/2];
    TR=X0-M*U0;
    A=[M TR]';

    T=affine2d(A);  % stores information about a 2-D affine geometric transformation and enables forward and inverse transformations.
    R=imref2d(size(ima));  % Reference 2-D image to world coordinates
    ima=imwarp(ima,T,'cubic','OutputView',R);  % Apply the geometric transformation 'T' to the image

    liste_points=cell(NX,NY); % create a indexed data containers, contain any type of data. like a dictionary
    for nx=1:NX
        for ny=1:NY
            liste_points{nx,ny}=[(nx-1)*DeltaX+(DeltaX/10)*randn(1) ...
                (ny-1)*DeltaY+(DeltaY/10)*randn(1)];
        end
    end
    ima_transf=transf_deform (ima,DeltaX,DeltaY,liste_points);
    ima=zeros(L,C);
    ima(1:size(ima_transf,1),1:size(ima_transf,2))=ima_transf;

    % Enhancement, decrease the strength of low gray level value, increase the strength of high gray level value
    nivmin=0.3*rand(1);
    nivmax=nivmin+0.4+0.3*rand(1);
    mes=(ima<0.5)*nivmin+(ima>=0.5)*nivmax;
    mes=mes+sigma*(1-2*rand(size(mes)));  % add noise

    imshow(mes),drawnow
    imwrite(mes,fullfile(base,['mesure' sprintf('%03d',n) '.' ...
        type_image_base]));
    fid=fopen(fullfile(base,['mesure' sprintf('%03d',n) '.txt']),'w');
    fprintf(fid,'%d',classe);
    fclose(fid);
end