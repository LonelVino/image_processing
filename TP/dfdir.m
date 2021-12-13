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
