% This function uses Kogan's model for the size of the vortex core for one
% band [A. Fente et al., Phys. Rev. B 94, 014517 (2016)] to calculate the
% size of the vortex core.
%
% INPUT:
% -----------------------------------------------------------------------
% Profile: Two colum vector containing the average profile of the vortex
%   core starting from the vortex center.
%
% Campo: Applied field for the measurement.
% -----------------------------------------------------------------------
% OUTPUT
% -----------------------------------------------------------------------
% Ajuste: column vector containing the parameters obtained from the fit:
%       Ajuste = [Applied field
%                 Conductance between vortices
%                 Conductance at the vortex core center
%                 Vortex core size in nm
%                 Wigner-Seitz appoximation radius
%                 Position of the vortex center];
%
% DatosNormalizados: two column vector containing the profile in normalized
%   units using the fit values
% 
% DatosFit: two column vector containing the normalized fit to the input
%   data


function [Ajuste,DatosNormalizados,DatosFit] = vortexCoreFit_1Band(Profile,Campo)

    XData = Profile(:,1);
    YData = Profile(:,2);
    b = 48.889/sqrt(Campo);
    Ajuste = zeros(6,1);
        Ajuste(1) = Campo;
            
% Parameters
% ----------------
%	sigmaBV = 0; 
% 	sigma0 = 1;
	a = 1.05*(b/2);
%	r0 = 0;
% ----------------
            
	myfittype = fittype(@(sigmaBV,sigma0,r0,eta,x) sigmaBV + (sigma0-sigmaBV)*(1 - (((((x/a)-r0)./sqrt(((x/a)-r0).^2 + eta^2)).*exp((-((x/a)-r0).^2*eta^2)./(2*(eta^2+1))))./((1/sqrt(1 + eta^2))*exp((-1^2*eta^2)/(2*(eta^2+1))))).^2));
	myfit = fit(XData,YData,myfittype,...
        'StartPoint',   [0,     1,   0,      0.06   ],...
        'Lower',        [0,     0 ,  -0.01   0      ],...
        'Upper',        [0.5,   1.5, 0.01,   1      ]);
  
	Ajuste(2) = myfit.sigmaBV;
	Ajuste(3) = myfit.sigma0;
	Ajuste(4) = myfit.eta*a;
	Ajuste(5) = a;
	Ajuste(6) = myfit.r0;
                     
    Fit(:) = 1 - (((RhoFit./sqrt(RhoFit.^2 + myfit.eta^2)).*exp((-RhoFit.^2*myfit.eta^2)./(2*(myfit.eta^2+1))))./((1/sqrt(1 + myfit.eta^2))*exp((-1^2*myfit.eta^2)/(2*(myfit.eta^2+1))))).^2;
      
	DistanciaNormalizada = (XData/Ajuste(5))-Ajuste(6);
	ConductanciaNormalizada = (YData - Ajuste(2))/(Ajuste(3) - Ajuste(2)); 
            
	DatosNormalizados = [DistanciaNormalizada, ConductanciaNormalizada];
	DatosFit = [RhoFit, Fit(:)];
                
	clear myfit myfittype;