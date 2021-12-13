% fichier genesin.m
% ligne de commande :
% ima=genesin(freq,angle);
% we generate an image with a sinusoidal pattern
% with frequence freq (inverse o distance (meter)) and an angle (en degr�s)

function ima=genesin(freq,angle)
N=500;

u0=freq*cos(angle*pi/180.0);
v0=freq*sin(angle*pi/180.0);
x=(0:N-1)/N;
y=(0:N-1)/N;
[X,Y]=meshgrid(x,y);
ima=round(128.5+127.5*cos(2*pi*(u0*X+v0*Y)));
ima=ima+randn(size(ima));
set(figure,...
'Name','Grandeur physique',...
'MenuBar','None')
image(x,y,ima)
colormap(gray(256))
axis('square')
axis('xy')
xlabel('x (en m)')
ylabel('y (en m)')
if u0~=0 && v0~=0
   title(['1/u0=' num2str(1/u0) ' m   1/v0=' num2str(1/v0) ' m'])
elseif u0==0 && v0~=0
   title(['1/u0= infini    1/v0=' num2str(1/v0) ' m'])
elseif u0~=0 && v0==0
   title(['1/u0=' num2str(1/u0) ' m   1/v0= infini'])
else
   title('1/u0= infini   1/v0= infini')
end

