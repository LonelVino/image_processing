% file echantil.m
% command :
% imaech=echantil(ima,deltax,deltay);
% sample the image with one step
% deltax at x (en m)
% deltay at y (en m)
% then visualize the result

function imaech=echantil(ima,deltax,deltay)
N=500;
if nargin == 0
   ima=genesin(50,30);
   deltax=0.01;
   deltay=0.01;
end

x=(0:N-1)/N;
y=(0:N-1)/N;
imaech=zeros(N);

%% Part1: Normal Sampling
gridx=round((0:deltax:1-1/N)*N+1);
gridy=round((0:deltay:1-1/N)*N+1);
imaech(gridx,gridy)=ima(gridx,gridy); % Sampling
IMAECH=fftshift(fft2(imaech));  % fft2(X) returns the two-dimensional Fourier transform of matrix X.
set(figure,...
'Name','TF sampling scale',...
'MenuBar','None')

x0=0; y0=0;width=800; height=800;
set(gca,'Xtick',[],'Ytick',[],'position',[x0,y0,width,height])

% fftshift():  shifting the zero-frequency component to the center
%     for example: swap the left and right halves of a vector
VISU=fftshift(fft2(imaech.*(blackman(N)*blackman(N)')));  % ' means transpose of matrix 
%  blackman(N) returns the N-point symmetric Blackman window in a column vector.
subplot(2,2,1)
imagesc(sqrt(abs(IMAECH)))  % display image with scaled color, here high value -> gray, low value -> black 
axis('square'), axis('xy'), title('Sampling with fftshift')
subplot(2,2,2)
imagesc(sqrt(abs(VISU)))  % display image with scaled color, here high value -> gray, low value -> black 
axis('square'), axis('xy'), title('Sampling with fftshift and blackman window')

colormap(gray(256))


%% Part2: Add Filter to sampling

filtrex=(deltax*N)*[...
         zeros(1,1+N/2-round(1/(2*deltax)))...
         ones(1,round(1/(2*deltax))-1)...
         ones(1,round(1/(2*deltax)))...
         zeros(1,N/2-round(1/(2*deltax)))];
filtrey=(deltay*N)*[...
         zeros(1,1+N/2-round(1/(2*deltay)))...
         ones(1,round(1/(2*deltay))-1)...
         ones(1,round(1/(2*deltay)))...
         zeros(1,N/2-round(1/(2*deltay)))];
IMAECH_FIL=IMAECH.*(filtrey'*filtrex);
VISU_FIL=VISU.*(filtrey'*filtrex);


subplot(2,2,3)
imagesc(sqrt(abs(VISU_FIL)))  % display image with scaled color, here high value -> gray, low value -> black 
axis('square'), axis('xy'), title('Filtered Sampling with fftshift and blackman window')

colormap(gray(256))
set(gca,'Xtick',[],'Ytick',[])



%% Part3: Rebuild Image
imaech_res=real(ifft2(fftshift(IMAECH_FIL)));
subplot(2,2,4)
image(x,y,imaech_res)
axis('square'), axis('xy'), title('Restored Image')

colormap(gray(256))
xlabel('x (en m)'), ylabel('y (en m)')
drawnow