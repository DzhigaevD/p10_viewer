%  User input for the desired scan =======================================
clc;
savePath                = fullfile('T:','current','processed','analysis'); % Normally processed folder of the beamtime
mkdir(savePath);
close all 
% Cases for user location
% 1 - Beamline Linux PCs
% 2 - Beamline Windows PCs 
% 3 - Office Windows PCs
% 4 - Something else
inputParam.maindirswitch = 2;

inputParam.beamtimeId    = '11003964'                                      ; % 'commissioning'
inputParam.online        = 'true';
inputParam.sampleName    = 'JWX38_CsPbBr3';
%inputParam.sampleName    = 'Sample2371W_etched_align';
inputParam.scanNumber    = 35;
inputParam.detector      = 'e4m';
inputParam.nData         = 1 ;      % OBS chang exp times                                   ; % Number of exposures per scanning point
inputParam.nDark         = 0                                               ;
inputParam.expTime       = 1.0                                             ;
inputParam.delayTime     = 0.0   ;
nPatterns                = 3600;
%hROI                      = [568        1053        1200        1676]       ;
%ROI = [hROI(2),hROI(2)+hROI(4),hROI(1),hROI(1)+hROI(3)];

% End of user input =======================================================
addpath('openFunctions\');
addpath('functions\');
addpath('classDef');
addpath('gui\');

% Define ROI interactively
if ~exist('ROI', 'var')
    % Open test bunch without ROI (500 frames maximum for hutch E1)
    bunchN = 20                                                               ;
    dummy  = openmultieiger4m(masterfile, 1, bunchN)                           ;
    dummy = dummy.imm;
    figure; imagesc(log10(sum(dummy,3)));
    hROI = round(getrect);
    ROI = [hROI(2),hROI(2)+hROI(4),hROI(1),hROI(1)+hROI(3)];
end

% Open full scan with ROI
% dataInfo = h5info(masterfile);
% nRecorded = length(dataInfo.Groups.Groups(1).Links);
dummy = openmultieiger4m_roi(masterfile, 1, nPatterns ,ROI); % fioParam.nPatterns*inputParam.nData
dummy = dummy.imm;

%%
figure
plot(squeeze(sum(sum(dummy,1),2)));