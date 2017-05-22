% DESCRIPTION:
% ------------------------------------------------------------------------
% This script finds the position of the vortex centers in an image based on
% a black and white contrast and the centroid function. Uses as imput an
% ASCII matrix but can be easily changed to use jpg or other image file.
% The output is a text ASCII file with the vortex center position.
% ------------------------------------------------------------------------
%
% Loading image
% ------------------------------------------------------------------------

    ZeroBias = load('ZeroBiasMap.txt');
        [Columnas,Filas] = size(ZeroBias);
        LateralSize = 359;                  % nm
        PixelSize = LateralSize/Columnas;   % nm

    FileName = 'ZeroBiasVortex';
    SaveFormat = '.txt';
    Campo = 4.0; % en T

    MapaColores = parula;
    Contraste = [0 0.8];

    Fig1 = figure(495);
        Fig1.Color = [1 1 1];
        Fig1.Position = [240   360   560   420];
            Ejes1 = axes('Parent',Fig1);
            Ejes1_h1 = imagesc(ZeroBias);
                Ejes1.YDir = 'normal';
                axis square;
            Ejes1.XLim = [1 Columnas];
            Ejes1.YLim = [1 Filas];
            Ejes1.XTick = [];
            Ejes1.YTick = [];
            Ejes1.CLim = Contraste;
            Ejes1.Visible = 'off';
            colormap(MapaColores);

%% Filter to smooth the image
% ------------------------------------------------------------------------
    ZeroBiasFiltrada = filter2(fspecial('average',[4,4]),ZeroBias);
	Ejes1_h1.CData = ZeroBiasFiltrada;
% ------------------------------------------------------------------------

%% Turn the image to binary with threashold
% ------------------------------------------------------------------------
    BW = im2bw(ZeroBiasFiltrada, 0.4);%Parametro de negro
	Ejes1_h1.CData = BW;
        colormap(gray);
% ------------------------------------------------------------------------

%% Reduce noise removing areas below certain size
% ------------------------------------------------------------------------
    S = regionprops(bwlabel(BW,8), 'Area');
        AreaMinima = 3;
        idx = find([S.Area] > AreaMinima);
        BW2 = ismember(bwlabel(BW,8),idx);

        Ejes1_h1.CData = BW2;
% ------------------------------------------------------------------------

%% Locate centers and store them in centroids
% ------------------------------------------------------------------------

    S2 = regionprops (bwlabel(BW2,8), 'Centroid');
        centroids = cat(1, S2.Centroid);

        Fig2 = figure(496);
            Fig2.Color = [1 1 1];
            Fig2.Position = [240   360   560   420];
                Ejes2 = axes('Parent',Fig2);
                hold(Ejes2,'on');

                Ejes2_h1 = imagesc(ZeroBias);
                    Ejes2.YDir = 'normal';
                    axis square;
                Ejes2_h2 = plot(centroids(:,1), centroids(:,2),...
                    'wo','MarkerFaceColor', [1,1,1], 'MarkerEdgeColor', 'k');

                hold(Ejes2,'off');
                Ejes2.XTick = [];
                Ejes2.YTick = [];
                Ejes2.CLim = Contraste;
                Ejes2.XLim = [1 Columnas];
                Ejes2.YLim = [1 Filas];
                Ejes2.Visible = 'off';
                colormap(MapaColores);
% ------------------------------------------------------------------------

%% Correct centers with ginput()
% ------------------------------------------------------------------------

    button = 1;

    if exist([FileName, SaveFormat],'file') > 0
        centroids = load([FileName, SaveFormat]);
    end

    while button == 1
        [xpuntero, ypuntero, button] = ginput(1);
        xypuntero = [xpuntero, ypuntero];
        contador = 0;

        for a = 1:length(centroids(:,1))
            contador = contador+1;

            if a==contador && a<=length(centroids(:,1)) && (centroids(a,1)-xpuntero)^2+(centroids(a,2)-ypuntero)^2<AreaMinima 

                contador = contador-1;
                centroids(a,:)=[];

                Ejes2_h1.CData = ZeroBias;
                hold(Ejes2,'on');
                delete(Ejes2_h2);
                Ejes2_h2 = plot(centroids(:,1), centroids(:,2), 'ko','MarkerFaceColor', [1 1 1]);
                hold(Ejes2,'off');

             elseif a==contador && contador==length(centroids(:,1)) && (centroids(a,1)-xpuntero)^2+(centroids(a,2)-ypuntero)^2>=AreaMinima  

                centroids = [centroids; xypuntero];

                Ejes2_h1.CData = ZeroBias;
                hold(Ejes2,'on');
                delete(Ejes2_h2);
                Ejes2_h2 = plot(centroids(:,1), centroids(:,2), 'ko','MarkerFaceColor', [1 1 1]);
                hold(Ejes2,'off');

            end
        end
    end
    centroids(length(centroids),:)=[];
 
% Saving data in file
% ------------------------------------------------------------------------
    dlmwrite([FileName, SaveFormat], centroids,'delimiter','\t','newline','pc');
% ------------------------------------------------------------------------

%% Check and numbering
% ------------------------------------------------------------------------
    centroids = load([FileName, SaveFormat]);

    hold(Ejes2,'on');
    delete(Ejes2_h2);
    Ejes2_h2 = plot(centroids(:,1), centroids(:,2),'o',...
        'MarkerFaceColor', [1,1,1], 'MarkerEdgeColor','k');

    for k = 1:length(centroids(:,1))
        text(centroids(k,1)-3*(Columnas/100), centroids(k,2)-3*(Filas/100), num2str(k),...
            'VerticalAlignment','bottom', ...
            'HorizontalAlignment','right',...
            'FontName','Arial','FontSize',16,...
            'Color','w','FontWeight','bold');
    end
    
    hold(Ejes2,'off');
% ------------------------------------------------------------------------