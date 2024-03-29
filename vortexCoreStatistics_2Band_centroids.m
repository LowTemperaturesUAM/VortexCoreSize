% Description:
% ------------------------------------------------------------------------
%   This script calculates from a conductance map in an ASCII matrix the
%   radial average of the different vortices and use them to calculate the
%   vortex core size following Kogan's model, as described in reference 
%   [A. Fente et al., Phys. Rev. B 94, 014517 (2016)].
%   It retuns the normalized data for each vortex and the average value of
%   all of them.
%
%   As an extra, instead of using ginput() to get the vortex center, it can
%   be given to the program as a two column vector.
%
% ------------------------------------------------------------------------
%
% Custom options
% ------------------------------------------------------------------------
    TamanhoLinea = 2;
    TamanhoPuntos = 10;
    TipoFuente = 'Arial';
    TamanhoFuenteTitulo = 14;
    TamanhoFuenteEjes = 12;
% ------------------------------------------------------------------------
%
% Input data:
% ------------------------------------------------------------------------
    FileName        = 'ZeroBiasMap.txt';    % File with the ASCII matrix
    FileCentros     = 'ZeroBiasVortex.txt'; % Vortex location norm. units
    LateralSize     = 359;                  % Size of the image in nm      
    NOfPoints       = 20;                   % Number of points in the profile
    AppliedField    = 0.1;                  % Applied magnetic field in T
    BandRatio       = 4.6;                  % Weight of each band
% ------------------------------------------------------------------------
%
% Calculated data:
% ------------------------------------------------------------------------ 
	Matrix = load(FileName);
        [Columnas,Filas] = size(Matrix);
        PixelSize = LateralSize/Columnas;
        
	Center = load(FileCentros);
        Center = Center*PixelSize;
        NVortices = length(Center(:,1));
        
    MaximumRadius = 0.5*1.05*49.89/sqrt(AppliedField); % Maximum radius around the core center in nm
% ------------------------------------------------------------------------ 

    if Columnas ~= Filas
        display('Image is not square, problems might arrise');
    else
        display('Square image');
    end
    
Ajuste = zeros(8,NVortices);
clear DatosNormalizados Fit;


Fig1 = figure(257);
    Fig1.Color = [1 1 1];
    Fig1.Position = [680   220   1000   760];
    Fig1_Ejes = axes('Parent',Fig1);
    hold(Fig1_Ejes,'on');
    
    Fig1_Ejes_h1 = imagesc(linspace(0,LateralSize,Columnas),linspace(0,LateralSize,Columnas),Matrix);
        Fig1_Ejes.YDir = 'normal';
        Fig1_Ejes_h1.Parent = Fig1_Ejes;
    Fig1_Ejes_h2 = plot(Center(:,1),Center(:,2),'wo');
    
    Fig1_Ejes.CLim = [0 1];
    Fig1_Ejes.XLim = [0 LateralSize];
    Fig1_Ejes.YLim = [0 LateralSize];
    
    axis square;

for Counter = 1:1:NVortices  
    
    display(num2str(Counter));
    figure(Fig1);
    
%     Center(Counter,:) = round(ginput(1));     

    [X,Y] = radialProfile([LateralSize,LateralSize], Center(Counter,:),  Matrix, NOfPoints, MaximumRadius);

    [Ajuste(:,Counter),DatosNormalizados(:,2*Counter-1:2*Counter),DatosFit(:,2*Counter-1:2*Counter)] = vortexCoreFit_2Bands(X,Y,AppliedField,BandRatio);

end

%% REPRESENTACION

Fig2 = figure(258);
    Fig2.Color = [1 1 1];
%     Fig2.Position = [150 230 1200 630];
    Fig2.Position = [33    49   807   948];
for Counter = 1:1:NVortices  
    
	figure(Fig2);
        Sub = subplot(round(sqrt(NVortices)),ceil(NVortices/round(sqrt(NVortices))),Counter);
        Sub.Parent = Fig2;
        hold(Sub,'on');
        
        Sub_h1 = plot(DatosNormalizados(:,2*Counter-1),DatosNormalizados(:,2*Counter),'o');
            Sub_h1.MarkerFaceColor = [30/255 144/255 1];
            Sub_h1_MarkerEdgeColor = 'k';
            Sub_h1_MarkerSize = TamanhoPuntos;
            Sub_h1.Parent = Sub;
 
        Sub_h2 = plot(DatosFit(:,2*Counter-1),DatosFit(:,2*Counter),'-');
            Sub_h2.Color = [1 69/255 0];
            Sub_h2.LineWidth = TamanhoLinea;
            Sub_h2.Parent = Sub;
            
        text(0.9,0.9,['C_1 = ',num2str(round(Ajuste(4,Counter),3,'Significant')),' nm'],...
                    'Units','normalized',...
                    'FontSize', TamanhoFuenteTitulo,...
                    'FontName', TipoFuente,...
                    'HorizontalAlignment','right');
                
        text(0.9,0.75,['C_2 = ',num2str(round(Ajuste(5,Counter),3,'Significant')),' nm'],...
                    'Units','normalized',...
                    'FontSize', TamanhoFuenteTitulo,...
                    'FontName', TipoFuente,...
                    'HorizontalAlignment','right');
            
        Sub.XLim = [0 1];
            Sub.YLim = [0 1];  
        Sub.FontName = TipoFuente;
        Sub.FontSize = TamanhoFuenteEjes;
        Sub.Box = 'on';    
        hold(Sub,'off');
    
