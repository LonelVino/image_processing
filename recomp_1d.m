% fichier recomp_1d.m

function x=recomp_1d(x0,x1,g0,g1)
% si deux arguments, on prend la (9,7)
if nargin == 2
    g0=[...
            -0.091271763114250;...
            -0.057543526228500;...
            +0.591271763114250;...
            +1.115087052457000;...
            +0.591271763114250;...
            -0.057543526228500;...
            -0.091271763114250...
        ];
    g1=[...
            +0.026748757410810;...
            +0.016864118442875;...
            -0.078223266528990;...
            -0.266864118442875;...
            +0.602949018236360;...
            -0.266864118442875;...
            -0.078223266528990;...
            +0.016864118442875;...
            +0.026748757410810...
        ];
end

T=size(x0);
if(T(2)~=1)
    disp('x0 doit etre un vecteur colonne')
    return
end
T=size(x1);
if(T(2)~=1)
    disp('x1 doit etre un vecteur colonne')
    return
end

T=size(g0);
if(T(2)~=1)
    disp('g0 doit etre un vecteur colonne')
    return
end
if(rem(T(1),2)==0)
    disp('g0 doit avoir un nombre impair de coefficients')
    return
end
T=size(g1);
if(T(2)~=1)
    disp('g1 doit etre un vecteur colonne')
    return
end
if(rem(T(1),2)==0)
    disp('g1 doit avoir un nombre impair de coefficients')
    return
end
% Kg1 : nombre de coefficients dans g1
Kg1=T(1);

N0=size(x0,1);
N1=size(x1,1);
if(N0==N1)
    x0comp=[x0((Kg1+1)/2:-1:2);x0;x0(end:-1:end+2-(Kg1-1)/2)];
    x1comp=[x1((Kg1+1)/2-1:-1:1);x1;x1(end-1:-1:end+1-(Kg1-1)/2)];
    x0sur=zeros(2*length(x0comp),1);
    x1sur=zeros(2*length(x1comp),1);
    x0sur(1:2:end)=x0comp;
    x1sur(1:2:end)=x1comp;
    x0f=conv(g0,x0sur);
    x1f=conv(g1,x1sur);
    x=x0f(3*(Kg1-1)/2:3*(Kg1-1)/2-1+2*N0)+x1f(3*(Kg1-1)/2:3*(Kg1-1)/2-1+2*N0);
elseif(N0==(N1+1))
    x0comp=[x0((Kg1+1)/2-1:-1:2);x0;x0(end-1:-1:end+2-(Kg1-1)/2)];
    x1comp=[x1((Kg1+1)/2-2:-1:1);x1;x1(end:-1:end+2-(Kg1-1)/2)];
    x0sur=zeros(2*length(x0comp),1);
    x1sur=zeros(2*length(x1comp),1);
    x0sur(1:2:end)=x0comp;
    x1sur(1:2:end)=x1comp;
    x0f=conv(g0,x0sur);
    x1f=conv(g1,x1sur);
    x=x0f(3*(Kg1-1)/2-2:3*(Kg1-1)/2-3+N0+N1)+x1f(3*(Kg1-1)/2-2:3*(Kg1-1)/2-3+N0+N1);
else
    disp('dimensions de x0 et x1 incorrectes')
    return
end