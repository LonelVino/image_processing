function res = calcul_entropie(X, recurs)
% Computes the first order entropy of an image decomposed into sub-bands 
% with a recursive depth
% Args:
%   X: array of images
%   recurs: the recursive depth
% Returns:
%   res: the first order entropy 

[LIG,COL]=size(X);
if recurs >= 1
    res=calcul_entropie_bande(X(1:floor((LIG+1)/2),floor((COL+1)/2)+1:COL));
    res=res+calcul_entropie_bande(X(floor((LIG+1)/2)+1:LIG,1:floor((COL+1)/2)));
    res=res+calcul_entropie_bande(X(floor((LIG+1)/2)+1:LIG,floor((COL+1)/2)+1:COL));
    res=(res+calcul_entropie(X(1:floor((LIG+1)/2),1:floor((COL+1)/2)),recurs-1))/4;
else
    res=calcul_entropie_bande(X);
end

function entropie=calcul_entropie_bande(X)
[LIG,COL]=size(X);
mini = min(X(:));
maxi = max(X(:));
if(mini==maxi)
    entropie=0;
else
    % hist(x,nbins) 将 x 有序划分入标量 nbins 所指定数量的 bin 中。
    P = hist(reshape(X,LIG*COL,1),mini:1:maxi)/(LIG*COL);
    P = P + (P == 0);
    entropie = - sum(P .* log2(P));
end