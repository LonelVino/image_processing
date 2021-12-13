% fichier stab2d.m

function stab2d(A)

N=1000;
A_c=size(A,2);

polynome=zeros(A_c,1);

set(figure(1),...
   'MenuBar','none',...
   'NumberTitle','off',...
   'Name','test de stabilité des filtres récursifs 2D'...
   )

z_l=1;
for c=1:A_c
   polynome(c)=polyval(A(:,c),z_l);
end
roots_c=roots(polynome);
plot(real(roots_c),...
   imag(roots_c),'.');
axis([-1 1 -1 1])
axis('square')
hold on
plot(exp(2*pi*1i*(0:500)/500),'r')

for n=1:N
   z_l=exp(2*pi*1i*n/N);
   for c=1:A_c
      polynome(c)=polyval(A(:,c),z_l);
   end
   roots_c=roots(polynome);
   plot(real(roots_c),...
   imag(roots_c),'.');
   drawnow
end
