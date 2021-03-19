clear;
close all;

%  User input for the desired scan ========================================
clc;
savePath                = fullfile('T:','current','processed','analysis'); % Normally processed folder of the beamtime
mkdir(savePath);
 
% Cases for user location
% 1 - Beamline Linux PCs
% 2 - Beamline Windows PCs 
% 3 - Office Windows PCs
% 4 - Something else
inputParam.maindirswitch = 4;

inputParam.beamtimeId    = '11005462'                                      ; % 'commissioning'
inputParam.online        = 'true';
inputParam.sampleName    = 'Ge_NPs_B_1'; % sample2371w1  Pt28092018
inputParam.scanNumber    = 36;
inputParam.seriesSwitch  = 0; % 1 - series, 0 - others
inputParam.detector      = 'e4m';
inputParam.nData         = 1                                               ; % Number of exposures per scanning point (ALSO FOR SERIES)
inputParam.nDark         = 0                                               ;
inputParam.expTime       = 1.0                                             ;
inputParam.delayTime     = 0.0                                             ;

% End of user input =======================================================

addpath('openFunctions\');
addpath('functions\');
addpath('classDef');
addpath('gui\');

% Get path to data and metadata
[masterfile, fiofile] = createPath(inputParam)                             ;

% scanObject = Scan(masterfile, fiofile);

% Get information about scan points
if ~inputParam.seriesSwitch
    fioParam = getinfoFio( fiofile )                                        ;
end
% infoMaster = h5info(masterfile,'/entry/data/')                             ;

% Path for data saving
fioParam.saveFolder    = savePath;
fioParam.sampleName    = inputParam.sampleName;
fioParam.scanNumber    = inputParam.scanNumber;

%% Open test bunch without ROI (500 frames maximum for hutch E1)
bunchN = 40                                                           ;
dummy  = openmultieiger4m(masterfile, 1, bunchN)                           ;
dummy = dummy.imm;

%% Define ROI interactively
figure; imagesc(log10(sum(dummy,3)));
hROI = round(getrect);
ROI = [hROI(2),hROI(2)+hROI(4),hROI(1),hROI(1)+hROI(3)];


%% Open full scan with ROI
dummy = openmultieiger4m_roi(masterfile, 1,fioParam.nPatterns*inputParam.nData,ROI);
dummy = dummy.imm;
if inputParam.nData>1
    dummy = reshape(dummy,[size(dummy(:,:,1)),inputParam.nData,fioParam.nPatterns]);
    dummy = squeeze(sum(dummy,3));
end


%% Open full scan without ROI
dummy = openmultieiger4m(masterfile, 1,fioParam.nPatterns*inputParam.nData);
dummy = dummy.imm;
if inputParam.nData>1
    dummy = reshape(dummy,[size(dummy(:,:,1)),fioParam.nPatterns,inputParam.nData]);
end

%% Viewer
if exist('obj','var')    
    mainGUI(obj);
else
    try
        switch fioParam.scanType1
            case 'mesh'
                % Create scan object
                data = MeshScan(dummy,fioParam);
                % Run GUI controls
                mainGUI(data);
            case {'scan', 'series'}
                % Create scan object
                data = Scan(dummy,fioParam);                
        end
    catch        
        data = Scan(dummy,fioParam);
    end
    % Run GUI controls
    mainGUI(data);
end

%% making GIF series
gifName = [savePath,'\',inputParam.sampleName,'_',num2str(inputParam.scanNumber),'.gif'];
f1 = figure;
for ii = 1:size(dummy,3)
    disp(ii);
    
    imagesc(log10(squeeze(dummy(:,:,ii))));
    colormap hot; axis image; %caxis([0.1 0.8]);
    title(num2str(ii));
    
    GIFanimation(gifName, f1, 0.1, size(dummy,3), ii);
end

%% Open test bunch with ROI 
bunchN = 40;
dummy  = openmultieiger4m_roi(masterfile, 1, bunchN, ROI);
dummy = dummy.imm;

% %% Or center of mass
% COM = ndimCOM((sum(dummy,3)),'manual');
% xc = COM(2);                                                                
% yc = COM(1);
% 
% %% Create ROI
% roiSize = 32                                                               ;
% ROI = [yc-roiSize, yc+roiSize, xc-roiSize, xc+roiSize]                     ;
% 
% %% Rotate data by 90 degrees
% dummy = rot90(dummy);
% 
% %% Manual stuff
% dummy = reshape(dummy,[size(dummy(:,:,1)),40,40]);
% dummy = squeeze(sum(dummy,3));
