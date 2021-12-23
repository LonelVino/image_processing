% images match using Cross Correlation
clear;clc;close all
%% Part 1  read an image and select two different sub-images with offsets da and db
Orig = imread('rice.png');
N = 200; range = 1:N;
da = [0 20]; db = [30 30]; % Displacement of 2 images respectively
A=Orig(da(1) + range, da(2) + range); 
B=Orig(db(1) + range, db(2) + range);

%% Part 2  Calculate cross-correlation and find maximum
X = normxcorr2(A, B);
m = max(X(:));
[i,j] = find(X == m);

%% Part 3 Patch them together using recovered shift
R = zeros(2*N, 2*N);
R(N + range, N + range) = B;
R(i + range, j + range) = A;
% COmprae intentional shift with recovered shift
delta_orig = da - db;   %--> [-30 -10]
delta_recovered = [i - N, j - N];  %--> [-30 -10]
disp([sprintf('Expected transformation: (X,Y) = (%d, %d) ', delta_orig(1), delta_orig(2))]);
disp([sprintf('Calculated displacement: (X,Y) = (%d, %d)', delta_recovered(1), delta_recovered(2))]);

%% Part 4 Illustrate
figure
subplot(2,2,1), imagesc(A)
subplot(2,2,2), imagesc(B)
subplot(2,2,3), imagesc(X)
rectangle('Position', [j-1 i-1 2 2]), line([N j], [N i])
subplot(2,2,4), imagesc(R);