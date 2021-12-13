### 1 Characterization of forms and classification 

#### 1.1 General presentation 

##### 1.1.1 Introduction 

The classification methods<u>**: "k-means" and the "k nearest neighboring".**</u>  (Python (in `SCIKIT-LEARN`) or MATLAB (``kmeans` and `fitcknn`), Here, we will use matlab with the "Toolboxes" statistics and machine learning and image processing. 

##### 1.1.2 Deliverables

###### 1.1.2.2 Programs

Autonomous: launched again without problems in a new session of Matlab and on another workstation. 

Write functions with useful params and a script with different params to test these functions. 

#### 1.2 Work to be carried out

##### 1.2.1 Generating an image base

Create a new folder `appr`

`Genere_Base`: This command will create 100 `mesurexxx.png` image files and 100 text files `measurexxx.txt` in the `appr` directory. The created images are built from initial shapes stored in the `reference` Directory, and correspond to random rotations, homotheties, and small deformations . 

##### 1.2.2 Viewing an image base 

`Visu_Base` 

###### 1.2.3 Obtaining a binary image

 on the black and white image, test with the function `imbinarize` the generation of a binary image. 

Explain and illustrate the method used by this function by observing the <u>histogram</u> of the images before <u>thresholding</u>. 

###### 1.2.4 Extraction of the contour of the shape

 with the `bwboundaries` , generate the sequence of <u>complex numbers</u> that will allow the <u>calculation of Fourier descriptors</u> (see the `dfdir` function in 2.1.1). 

<u>Rebuild an outline</u> from these descriptors (see Function `dfinv` in 2.1.2) to qualitatively <u>assess the influence of the `cmax` parameter</u>. To <u>obtain independent attributes of the rotation,</u> the module of the **<u>coefficients</u>** provided by the `dfdir` function will then be taken.

##### 1.2.5 Other geometric parameters

Use  `RegionProps` on the binary image, in order to obtain <u>parameters on shapes without having to extract a cont</u>our. 

**Find parameters that also independent of translation, rotation and homothetics.** 

##### 1.2.6 Principal Component Analysis

 <u>The parameters</u> chosen to perform a <u>classification</u> will be the modules of the coefficients obtained with the <u>Fourier descriptor method.</u> 

 `PCA`:  reduce any information redundancies of the parameters

 **Interpret the result of this analysis and choose the number of components to keep for the following steps.** 

##### 1.2.7 K-average method 

`kmeans`  on data from the PCA to find prototype vectors in the parameter space. 

**Represent these vectors in the parameter space and check their adequacy with the data.** 

##### 1.2.8 K-nearest Method

 `fitcknn` : build a classification method operating the data from the learning base. The methods are saved in Classification-type objects.

**Build the method operating the result of the K-means (with K = 1, the vector quantization is made) and the method directly operating the learning base data.** 

###### 1.2.9 Performance Assessment

 Create a `test` directory and call again the `genere_base` function with the appropriate settings. 

 `predict` : implement the previously constructed classification methods. 

**Launch the different methods previously constructed on the same test base and compare the results obtained.** 

##### 1.2.10 Generalization to other forms

 in the `reference` directory, the initial images used to generate the different bases are arbitrarily chosen. 

**Offer other initial images to test your program in a more general context.**

#### 2. Annexes

##### 2.1 Function of Matlab 

###### 2.1.1  dfdir.m 

 ```matlab
 % fonction coeff=dfdir(z,cmax) 
 % z : suite complexe représentant le contour 
 % cmax : les coefficients d'indice -cmax à cmax sont conservés 
 % coeff : tableau des 2*cmax+1 coefficients complexes 
 function coeff=dfdir(z,cmax) 
 % on calcule la moyenne 
 z_moy=mean(z); 
 N=length(z); 
 % on calcule les coefficients de Fourier 
 TC=fft(z-z_moy)/N; 
 num=(-cmax):cmax; 
 % on sélectionne les coefficients entre -cmax et cmax 
 coeff=zeros(2*cmax+1,1); 
 coeff(end-cmax:end)=TC(1:cmax+1); 
 coeff(1:cmax)=TC(end-cmax+1:end); 
 % on retourne la séquence si le parcours est dans le 
 % sens inverse au sens trigonométrique 
 if abs(coeff(num==-1))>abs(coeff(num==1)) 
     coeff=coeff(end:-1:1); 
 end 
 % normalisation d'échelle 
 coeff=coeff/abs(coeff(num==1)); 
 ```





###### 2.1.2  dfinv.m  

```matlab
% fonction z=dfinv(coeff,N) 
% coeff : tableau des 2*cmax+1 oefficients complexes 
% N : nombre de points pour le contour reconstruit 
% z : suite complexe avec N éléments représentant le contour reconstruit 
function z=dfinv(coeff,N) 
cmax=(length(coeff)-1)/2; 
TC=zeros(N,1); 
TC(1:cmax+1)=coeff(end-cmax:end); 
TC(end-cmax+1:end)=coeff(1:cmax); 
z=ifft(TC)*N;
```

###### 2.1.3 genere_base.m 

```matlab

% fonction genere_base(reference,base,N) 
% reference : nom du répertoire contenant les formes initiales 
% base : nom du répertoire où seront stockées les images 
% type_image_ref : type des images de reference 
% type_image_base : type des images générées dans la base 
% N : nombre d'images générées 
function genere_base(reference,base,type_image_ref,type_image_base,N) 
if nargin==0 
    reference='reference'; 
    base='appr'; 
    type_image_ref='bmp'; 
    type_image_base='png'; 
    N=100; 
end 
close all 
dos(['del /q .\' base '\*.*']); 
sigma=0.05; 
DeltaX=22;DeltaY=22; 
NX=10;NY=10; 
liste=dir(fullfile(reference,['*.' type_image_ref])); 
Nfile=length(liste); 
for n=1:N 
    classe=randi(Nfile,1); 
    nom=fullfile(reference,liste(classe).name); 
    ima=~imread(nom); 
    [L,C]=size(ima); 
    rota=pi*rand(1); 
    ech=0.4+0.6*rand(1); 
    R=[cos(rota) -sin(rota);sin(rota) cos(rota)]; 
    M=ech*R; 
    U0=[C/2;L/2];X0=[C/2;L/2]; 
    TR=X0-M*U0; 
    A=[M TR]'; 
    T=affine2d(A); 
    R=imref2d(size(ima)); 
    ima=imwarp(ima,T,'cubic','OutputView',R); 
    liste_points=cell(NX,NY); 
    for nx=1:NX 
        for ny=1:NY 
            liste_points{nx,ny}=[(nx-1)*DeltaX+(DeltaX/10)*randn(1) ... 
                (ny-1)*DeltaY+(DeltaY/10)*randn(1)]; 
        end 
    end 
    ima_transf=transf_deform (ima,DeltaX,DeltaY,liste_points); 
    ima=zeros(L,C); 
    ima(1:size(ima_transf,1),1:size(ima_transf,2))=ima_transf; 
    nivmin=0.3*rand(1); 
    nivmax=nivmin+0.4+0.3*rand(1); 
    mes=(ima<0.5)*nivmin+(ima>=0.5)*nivmax; 
    mes=mes+sigma*(1-2*rand(size(mes))); 
    imshow(mes),drawnow 
    imwrite(mes,fullfile(base,['mesure' sprintf('%03d',n) '.' ... 
        type_image_base])); 
    fid=fopen(fullfile(base,['mesure' sprintf('%03d',n) '.txt']),'w'); 
    fprintf(fid,'%d',classe); 
    fclose(fid); 
end
```

###### 2.1.4  visu_base.m

```matlab


% fonction visu_base(base,arretimage) 
% base : nom du répertoire contenant la base d'images 
% type_image_base : type des images dans la base 
% arretimage : si 0, le défilement est continu, si 1, il faut appuyer sur 
% une touche pour obtenir le défilement image par image. 
function visu_base(base,type_image_base,arretimage) 
if nargin==0 
    base='appr'; 
    type_image_base='png'; 
    arretimage=0; 
end 
close all 
liste=dir(fullfile(base,['*.' type_image_base])); 
set(figure,'Units','normalized','Position',[5 5 90 85]/100) 
for n=1:length(liste) 
    nom=liste(n).name; 
    Y=double(imread(fullfile(base,nom)))/255; 
    fid=fopen(fullfile(base,[nom(1:strfind(nom,'.')-1) '.txt']),'r'); 
    classe=fscanf(fid,'%d'); 
    fclose (fid); 
    subplot(1,2,1) 
    imshow(Y),title(['fichier ' nom ', classe ' int2str(classe)]),drawnow 
    subplot(1,2,2) 
    % on peut ici rajouter le code associé à différents traitements 
    imshow(Y),title('image noir et blanc'),drawnow 
    if arretimage 
        pause() 
    end 
end
```

