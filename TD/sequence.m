% fichier sequence.m
% Command : 
% sequence (K, a, LIS)
% exemple  :  sequence (100, 0.99, 8)
% K  :  l'image a une dimension (2*K) x (2*K)
% a  :  coefficient du filtre d'estimation de la
% trajectoire (1/(1 - az^( - 1))
% LIS  :  we filter the trajectory with an averaging device
% sur LIS �chantillons.

function sequence (K, a, LIS)
if nargin == 0
    K = 100; a = 0.99; LIS = 8;
end
close all

%% Part 1 Parameters definition,  Load images
M = 300; %
dtheta = 2*pi/M;
sigma = 4; ampl = 2;

[temp, map] = imread('140.context.bmp');  % converts the indexed image X to a grayscale image,  
I = ind2gray(temp, map);
clear temp map
if isa(I, 'double')  % Determine if the input is object of specified class
    I = uint8(255*I);  % multiply by 255(pixel),  and then convert it into unit8
end

%% Move the image according to a random trajectory
ima = flipud(I);  % Flip array up to down
clear I
[L, C] = size(ima);
dv = sigma*randn(M, 2) + ampl*[cos((0 : M - 1)'*dtheta) sin((0 : M - 1)'*dtheta)];
v = cumsum(dv);
v( :, 1) = v( :, 1) - mean(v( :, 1));
v( :, 2) = v( :, 2) - mean(v( :, 2));
v( :, 1) = round(v( :, 1) + L/2);
v( :, 2) = round(v( :, 2) + C/2);

set(figure, 'Units', 'normal', 'Position', [0 0.5 0.5 0.5]);
plot(v( :, 2), v( :, 1))
grid on,  axis('equal')
drawnow

seq = zeros(2*K);
set(figure, 'Units', 'normal', 'Position', [0.5 0.5 0.5 0.5]);
h = image(seq);
% set(h, 'EraseMode', 'none');
axis xy; colormap(gray(256));
for n = 1 : M
   seq = ima(v(n, 1)-K : v(n, 1)+K-1, v(n, 2)-K : v(n, 2)+K-1);
   set(h, 'CData', seq);
   drawnow
   pause(0.05)
end

%% Part 3. Add filter
vest = filter(1, [1-a], dv);
lis = hanning(LIS)/sum(hanning(LIS)); % filter window,  hanning(N) returns the N - point symmetric Hanning window in a column
vcomp = round(filter(lis, 1, vest) - vest);

% Visualize
set(figure, 'Units', 'normal', 'Position', [0 0 0.5 0.5]);
plot(v( :, 2) + vcomp( :, 2), v( :, 1) + vcomp( :, 1))
grid on; axis('equal')
drawnow

set(figure, 'Units', 'normal', 'Position', [0.5 0 0.5 0.5]);
h = image(seq);
% set(h, 'EraseMode', 'none');
axis xy; colormap(gray(256));
for n = 1 : M
   seq = ima(v(n, 1)-K : v(n, 1)+K-1, v(n, 2)-K : v(n, 2)+K-1);
   seqcomp = zeros(2*K);
   if((vcomp(n, 1) >= 0)&&(vcomp(n, 2) >= 0))
      seqcomp(1 : end - vcomp(n, 1), 1 : end - vcomp(n, 2)) = ...
         seq(vcomp(n, 1) + 1 : end, vcomp(n, 2) + 1 : end);
   elseif((vcomp(n, 1) >= 0)&&(vcomp(n, 2) < 0))
      seqcomp(1 : end - vcomp(n, 1), 1 - vcomp(n, 2) : end) = ...
         seq(vcomp(n, 1) + 1 : end, 1 : end + vcomp(n, 2));
   elseif((vcomp(n, 1) < 0)&&(vcomp(n, 2) >= 0))
      seqcomp(1 - vcomp(n, 1) : end, 1 : end - vcomp(n, 2)) = ...
         seq(1 : end + vcomp(n, 1), vcomp(n, 2) + 1 : end);
   elseif((vcomp(n, 1) < 0)&&(vcomp(n, 2) < 0))
      seqcomp(1 - vcomp(n, 1) : end, 1 - vcomp(n, 2) : end) = ...
         seq(1 : end + vcomp(n, 1), 1 : end + vcomp(n, 2));
   end
   set(h, 'CData', seqcomp);
   drawnow
   pause(0.05)
end