end

Fig3 = figure(259);
    Fig3.Color = [1 1 1];
    Fig3.Position = [1335          92         560         420];

    Fig3_Ejes = axes('Parent',Fig3,'Box','on');
        hold(Fig3_Ejes,'on');
        Fig3_Ejes_h1 = plot((1:1:NVortices),Ajuste(4,:),'o');
            Fig3_Ejes_h1.MarkerSize = TamanhoPuntos;
            Fig3_Ejes_h1.MarkerEdgeColor = [0 0 0];
            Fig3_Ejes_h1.MarkerFaceColor = [0.9856 0.7372 0.2537];
            
        Fig3_Ejes_h2 = plot([0, NVortices+1],[mean(Ajuste(4,:)) mean(Ajuste(4,:))],'--');
            Fig3_Ejes_h2.Color = [0.9856 0.7372 0.2537];
            Fig3_Ejes_h2.LineWidth = TamanhoLinea;
            
        Fig3_Ejes_h3 = plot((1:1:NVortices),Ajuste(5,:),'o');
            Fig3_Ejes_h3.MarkerSize = TamanhoPuntos;
            Fig3_Ejes_h3.MarkerEdgeColor = [0 0 0];
            Fig3_Ejes_h3.MarkerFaceColor = [30/255 144/255 1];
            
        Fig3_Ejes_h4 = plot([0, NVortices+1],[mean(Ajuste(5,:)) mean(Ajuste(5,:))],'--');
            Fig3_Ejes_h4.Color = [30/255 144/255 1];
            Fig3_Ejes_h4.LineWidth = TamanhoLinea;
            
        text(0.9,0.9,['C_1 = ',num2str(round(mean(Ajuste(4,:)),3,'Significant')),' nm'],...
                    'Units','normalized',...
                    'FontSize', TamanhoFuenteTitulo,...
                    'FontName', TipoFuente,...
                    'HorizontalAlignment','right');
                
        text(0.9,0.8,['C_2 = ',num2str(round(mean(Ajuste(5,:)),3,'Significant')),' nm'],...
                    'Units','normalized',...
                    'FontSize', TamanhoFuenteTitulo,...
                    'FontName', TipoFuente,...
                    'HorizontalAlignment','right');
            
        title(Fig3_Ejes,'Result from fits',...
            'FontName',TipoFuente,...
            'FontSize',TamanhoFuenteTitulo);

        xlabel(Fig3_Ejes,'Vortex',...
            'FontName',TipoFuente,...
            'FontSize',TamanhoFuenteTitulo);
        
        ylabel(Fig3_Ejes,'Core size (nm)',...
            'FontName',TipoFuente,...
            'FontSize',TamanhoFuenteTitulo);
        
        Fig3_Ejes.FontName = TipoFuente;
        Fig3_Ejes.FontSize = TamanhoFuenteEjes;
        Fig3_Ejes.XLim = [0, NVortices+1];
        Fig3_Ejes.YLim = [0, 2*max(mean(Ajuste(4,:)),mean(Ajuste(5,:)))];
        hold(Fig3_Ejes,'off');
        
        
 %% Check and numbering
% ------------------------------------------------------------------------
    figure(257);
    hold(Fig1_Ejes,'on');
    Fig1_Ejes_h3 = plot(Center(:,1), Center(:,2),'o',...
        'MarkerFaceColor', [1,1,1], 'MarkerEdgeColor','k');
        Fig1_Ejes_h3.Parent = Fig1_Ejes;

    for k = 1:length(Center(:,1))
        Ejes1_T1 = text(Center(k,1)-3*(LateralSize/100), Center(k,2)-3*(LateralSize/100), num2str(k),...
            'VerticalAlignment','bottom', ...
            'HorizontalAlignment','right',...
            'FontName',TipoFuente,'FontSize',TamanhoFuenteTitulo,...
            'Color','w','FontWeight','bold');
            Fig1_Ejes_T1.Parent = Fig1_Ejes;
    end
    
    hold(Fig1_Ejes,'off');
%     export_fig(Fig1,'VortexLabel','-opengl', '-transparent', '-png');
% ------------------------------------------------------------------------
    