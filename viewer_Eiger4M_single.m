clear;
close all;

%  User input for the desired scan ========================================
savePath                = './'; % Normally processed folder of the beamtime

% Cases for user location
% 1 - Beamline Linux PCs
% 2 - Beamline Windows PCs 
% 3 - Office Windows PCs
% 4 - Something else
inputParam.maindirswitch = 2;

inputParam.beamtimeId    = '11005294'                                      ; % 'commissioning'
inputParam.online        = 'true';
inputParam.sampleName    = 'align_A';
inputParam.masterNumber  = 160;
inputParam.imageNumber   = 1;
inputParam.detector      = 'e4m';
inputParam.nData         = 1                                               ; % Number of exposures per scanning point
inputParam.nDark         = 0                                               ;
inputParam.expTime       = 10.0                                            ;
inputParam.delayTime     = 0.0                                             ;

% End of user input =======================================================
addpath('openFunctions\');

% Get path to data and metadata
masterfile = createPath_single(inputParam)                             ;

image = opensingleeiger4m(masterfile,inputParam.imageNumber);
image = image.imm;

% Single figure
figure;
imagesc(log10(image));
axis image;
colorbar;colormap jet


