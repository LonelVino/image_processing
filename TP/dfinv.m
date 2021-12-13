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