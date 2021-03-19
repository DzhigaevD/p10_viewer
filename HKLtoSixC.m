function F = HKLtoSixC(x)
%Angle calculations for six circle diffractometer. Z-axis geometry, no
%miscut assumed, incidence angle is fixed, sample lattice unit cell is orthonormal, c-axis along
%the theta axis, a and b axes of the sample lay along x and y axes of Cartesian
%frame mounted on the th-axis, respectively. That is, no orientation matrix, UB is fixed
%with the th-frame, only axis length are allowed to be different. That is, U*B is
%always diagonal matrix and CHI and PHI is not calculated, insidence angle
%is fixed in x(3);
%x - is a vector, containing:
%[lattice constant in angstroms; vavelength in angstroms; incidencewwsw
%angle; h; k; l]; all angles are in
%degrees
% Created by R. Shayduk, last updated 18.01.2017

%a = 3.9245; 
a=x(1);
%lambda =0.82656; %X-ray wavelength used at ESRF experiment HC2294
lambda=x(2);
%alpha=2*pi/180; %Incidence angle used at ESRF in 2016 experiment HC2294
alpha=x(3)*pi/180;

UB=(2*pi)/a*[[2^0.5;0;0],[0;1;0],[0;0;2^0.5]]; %UB matrix for properly orineted FCC-crystal in 110-surface unit cell notation
ki=2*pi/lambda*[0;1;0];
H=[x(4);x(5);x(6)];

function Minimization = MatrixFunctional(y) %functional to be minimized for numerical solution of non-linear system
    %omega=125.285*pi/180; %
%delta=24.05*pi/180;
%gamma=33.7*pi/180; 
omega=y(1)*pi/180 ;%
delta=y(2)*pi/180;
gamma=y(3)*pi/180;
Omega=[[cos(omega);-sin(omega);0],[sin(omega);cos(omega);0],[0;0;1]];
Delta=[[cos(delta);-sin(delta);0],[sin(delta);cos(delta);0],[0;0;1]];
Gamma=[[1;0;0],[0;cos(gamma);sin(gamma)],[0;-sin(gamma);cos(gamma)]];
Alpha=[[1;0;0],[0;cos(alpha);sin(alpha)],[0;-sin(alpha);cos(alpha)]];

Minimization=Omega*UB*H-(Delta*Gamma-inv(Alpha))*ki; %the non-linear equation system with respect to y, y=[omega; delta; gamma]
end

 fun = @MatrixFunctional;
 y0 = [1,10,10]; %arbitrary initial values
 options=optimset('MaxFunEvals',5000,'TolFun',1e-5,'Display','off');
 F = fsolve(fun,y0,options); %solution
 %MatrixFunctional(F) 
end