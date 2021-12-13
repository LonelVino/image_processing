clc; clear;

I=1; h=1; Omega=4*pi; % I: intensity (cd), h: distance (m), Omega: solid angle (steradian)
P = I*Omega;  % the luminous flux or radial power, unit: lm

% restore a gray level image, initialize a table
N=400; 
ima1=zeros(N,N);  ima2=zeros(N,N);
ima1=rand(N,N); % exemple particulier 
figure, imshow(ima1), title('Random Noise Image');

pos_x = zeros(N); pos_y = zeros(N);   % the position in the real world
for i = 1:N
    pos_x(i) = i/N - 1/2;
    pos_y(i) = i/N - 1/2;
end

for i = 1:N
    for j = 1:N
        pos = [pos_x(i), pos_y(j), 1];
        d = euclidean(pos);
        ima2(i,j) = P / (4*pi*d^2);
    end
end

figure, imshow(ima2), title('Plan: Source 1 meter away');

% calculate the euclidean distance from point(m,n,1) to point (0,0,0)
function dist = euclidean(pos)
    dist = sqrt(sum((abs(pos) - [0,0,0]).^2, 2));
end
