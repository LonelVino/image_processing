% testraw.m

function testraw(rate,bits,pasquantif)
if nargin==0
    rate=1;
    bits=16;
    pasquantif=1/(2^24);
end
close all

if bits==16
    precision=16;
elseif bits==32
    precision=31;
end

disp(['débit=' num2str(rate) ' bits/pixel'])
disp(['précision=' num2str(precision) ' bits'])
disp(['pas de quantificaction=' num2str(pasquantif)])

for n=0:9
    eval(['im=imread(''im' int2str(n) '.bmp'');']);
    im=(2^(precision-1))+(2^(precision-2))*double(im);
    im=swapoctets(transpose(im),bits);    
    eval(['fid=fopen(''im' int2str(n) '.raw'',''w'');']);
    fwrite(fid,im,['uint' int2str(bits)]);
    fclose(fid);
end

ligcom=['kdu_compress.exe -quiet -record compress.txt -i '];
for n=0:8
    ligcom=[ligcom 'im' int2str(n) '.raw,'];
end
ligcom=[ligcom 'im' int2str(9) '.raw '];
ligcom=[ligcom '-o sortie.j2c Sprecision=' int2str(precision) ...
        ' Ssigned=no Sdims={128,128} -rate ' num2str(rate) ...
        ' -no_weights Qstep=' num2str(pasquantif)];

dos(ligcom);

ligcom=['kdu_expand.exe -quiet -i sortie.j2c -o '];
for n=0:8
    ligcom=[ligcom 'test' int2str(n) '.raw,'];
end
ligcom=[ligcom 'test' int2str(9) '.raw '];

dos(ligcom);

for n=0:9
    eval(['fid=fopen(''test' int2str(n) '.raw'',''r'');']);
    im=fread(fid,[128 128],['uint' int2str(bits)]);
    fclose(fid);
    im=swapoctets(transpose(im),bits);    
    eval(['fid=fopen(''im' int2str(n) '.raw'',''r'');']);
    im_ent=fread(fid,[128 128],['uint' int2str(bits)]);
    fclose(fid);
    im_ent=swapoctets(transpose(im_ent),bits);
    figure
    subplot(2,2,1)
    imshow(im_ent,[0 2^precision]);
    subplot(2,2,2)
    imshow(im,[0 2^precision]);
    subplot(2,2,3)
    imagesc((im-im_ent)/2^precision);
    colorbar
    disp(max(max(abs(im-im_ent)))/(2^precision))
end
