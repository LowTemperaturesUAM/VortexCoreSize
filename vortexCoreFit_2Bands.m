% This function uses Kogan's model for the size of the vortex core for two
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
%                 Conductance between vortices (sigmaBV)
%                 Conductance at the vortex core center (sigma0)
%                 Vortex core size in nm for the first band (eta1)
%                 Vortex core size in nm for the second band (eta2)
%                 Ratio between bands (gamma)
%                 Wigner-Seitz appoximation radius (a)
%                 Position of the vortex center (r0)];
%
% DatosNormalizados: two column vector containing the profile in normalized
%   units using the fit values
% 
% DatosFit: two column vector containing the normalized fit to the input
%   data

function [Ajuste,DatosNormalizados,DatosFit] = vortexCoreFit_2Bands(XData,YData,Campo,Gamma)

    b = 48.889/sqrt(Campo);
    Ajuste = zeros(8,1);
        Ajuste(1) = Campo;
            
% Parameters
% ----------------
%	sigmaBV = 0; 
% 	sigma0 = 1;
	a = 1.05*(b/2);
%	r0 = 0;
%   Gamma;
% ----------------
            
	myfittype = fittype(@(sigmaBV,sigma0,r0,eta1,eta2,x) sigmaBV + (sigma0-sigmaBV).*(1-((((((x/a)-r0)./sqrt(((x/a)-r0).^2 + eta1.^2)).*exp((-((x/a)-r0).^2*eta1.^2)./(2*(eta1.^2+1)))).^2+Gamma*((((x/a)-r0)./sqrt(((x/a)-r0).^2 + eta2.^2)).*exp((-((x/a)-r0).^2*eta2.^2)/(2*(eta2.^2+1)))).^2)/(((1/sqrt(1 + eta1^2))*exp((-1^2*eta1^2)/(2*(eta1^2+1))))^2 + Gamma*((1/sqrt(1 + eta2^2))*exp((-1^2*eta2^2)/(2*(eta2^2+1))))^2))));
	myfit = fit(XData,YData,myfittype,...
        'StartPoint',   [0,     1,   0,      0.06,   0.06   ],...
        'Lower',        [0,     0 ,  -0.01   0,      0      ],...
        'Upper',        [0.5,   1.5, 0.01,   1,      1      ]);
  
	Ajuste(2) = myfit.sigmaBV;
	Ajuste(3) = myfit.sigma0;
	Ajuste(4) = myfit.eta1*a;
	Ajuste(5) = myfit.eta2*a;
	Ajuste(6) = Gamma;
	Ajuste(7) = a;
	Ajuste(8) = myfit.r0;
                     
    Fit(:) = (1-((((RhoFit./sqrt(RhoFit.^2 + myfit.eta1.^2)).*exp((-RhoFit.^2*myfit.eta1.^2)./(2*(myfit.eta1.^2+1)))).^2+...
        Ajuste(6)*((RhoFit./sqrt(RhoFit.^2 + myfit.eta2.^2)).*exp((-RhoFit.^2*myfit.eta2.^2)/(2*(myfit.eta2.^2+1)))).^2)/...
        (((1/sqrt(1 + myfit.eta1^2))*exp((-1^2*myfit.eta1^2)/(2*(myfit.eta1^2+1))))^2 + ...
        Ajuste(6)*((1/sqrt(1 + myfit.eta2^2))*exp((-1^2*myfit.eta2^2)/(2*(myfit.eta2^2+1))))^2)));
                
            
	DistanciaNormalizada = (XData/Ajuste(7))-Ajuste(8);
	ConductanciaNormalizada = (YData - Ajuste(2))/(Ajuste(3) - Ajuste(2)); 
            
	DatosNormalizados = [DistanciaNormalizada, ConductanciaNormalizada];
	DatosFit = [RhoFit, Fit(:)];
            
                
	clear myfit myfittype;