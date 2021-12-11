clear; clc;

M=1000; 
N=1500; 
ima=zeros(M,N,3); 

for n = 1:N
    for m = 1:M
       R = n/N; V=m/N;B=1-R-V;
       if B >=0
           ima(m,n,1)=R;ima(m,n,2)=V;ima(m,n,3)=B;
       end
    end
end

imshow(ima)