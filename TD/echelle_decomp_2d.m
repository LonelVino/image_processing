% echelle_decomp_2d.m

function Y=echelle_decomp_2d(X,recurs,prof)
if recurs >= 1
    coeffHL=2^(prof-1);
    coeffLH=2^(prof-1);
    coeffHH=2^(prof-2);
else
    coeffLL=2^(prof-1);
end
[LIG,COL]=size(X);
if recurs >= 1
    X(1:floor((LIG+1)/2),floor((COL+1)/2)+1:COL)=...
        coeffHL*X(1:floor((LIG+1)/2),floor((COL+1)/2)+1:COL);
    X(floor((LIG+1)/2)+1:LIG,1:floor((COL+1)/2))=...
        coeffLH*X(floor((LIG+1)/2)+1:LIG,1:floor((COL+1)/2));
    X(floor((LIG+1)/2)+1:LIG,floor((COL+1)/2)+1:COL)=...
        coeffHH*X(floor((LIG+1)/2)+1:LIG,floor((COL+1)/2)+1:COL);
    X(1:floor((LIG+1)/2),1:floor((COL+1)/2))=...
        echelle_decomp_2d(X(1:floor((LIG+1)/2),1:floor((COL+1)/2)),recurs-1,prof+1);
else
    X=coeffLL*X;
end
Y=X;
