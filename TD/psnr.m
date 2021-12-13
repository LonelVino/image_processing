function val=psnr(I1,I2)
val=10*log10((255^2)/(sum(sum((I1-I2).^2))/numel(I1)));