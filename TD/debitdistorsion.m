% debitdistorsion.m

function debitdistorsion(nom)
if nargin==0
    nom='lena512.bmp';
end
taillebloc=8;
X=double(imread(nom));
X=X+rand(size(X));

q=[0.25 0.5 1 2 4 8 16 32];
debit=[];
distorsion=[];
for n=1:length(q)
    N=floor(X/q(n)+0.5);
    Xq=N*q(n);
    Nmax=max(N(:));
    Nmin=min(N(:));
    H=hist(N(:),Nmin:Nmax);
    H=H/sum(H);
    index=(H~=0);
    E=-sum(H(index).*log2(H(index)));
    debit=[debit;E];
    distorsion=[distorsion;10*log10((255^2)/(sum((X(:)-Xq(:)).^2)/numel(X)))];
end

nblig=size(X,1)/taillebloc;
nbcol=size(X,2)/taillebloc;
Y=zeros(size(X));
Xq=zeros(size(X));
for lig=1:nblig
    for col=1:nbcol
        Y(1+(lig-1)*taillebloc:lig*taillebloc,1+(col-1)*taillebloc:col*taillebloc)= ...
        dct2(X(1+(lig-1)*taillebloc:lig*taillebloc,1+(col-1)*taillebloc:col*taillebloc));
    end
end

debitdct=[];
distorsiondct=[];
for n=1:length(q)
    N=floor(Y/q(n)+0.5);
    Yq=N*q(n);
    Nmax=max(N(:));
    Nmin=min(N(:));
    H=hist(N(:),Nmin:Nmax);
    H=H/sum(H);
    index=(H~=0);
    E=-sum(H(index).*log2(H(index)));
    debitdct=[debitdct;E];
    for lig=1:nblig
        for col=1:nbcol
            Xq(1+(lig-1)*taillebloc:lig*taillebloc,1+(col-1)*taillebloc:col*taillebloc)= ...
            idct2(Yq(1+(lig-1)*taillebloc:lig*taillebloc,1+(col-1)*taillebloc:col*taillebloc));
        end
    end
    distorsiondct=[distorsiondct;10*log10((255^2)/(sum((X(:)-Xq(:)).^2)/numel(X)))];
end

figure
h=plot(debit,distorsion,'-o',debitdct,distorsiondct,'-o');
title(['courbes débit distorsion avec ' nom])
xlabel('bits/pixel')
ylabel('PSNR (en dB)')
grid on
legend(h,'sans transformation','avec DCT par bloc','Location','NorthWest')





