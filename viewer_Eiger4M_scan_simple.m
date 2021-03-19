
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
inputParam.sampleName    = 'SiemensStar_02'; %  SampleJWX37A_1
%inputParam.sampleName    = 'Sample2371W_etched_align';
inputParam.scanNumber    = 22;
inputParam.detector      = 'e4m';
inputParam.nData         = 1; % Number of exposures per scanning point
inputParam.nDark         = 0                                               ;
inputParam.expTime       = 1.0                                             ;
inputParam.delayTime     = 0.0                                             ;
%hROI                      = [568        1053        1200        1676]       ;
%ROI = [hROI(2),hROI(2)+hROI(4),hROI(1),hROI(1)+hROI(3)];

% End of user input =======================================================
addpath('openFunctions\');
addpath('functions\');
addpath('classDef');
addpath('gui\');

% Get path to data and metadata
[masterfile, fiofile] = createPath(inputParam)                             ;

% scanObject = Scan(masterfile, fiofile);

% Get information about scan points
try
    fioParam = getinfoFio( fiofile )                                           ;
catch
    disp('no .fio file!')
end
% infoMaster = h5info(masterfile,'/entry/data/')                             ;

% Path for data saving
fioParam.saveFolder    = savePath;
fioParam.sampleName    = inputParam.sampleName;
fioParam.scanNumber    = inputParam.scanNumber;

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
dummy = openmultieiger4m_roi(masterfile, 1, fioParam.nPatterns*inputParam.nData ,ROI); % fioParam.nPatterns*inputParam.nData
dummy = dummy.imm;

if inputParam.nData>1
    dummy = reshape(dummy,[size(dummy,1),size(dummy,2),inputParam.nData,fioParam.nPatterns]);
    dummy = squeeze(sum(dummy,3));
end

% Viewer
if exist('obj','var')    
    mainGUI(obj);
else
    switch fioParam.scanType
        case 'mesh'
            % Create scan object
            data = MeshScan(dummy,fioParam);
            % Run GUI controls
            mainGUI(data);
%             data.showScanSTXM;
        case {'scan', 'series'}
            % Create scan object
            data = Scan(dummy,fioParam);
            % Run GUI controls
            mainGUI(data);    
    end
end

%%

% mu  =  [12, 11, 10] ;
% spy =  [-2619, -2617.8, -2616.2, -2614.95] ;
% spz =  [3477.4, 3477.2, 3477.2] ;

% figure(1)
% %plot(mu, spy, 'r-')
% %hold on
% plot(mu, spz, 'b-')
% %hold off
