% recomp_2d.m

function Y=recomp_2d(X,recurs,g0,g1)
% si deux argument, on prend la (9,7)
if nargin==2
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
[LIG,COL]=size(X);
if recurs > 1
    X(1:floor((LIG+1)/2),1:floor((COL+1)/2))=recomp_2d(X(1:floor((LIG+1)/2),1:floor((COL+1)/2)),recurs-1,g0,g1);
end
for lig=1:LIG
     ligne=X(lig,:);
     x0=ligne(1:floor((COL+1)/2))';
     x1=ligne(floor((COL+1)/2)+1:COL)';
     y=recomp_1d(x0,x1,g0,g1);
     X(lig,:)=y';
end
for col=1:COL
     colonne=X(:,col);
     x0=colonne(1:floor((LIG+1)/2));
     x1=colonne(floor((LIG+1)/2)+1:LIG);
     y=recomp_1d(x0,x1,g0,g1);
     X(:,col)=y;
end
Y=X;