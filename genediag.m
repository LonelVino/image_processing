function genediag
[~,xb,yb,zb]=genemel;
plot([0 1 0 0],[0 0 1 0])
xlabel('x')
ylabel('y')
hold on
plot(xb./(xb+yb+zb),...
     yb./(xb+yb+zb),'r')
  plot([xb(1)/(xb(1)+yb(1)+zb(1)), ...
        xb(end)/(xb(end)+yb(end)+zb(end))],...
       [yb(1)/(xb(1)+yb(1)+zb(1)),...
        yb(end)/(xb(end)+yb(end)+zb(end))],'r');
hold off
axis('square')
axis([0 1 0 1])
title('Diagramme de chromaticité')