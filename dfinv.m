% fonction z = dfinv(coeff,N)
% Inverse FFT according to the FFT coeffiecnt 'coeff'
% Args:
% -------------------------------
%   coeff : tableau des 2*cmax+1 oefficients complexes
%   N : nombre de points pour le contour reconstruit
% Returns:
% -------------------------------
%   z : suite complexe avec N �l�ments repr�sentant le contour reconstruit
function z=dfinv(coeff,N)
    cmax=(length(coeff)-1)/2;
    TC=zeros(N,1);
    TC(1:cmax+1)=coeff(end-cmax:end);
    TC(end-cmax+1:end)=coeff(1:cmax);
    z=ifft(TC)*N;