function imagexyz(maxlum)
if nargin==0
    maxlum=1;
end
close all
N=1000;gamma=2.2;
imxyz=zeros(N,N,3);
x=(0:N-1)/(N-1);
y=(0:N-1)/(N-1);
RGBtoXYZ=...
     [ 0.4124 0.3576 0.1805;...
       0.2126 0.7152 0.0722;...
       0.0193 0.1192 0.9505];   
for lig=1:N
    for col=1:N
        XYZ=[x(col);y(lig);1-x(col)-y(lig)];
        RGB=RGBtoXYZ\XYZ;
        if all(RGB >= 0)
            XYZ=RGBtoXYZ*RGB;
            RGB=RGB*maxlum/XYZ(2);
            if any (RGB > 1)
                RGB=RGB/max(RGB);
            end
            imxyz(lig,col,:)=gammadir(RGB);
        end
    end
end
figure,image(x,y,imxyz)
axis xy
hold on
genediag
hold off
figure
C=(0:0.001:1);
gdir=zeros(length(C),1);
ginv=zeros(length(C),1);
for n=1:length(C)
    vec=gammadir([C(n);C(n);C(n)]);
    gdir(n)=vec(2);
    vec=gammainv([C(n);C(n);C(n)]);
    ginv(n)=vec(2);
end
plot(C,gdir,C,ginv,C,C.^(1/gamma),C,C.^gamma)
grid on

function Cs=gammadir(Cl)
Clim=0.0031308;
gain=12.92;expos=2.4;a=0.055;
Cs=zeros(3,1);
for n=1:3
    if Cl(n)<=Clim
        Cs(n)=gain*Cl(n);
    else
        Cs(n)=(1+a)*Cl(n)^(1/expos)-a;
    end
end

function Cl=gammainv(Cs)
Cslim=0.04045;
gain=12.92;expos=2.4;a=0.055;
Cl=zeros(3,1);
for n=1:3
    if Cs(n)<=Cslim
        Cl(n)=Cs(n)/gain;
    else
        Cl(n)=((Cs(n)+a)/(1+a))^expos;
    end
end


