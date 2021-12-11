% codeimage.m

function codeimage (nom,dico,numiter)

RGB=imread(nom);
figure,image(RGB),title('image initiale')
axis equal
drawnow

LIG=size(RGB,1);
COL=size(RGB,2);
M=LIG*COL;
vecteurs=zeros(3,M);
vecteurs(1,:)=reshape(RGB(:,:,1),1,LIG*COL);
vecteurs(2,:)=reshape(RGB(:,:,2),1,LIG*COL);
vecteurs(3,:)=reshape(RGB(:,:,3),1,LIG*COL);

[vecteursliste,code,occur]=kmoyennes(vecteurs,dico,numiter);

RGBres=zeros(LIG,COL,3,'uint8');

for lig=1:LIG
    for col=1:COL
        index=lig+(col-1)*LIG;
        RGBres(lig,col,:)=round(vecteursliste(:,1+code(index)));
    end
end

figure,image(RGBres),title(['image code sur ' int2str(dico) ' niveaux'])
axis equal
drawnow
figure,plot(1:dico,occur),title('nombre d''occurrences'),grid on
figure,plot3(vecteursliste(1,:),vecteursliste(2,:),vecteursliste(3,:),'.')
axis([0 255 0 255 0 255])
xlabel('R'),ylabel('G'),zlabel('B'),grid on
title('espace des couleurs')

dos('del code');
dos('del dict');
dos('del vecteurs');



