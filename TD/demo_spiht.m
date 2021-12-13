% demo_spiht.m
% codage d'image avec ondelettes + spiht
% nom : nom du fichier image
% recurs : profondeur de récursion
% debit : debit binaire à atteindre

function PSNR=demo_spiht(nom,recurs,debit)
if nargin==0
    nom='lena512.bmp';
    recurs=4;
    debit=1;
end

X=lireimagenb(nom);

[X_c,~,Ynorm,Ynorm_c]=spiht(X,recurs,debit);

warning off
figure,image(X),colormap(gray(256)),axis equal
colorbar
set(gca,'XTick',[],'YTick',[])
title('image initiale')
figure,imagesc(20*log10(abs(Ynorm)),[-30 70]),colormap(gray(256)),axis equal
colorbar
set(gca,'XTick',[],'YTick',[])
title('puissances dans l''image transformée (en dB)')
figure,imagesc(20*log10(abs(Ynorm_c)),[-30 70]),colormap(gray(256)),axis equal
colorbar
set(gca,'XTick',[],'YTick',[])
title('puissances dans l''image transformée quantifiée (en dB)')
figure,image(X_c),colormap(gray(256)),axis equal
colorbar
set(gca,'XTick',[],'YTick',[])
title('image codée')

puissanceX=sum(X(:).^2)/numel(X);
puissanceY=sum(Ynorm(:).^2)/numel(X);
distorsionX=sum((X(:)-X_c(:)).^2)/numel(X);
distorsionY=sum((Ynorm(:)-Ynorm_c(:)).^2)/numel(X);
PSNR=10*log10((255^2)/distorsionX);

disp(['débit binaire mesuré ' num2str(debit) ' bits/pixel'])
disp(['PSNR ' num2str(PSNR) ' dB'])
disp(['puissance dans image ' num2str(10*log10(puissanceX)) ' dB'])
disp(['puissance dans plan transformé ' num2str(10*log10(puissanceY)) ' dB'])
disp(['puissance bruit dans image ' num2str(10*log10(distorsionX)) ' dB'])
disp(['puissance bruit dans plan transformé ' num2str(10*log10(distorsionY)) ' dB'])

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