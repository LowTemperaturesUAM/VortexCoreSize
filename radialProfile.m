%This function calculates  the radial profile of a matrix being able to
%decide the origin and the size of the profile.

%Inputs:
        %TamanhoReal  : Array of the real size of image [XSize, YSize]
        %Center       : Array of the origin of the radial profile [X0,Y0]
        %Matrix       : Matrix to calculate profile
        %NOfPoints    : Length of the radial profile wanted
        %MaximumRadius: Maximum radius to calculate the profile (Real units).
                        

function [ValoresValidos, RadialProfile] = radialProfile(TamanhoReal, Center,  Matrix, NOfPoints, MaximumRadius)
    TamanhoImagen = length(Matrix);
%     SizeOfRings = TamanhoImagen/NOfPoints;
    TamanhoRealX = TamanhoReal(1);
    TamanhoRealY = TamanhoReal(2);
    X            = Center(1);
    Y            = Center(2);
    NewX = X- TamanhoRealX/2;
    NewY = Y- TamanhoRealY/2;
    %Creation of a cartesian matrix of X and Y centered in "center"
    CordX = linspace(-TamanhoRealX/2- NewX, TamanhoRealX/2 - NewX, TamanhoImagen);
    CordY = linspace(-TamanhoRealY/2 -NewY, TamanhoRealY/2 - NewY, TamanhoImagen);
    CordX = meshgrid(CordX,CordX) ;
    CordY = meshgrid(CordY,CordY) ;
    CordY = CordY';

    %Change to polar coordinates, only module matrix is needed.
    CordMod = sqrt(CordX.^2 + CordY.^2);
  
    %Array that controls the points to do the profile.
    ValoresValidos = linspace(0,MaximumRadius,NOfPoints)'; % (TamanhoImagen/2)/SizeOfRings
    
    %Allocate the RadialProfile array.
    RadialProfile = zeros(length(ValoresValidos) -1,1);

    
    for i =1:length(ValoresValidos) -1
        %Make a logical array of the valid points inside each
        %circunference.
        RadioValido  = CordMod >ValoresValidos(i) & CordMod <ValoresValidos(i +1);
      
        %LogicalMatrix with ones in the valid circunference.
        ValidMatrix     = (Matrix).*RadioValido;
        %Mean value of the nonZero elemens of the ValidMatrix, i.e, the
        %points that are inside of the valid circunference
        RadialProfile(i) = mean(mean(ValidMatrix(ValidMatrix~=0)));
        
        %If integral is needed it is necesary the size of the real image
        % Area              = sum(sum(RadioValido))*(tamanhoRealnm/TamanhoImagen)^2;
        % IntegralRadial(i) = (sum(sum(fftLogicMatrix.*RadioValido)))/Area;

    end
    ValoresValidos = ValoresValidos(1:end-1);
