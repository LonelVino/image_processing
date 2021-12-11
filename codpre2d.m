% fichier codpre2d.m
% pour le codage avec erreur
% [Xq,deltaq,A]=codpre2d(X,A_l,A_c,deltamax,bits)

function [Xq,deltaq,A]=codpre2d(X,A_l,A_c,deltamax,bits)

X_l=size(X,1);
X_c=size(X,2);
deltaq=zeros(X_l,X_c);
A=zeros(A_l,A_c);
R=zeros(A_l*A_c-1);
r=zeros(A_l*A_c-1,1);
q=(2*deltamax)/(2^bits-1);

X_corr=zeros(2*A_l-1,2*A_c-1);

for l=0:A_l-1
   for c=-(A_c-1):(A_c-1)
      if c >=0
         X_corr(A_l+l,A_c+c)=sum(sum(X(1:X_l-l,1:X_c-c).*X(l+1:X_l,c+1:X_c)));
      else
         X_corr(A_l+l,A_c+c)=sum(sum(X(1:X_l-l,1-c:X_c).*X(l+1:X_l,1:X_c+c)));
      end
      X_corr(A_l-l,A_c-c)=X_corr(A_l+l,A_c+c);
   end
end

index0=1;
for l0=0:A_l-1
   for c0=0:A_c-1
      if l0~=0 || c0~=0
         r(index0)=X_corr(A_l+l0,A_c+c0);
         index0=index0+1;
      end
   end
end

index0=1;
for l0=0:A_l-1
   for c0=0:A_c-1
      if l0~=0 || c0~=0
         index=1;
         for l=0:A_l-1
            for c=0:A_c-1
               if l~=0 || c~=0
                  R(index0,index)=X_corr(A_l+l0-l,A_c+c0-c);
                  index=index+1;
               end
            end
         end
         index0=index0+1;
      end
   end
end

A_vec=R\r;

index=1;
for l=0:A_l-1
   for c=0:A_c-1
      if l~=0 || c~=0
         A(1+l,1+c)=-A_vec(index);
         index=index+1;
      end
   end
end

A=rot90(A,2);

Xmemoire=zeros(X_l+A_l-1,X_c+A_c-1);

for l=A_l:X_l+A_l-1
   for c=A_c:X_c+A_c-1
      Xpredit=-sum(sum(A.*Xmemoire(l-A_l+1:l,c-A_c+1:c)));
      delta=X(l-A_l+1,c-A_c+1)-Xpredit;
      erreurcode=q/2+q*floor(delta/q);
      if erreurcode > deltamax
         erreurcode=deltamax;
      end
      if erreurcode < -deltamax
         erreurcode=-deltamax;
      end
      deltaq(l-A_l+1,c-A_c+1)=erreurcode;
      Xmemoire(l,c)=erreurcode+Xpredit;
   end
end

A=rot90(A,2);
A(1,1)=1;
Xq=Xmemoire(A_l:X_l+A_l-1,A_c:X_c+A_c-1);

disp(['variance de l''erreur de prédiction : ' ...
      num2str(sum(sum(deltaq.^2))/(X_l*X_c))])