% PROGRAMA PARA LA TRIANGULACIÓN DE DELAUNAY

% Modificado para cargar una matriz de matlab en lugar de un jpg.
% Deberíamos poner ambos en común para poder usar cualquiera de los dos
% formatos. Por ahora guarda cosas en excel y cosas en ASCII. También
% habría que estandarizar eso.

% NOTAS: Es necesario modificar el campo, el tamaño del pixel, en nombre de
% la imagen, el mapa de colores y el contraste. Todo ello aquí arriba. En
% los pasos posteriores existen algunos números mágicos que hay que ir
% cambiando según la imagen, son los correspondientes a los contrastes de
% blanco, la extensión a considear un vórtice y alguno de la triangulación.

%% Cargar y pintar la imagen. 
% Hay que poner la ruta completa de la imagen si no está guarda en la misma
% carpeta que el script de matlab

ZeroBias = load('ZeroBiasMap.txt');
    ZeroBias = medfilt2(ZeroBias,[2,2]);
    [Columnas,Filas] = size(ZeroBias);
    LateralSize = 359;  % en nm
    PixelSize = LateralSize/Columnas; %nm
    
FileName = 'ZeroBiasVortex';
SaveFormat = '.txt';
Campo = 4.0; % en T

MapaColores = parula;
Contraste = [0,0.8];

figure
    pcolor(ZeroBias);
        shading flat;
        axis square;
        set(gca,'XTick',[]);
        set(gca,'YTick',[]);
        caxis(Contraste);
        colormap(MapaColores);

%% Aplico un filtro.

% ZeroBiasFiltrada = filter2(fspecial('average',[4,4]),ZeroBias);
ZeroBiasFiltrada = ZeroBias;
pcolor(ZeroBiasFiltrada);
        shading flat;
        axis square;
        set(gca,'XTick',[]);
        set(gca,'YTick',[]);
        caxis(Contraste);
        colormap(MapaColores);
%% Convertir la imagen en binaria eligiendo un threshold

BW = im2bw(ZeroBiasFiltrada, 0.4);%Parametro de negro
%BW =~BW;
    pcolor(BW);
        shading flat;
        axis square;
        set(gca,'XTick',[]);
        set(gca,'YTick',[]);
        caxis(Contraste);
        colormap(gray);

%% Tratar la imagen eliminando ruido. Borra areas por debajo de cierto tamaño

s = regionprops(bwlabel(BW,8), 'Area');
    areaMinima = 3;
    idx = find([s.Area] > areaMinima);
    BW2 = ismember(bwlabel(BW,8),idx);

pcolor(BW2);
        shading flat;
        axis square;
        set(gca,'XTick',[]);
        set(gca,'YTick',[]);
        caxis(Contraste);
        colormap(gray);


%% Buscar los centros y los almacena en la variable centroids

s2 = regionprops (bwlabel(BW2,8), 'Centroid');
    centroids = cat(1, s2.Centroid);
    figure
    pcolor(ZeroBias);
        shading flat;
        axis square;
        set(gca,'XTick',[]);
        set(gca,'YTick',[]);
        caxis(Contraste);
        colormap(MapaColores);
        
hold on
plot(centroids(:,1), centroids(:,2), 'yo','MarkerFaceColor', [1,1, 1], 'MarkerEdgeColor', 'k')
hold off




%% Corregir Centros con ginput
% xpuntero=0;
% ypuntero=0;
button = 1;
if exist(strcat([FileName,'Zoom', SaveFormat]),'file') > 0
    centroids = load(strcat([FileName,'Zoom'] , SaveFormat));

end
while button == 1
    [xpuntero, ypuntero, button]=ginput(1);
    xypuntero=[xpuntero, ypuntero];
    contador = 0;
    for a=1:length(centroids(:,1))
        contador = contador+1;
        
        if a==contador && a<=length(centroids(:,1)) && (centroids(a,1)-xpuntero)^2+(centroids(a,2)-ypuntero)^2<areaMinima 
            
            contador = contador-1;
            centroids(a,:)=[];
            pcolor(ZeroBias);
                shading flat;
                axis square;
                set(gca,'XTick',[]);
                set(gca,'YTick',[]);
                caxis(Contraste);
                colormap(MapaColores);
            hold on
                plot(centroids(:,1), centroids(:,2), 'ko','MarkerFaceColor', [1,1, 1])
            hold off
            
         elseif a==contador && contador==length(centroids(:,1)) && (centroids(a,1)-xpuntero)^2+(centroids(a,2)-ypuntero)^2>=areaMinima  
             
            centroids = [centroids; xypuntero];
            pcolor(ZeroBias);
                shading flat;
                axis square;
                set(gca,'XTick',[]);
                set(gca,'YTick',[]);
                caxis(Contraste);
                colormap(MapaColores);
            hold on
                plot(centroids(:,1), centroids(:,2), 'ko','MarkerFaceColor', [1,1, 1])
            hold off
    
        end
    end
end
centroids(length(centroids),:)=[];
dlmwrite([FileName, SaveFormat], centroids,'delimiter','\t','newline','pc')
%%
%%Comprobar
centroids = load([FileName, SaveFormat]);
pcolor(ZeroBias);
	shading flat;
	axis square;
	set(gca,'XTick',[]);
	set(gca,'YTick',[]);
    caxis(Contraste);
 	colormap(MapaColores);
hold on
plot(centroids(:,1), centroids(:,2),'yo','MarkerFaceColor', [1,1, 0])
for k = 1:length(centroids(:,1))
    text(centroids(k,1), centroids(k,2), num2str(k), 'VerticalAlignment','bottom', ...
        'HorizontalAlignment','right', 'EdgeColor','white');
end
hold off