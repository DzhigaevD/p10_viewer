function F = SixCtoHKL(x)
%HKL from Angle calculations for six circle diffractometer. Z-axis geometry, no
%miscut assumed, incidence angle is fixed, sample lattice unit cell is orthonormal, c-axis along
%the theta axis, a and b axes of the sample lay along x and y axes of Cartesian
%frame mounted on the th-axis, respectively. That is, no orientation matrix, UB is fixed
%with the th-frame, only axis lentgh are allowed to be different. That is, U*B is
%always diagonal matrix.
%x - is a vector, containing:
%[lattice constant in angstroms; vavelength in angstroms; incidence
%angle; omega angle (sample azimuth); delta; gamma]; all angles are in
%degrees
% Created by R. Shayduk, last updated 18.01.2017

%a = 3.9245; 
a=x(1);
%lambda =0.82656; %X-ray wavelength used at ESRF experiment HC2294
lambda=x(2);
%alpha=2*pi/180; %Incidence angle used at ESRF in 2016 experiment HC2294
alpha=x(3)*pi/180;

UB=(2*pi)/a*[[2^0.5;0;0],[0;1;0],[0;0;2^0.5]]; %UB matrix for properly orineted FCC-crystal in 110-surface unit cell notation

%omega=125.285*pi/180; %
%delta=24.05*pi/180;
%gamma=33.7*pi/180; 
omega=x(4)*pi/180; %
delta=x(5)*pi/180;
gamma=x(6)*pi/180; 



Omega=[[cos(omega);-sin(omega);0],[sin(omega);cos(omega);0],[0;0;1]];
Delta=[[cos(delta);-sin(delta);0],[sin(delta);cos(delta);0],[0;0;1]];
Gamma=[[1;0;0],[0;cos(gamma);sin(gamma)],[0;-sin(gamma);cos(gamma)]];
Alpha=[[1;0;0],[0;cos(alpha);sin(alpha)],[0;-sin(alpha);cos(alpha)]];

%H=zeros(3,1);
ki=2*pi/lambda*[0;1;0];

F=(inv(UB)*inv(Omega)*(Delta*Gamma-inv(Alpha)))*ki;
end