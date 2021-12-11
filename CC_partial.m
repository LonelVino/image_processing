% Cross-Correlation Example
%% Load Image
load durer
img = X;
White = max(max(img));

imagesc(img)
axis image off
colormap gray
title('Original')

%% Extract a section of the whole image
x = 435;
X = 535;
szx = x:X;

y = 62;
Y = 182;
szy = y:Y;

Sect = img(szx,szy);

kimg = img;
kimg(szx,szy) = White;

kumg = White*ones(size(img));
kumg(szx,szy) = Sect;

subplot(1,2,1)
imagesc(kimg)
axis image off
colormap gray
title('Image')

subplot(1,2,2)
imagesc(kumg)
axis image off
colormap gray
title('Section')


%% Calculate the Cross Correlation
nimg = img-mean(mean(img));
nSec = nimg(szx,szy);

crr = xcorr2(nimg,nSec);

%% Analyze the cross-correlation to estimate the localtion of section image
[ssr,snd] = max(crr(:));
[ij,ji] = ind2sub(size(crr),snd);

figure
plot(crr(:))
title('Cross-Correlation')
hold on
plot(snd,ssr,'or')
text(snd*1.05,ssr,'Maximum')

%% Place the smaller image insider the larger image
img(ij:-1:ij-size(Sect,1)+1,ji:-1:ji-size(Sect,2)+1) = rot90(Sect,2);

figure
imagesc(img)
axis image off
colormap gray
title('Reconstructed')
hold on
plot([y y Y Y y],[x X X x x],'r')
hold off