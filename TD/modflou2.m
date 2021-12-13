function H=modflou2(N,a,b)

% modele de dégradation  de flou
% ligne de commande : H=modflou2 (N,a,b);
% NxN dimension de la reponse en frequence
% a et b diametres exprimes en frequence reduite

if nargin ~= 3
   error('ligne de commande : H=modflou2 (N,a,b);');
end

Nmini=32;
Nmini2=Nmini/2;
a2=(a*Nmini)*(a*Nmini);
b2=(b*Nmini)*(b*Nmini);
[X,Y]=meshgrid((1:Nmini)-Nmini2-1,(1:Nmini)-Nmini2-1);
RAYON=0.610*sqrt(X.*X/a2+Y.*Y/b2);
clear X Y
Hmini=besselj(1,2*pi*RAYON)./(pi*RAYON);
clear RAYON
Hmini(Nmini2+1,Nmini2+1)=1;
hmini=fftshift(real(ifft2(fftshift(Hmini))));
h=zeros(N);
N2=N/2;
h(N2+1-Nmini2:N2+Nmini2,N2+1-Nmini2:N2+Nmini2)=hmini;
H=fftshift(real(fft2(fftshift(h))));

