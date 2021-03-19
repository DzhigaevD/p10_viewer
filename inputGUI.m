function inputGUI()
% This script allows the data analysis of the scans 
    close all;

    beamtimeID_pre = '11005359';
    sampleName_pre = 'dewet2_2';
    
    % ============================ GUI ====================================
    % --- Create the starting window
    % =====================================================================  
        
    mainInputF = figure('Name','Scan Input',...
        'NumberTitle','off','units',...
        'normalized','outerposition',[0 0.45 0.2 0.5]);
    
    % Button elements + callback ==========================================    
    % - User location -
    uicontrol('Parent',mainInputF,'Units','normalized',...
        'Position',[0.05 0.9 0.4 0.05],'style','text','String','User location');       
    
    locationList = {'Beamline Linux PC', 'Beamline Windows PC', 'Office Windows PC', 'User defined'};
    
    hUserLocation = uicontrol('Parent',mainInputF,'Style','popupmenu','Units','normalized',...
        'Position',[0.55 0.9 0.4 0.05],'Value', 2,...
        'String',locationList);    
    
    % =====================================================================    
    % - Beamtime ID -                         
    uicontrol('Parent',mainInputF,'Units','normalized','Style','text',...
        'Position',[0.05 0.85 0.4 0.05],'String','Beamtime ID'); 
    
    hBeamtimeID = uicontrol('Parent',mainInputF,'Style','edit','Units','normalized',...
        'Position',[0.55 0.85 0.4 0.05],'String',beamtimeID_pre);
    
    % =====================================================================
    % - Online status -
    uicontrol('Parent',mainInputF,'Units','normalized','Style','text',...
        'Position',[0.05 0.8 0.4 0.05],'String','Online State'); 
    
    hOnline = uicontrol('Parent',mainInputF,'Style','checkbox','Units','normalized',...
        'Position',[0.55 0.8 0.4 0.05],'Value',1);        
    
    % =====================================================================
    % - Sample name -     
    uicontrol('Parent',mainInputF,'Units','normalized','Style','text',...
        'Position',[0.05 0.75 0.4 0.05],'String','Sample Name'); 
    
    hSampleName = uicontrol('Parent',mainInputF,'Style','edit','Units','normalized',...
        'Position',[0.55 0.75 0.4 0.05],'String',sampleName_pre);
    
    % =====================================================================              
    % - Scan number -     
    uicontrol('Parent',mainInputF,'Units','normalized','Style','text',...
        'Position',[0.05 0.7 0.4 0.05],'String','Scan number'); 
    
    hScanNumber = uicontrol('Parent',mainInputF,'Style','edit','Units','normalized',...
        'Position',[0.55 0.7 0.4 0.05],'String','1');
    
    % =====================================================================
    % - Detector -
    uicontrol('Parent',mainInputF,'Units','normalized',...
        'Position',[0.05 0.65 0.4 0.05],'style','text','String','Detector');       
    
    detectorList = {'e4m', 'pilatus300k', 'lambda', 'diffdio', 'udio'};
    
    hDetector = uicontrol('Parent',mainInputF,'Style','popupmenu','Units','normalized',...
        'Position',[0.55 0.65 0.4 0.05],'String',detectorList); 
    
    % =====================================================================        
    % - Number of frames -
    uicontrol('Parent',mainInputF,'Units','normalized',...
        'Position',[0.05 0.6 0.5 0.05],'style','text','String','# of frames per position');       
    
    hNumberOfFrames = uicontrol('Parent',mainInputF,'Style','edit','Units','normalized',...
        'Position',[0.55 0.6 0.4 0.05],'String','1'); 
    
    % =====================================================================        
    % - Series switch -
    uicontrol('Parent',mainInputF,'Units','normalized','Style','text',...
        'Position',[0.05 0.55 0.4 0.05],'String','Series scan'); 
    
    hSeries = uicontrol('Parent',mainInputF,'Style','checkbox','Units','normalized',...
        'Position',[0.55 0.55 0.4 0.05],'Value',0);    
    
    % =====================================================================        
    % - User-defined test bunch -
    uicontrol('Parent',mainInputF,'Units','normalized','Style','text',...
        'Position',[0.05 0.5 0.4 0.05],'String','Test frames'); 
    
    hTestStart = uicontrol('Parent',mainInputF,'Style','edit','Units','normalized',...
        'Position',[0.55 0.5 0.2 0.05],'String',1);    
    
    hTestStop = uicontrol('Parent',mainInputF,'Style','edit','Units','normalized',...
        'Position',[0.75 0.5 0.2 0.05],'String',10);    
    
    % =====================================================================
    % - Load Scan info - 
    uicontrol('Parent',mainInputF,'Units','normalized',...
        'Position',[0.05 0.02 0.2 0.1],'String','Load Info',...
        'Callback',@loadInfo);
      
    % =====================================================================
    % - Functions -
    function [inputParam,fioParam,masterfile] = loadInfo(hObj,callbackdata)
        savePath                = fullfile('T:','current','processed','analysis'); % Normally processed folder of the beamtime
        mkdir(savePath);
        
        addpath('openFunctions');
        addpath('functions');
        addpath('classDef');
        addpath('gui');
        
        inputParam.maindirswitch = get(hUserLocation,'Value')              ;
        inputParam.beamtimeId    = get(hBeamtimeID,'String')               ;
        inputParam.online        = get(hOnline,'Value')                    ;
        inputParam.sampleName    = get(hSampleName,'String')               ; 
        inputParam.scanNumber    = str2double(get(hScanNumber,'String'))   ;
        inputParam.detector      = detectorList{get(hDetector,'Value')}    ;                           
        inputParam.nData         = str2double(get(hNumberOfFrames,'String')); % Number of exposures per scanning point
        inputParam.nDark         = 0                                       ;
        inputParam.expTime       = 1.0                                     ;
        inputParam.delayTime     = 0.0                                     ;
        inputParam.testStart     = str2double(get(hTestStart,'String'))    ;
        inputParam.testStop      = str2double(get(hTestStop,'String'))     ;
        inputParam.seriesSwitch  = get(hSeries, 'Value')                   ;
        
        try
            % Get path to data and metadata
            % UPDATE FOR FIO FLAGS IS NEEDED!!!
            [masterfile, fiofile] = createPath(inputParam)                     ;              

            % Get information about scan points
            if ~inputParam.seriesSwitch
                disp('Reading .fio data...')                                   ;
                fioParam = getinfoFio( fiofile )                               ;            
                disp('Reading .fio data, finished...')                         ;
            else
                disp('Reading series data, finished...')                       ;
                fioParam.scanType1    = 'scan';
                fioParam.scanType     = 'scan';
            end
        catch
            error('The input parameters are wrong!')
        end
        
        % Path for data saving
        fioParam.saveFolder    = savePath;
        fioParam.sampleName    = inputParam.sampleName;
        fioParam.scanNumber    = inputParam.scanNumber;
        
        % =====================================================================
        % - Load full scan without ROI - 
        uicontrol('Parent',mainInputF,'Units','normalized',...
            'Position',[0.25 0.02 0.2 0.1],'String','Full',...
            'Callback',@run_loadFullScan);

        % =====================================================================
        % - Load Test Scan - 
        uicontrol('Parent',mainInputF,'Units','normalized',...
            'Position',[0.45 0.02 0.2 0.1],'String','Test',...
            'Callback',@run_loadTestScan);        
        
        function dummy = loadFullScan(inputParam,fioParam,masterfile)
            % Open full scan without ROI
            disp('Reading data...');
            
            try
                dummy = openmultieiger4m(masterfile, 1,fioParam.nPatterns*inputParam.nData);
                dummy = dummy.imm;
                if inputParam.nData>1
                    dummy = reshape(dummy,[size(dummy(:,:,1)),fioParam.nPatterns,inputParam.nData]);
                end
            catch
                dummy = openmultieiger4m(masterfile);
                dummy = dummy.imm;
                disp('Incomplete scan!');
                if inputParam.nData>1
                    disp('Summation skipped!');
                end
            end                        
            
            disp('Reading data, finished...');
            viewer(fioParam,dummy);
        end
        
        function [dummy, ROI] = loadTestScan(masterfile)            
            dummy  = openmultieiger4m(masterfile, inputParam.testStart, inputParam.testStop)                           ;
            dummy = dummy.imm;
            
            % Define ROI interactively
            figure; imagesc(log10(sum(dummy,3)));
            disp('Select a region of interest by left click and drag');
            hROI = round(getrect);
            ROI = [hROI(2),hROI(2)+hROI(4),hROI(1),hROI(1)+hROI(3)];
            close;
            disp('Region of interest is selected');
            
            % =====================================================================
            % - Load Scan info - 
            uicontrol('Parent',mainInputF,'Units','normalized',...
            'Position',[0.65 0.02 0.2 0.1],'String','Plot ROI',...
            'Callback',@run_loadROIScan);
            
            function dummy = run_loadROIScan(hObj,callbackdata)           
                dummy = loadROIScan(inputParam,fioParam,masterfile,ROI); 
                viewer(fioParam,dummy);
            end
        
            function [dummy] = loadROIScan(inputParam,fioParam,masterfile,ROI)
                % Open full scan with ROI
                disp('Reading data with ROI...');
                
                try
                    dummy = openmultieiger4m_roi(masterfile, 1,fioParam.nPatterns*inputParam.nData,ROI);                    
                    dummy = dummy.imm;
                    if inputParam.nData>1
                        dummy = reshape(dummy,[size(dummy(:,:,1)),inputParam.nData,fioParam.nPatterns]);
                        dummy = squeeze(sum(dummy,3));
                    end
                catch
                    dummy = openmultieiger4m_roi(masterfile,ROI);                    
                    dummy = dummy.imm;
                    disp('Incomplete scan!');
                    if inputParam.nData>1
                        disp('Summation skipped!');
                    end
                end
                
                disp('Reading data with ROI, finished');                
            end
        end
        
        function viewer(fioParam,dummy)
        % Viewer            
            try
                switch fioParam.scanType1
                    case 'mesh'
                        % Create scan object
                        data = MeshScan(dummy,fioParam);                        
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
        
        % =====================================================================
        % - Callbacks -    
        function dummy = run_loadFullScan(hObj,callbackdata)
            dummy = loadFullScan(inputParam,fioParam,masterfile);
        end
        
        function [dummy, ROI] = run_loadTestScan(hObj,callbackdata)
            [dummy, ROI] = loadTestScan(masterfile);
        end                
        % =====================================================================

    end
end