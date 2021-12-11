% swapoctets.m
% conversion entiers non signés

function ASW=swapoctets(A,bits);
ASW=zeros(size(A));
for n=0:8:(bits-8)
    ASW=ASW+(2^n)*floor(rem(A,2^(bits-n))/(2^(bits-n-8)));
end
