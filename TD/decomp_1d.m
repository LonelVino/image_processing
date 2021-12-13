% fichier decomp_1d.m

function [x0,x1]=decomp_1d(x,h0,h1)
% si un argument, on prend la (9,7)
if nargin==1
    h0=[...
            +0.026748757410810;...
            -0.016864118442875;...
            -0.078223266528990;...
            +0.266864118442875;...
            +0.602949018236360;...
            +0.266864118442875;...
            -0.078223266528990;...
            -0.016864118442875;...
            +0.026748757410810...
        ];
    h1=[...
            +0.091271763114250;...
            -0.057543526228500;...
            -0.591271763114250;...
            +1.115087052457000;...
            -0.591271763114250;...
            -0.057543526228500;...
            +0.091271763114250...
         ];            
end
T=size(x);
if(T(2)~=1)
    disp('x doit etre un vecteur colonne')
    return
end
T=size(h0);
if(T(2)~=1)
    disp('h0 doit etre un vecteur colonne')
    return
end
if(rem(T(1),2)==0)
    disp('h0 doit avoir un nombre impair de coefficients')
    return
end
% Kh0 : nombre de coefficients dans h0
Kh0=T(1);
T=size(h1);
if(T(2)~=1)
    disp('h1 doit etre un vecteur colonne')
    return
end
if(rem(T(1),2)==0)
    disp('h1 doit avoir un nombre impair de coefficients')
    return
end

N=size(x,1);

xcomp=[x(1+(Kh0+1)/2:-1:2);x;x(end-1:-1:end-1-(Kh0+1)/2)];
x0=conv(h0,xcomp);
x1=conv(h1,xcomp);

if(rem(N,2)==0)
   x0=x0(Kh0+1:2:N+Kh0);
   x1=x1(Kh0+1:2:N+Kh0);
else
   x0=x0(Kh0+1:2:N+Kh0);
   x1=x1(Kh0+1:2:N+Kh0-2);
end

