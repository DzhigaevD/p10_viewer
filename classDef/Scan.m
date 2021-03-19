classdef Scan < handle
    %SCAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        data;
        dataSize;        
        metaData;        
    end
    
    % Constructor of the object
    methods
        function obj = Scan(dataArray,fioParam)
            obj.data      = dataArray;
            obj.dataSize  = size(dataArray);
            obj.metaData  = fioParam;
        end
    end    
    
    % Methods for calculations
    methods
        
        function averagePattern = averageScan(obj)
            if ndims(obj.data) == 4                
                averagePattern = sum(sum(obj.data,4),3);
            else
                averagePattern = sum(obj.data,3);
            end
        end
        
        function data3D = dataTo3D(obj)
            data3D = log10(obj.data)./max(max(max(log10(obj.data))));
        end
                        
        function integratedScan = integrateScan(obj)
            if ndims(obj.data) == 4                
                integratedScan = squeeze(sum(sum(squeeze(sum(obj.data,3)),1),2));
            else
                integratedScan = squeeze(sum(sum(obj.data,1),2));
            end
        end                                
        
%         function readDiffractionDataBunch(obj, bunchSize)
%             obj.diffractionData = openmultieiger4m(obj.pathMaster, 1, bunchSize);
%         end
%         
%         function readDiffractionDataBunchROI(obj, bunchSize, ROI)
%             obj.diffractionData = openmultieiger4m_roi(obj.pathMaster, 1, bunchSize, ROI);
%         end        
    end
    
    % Show methods
    methods       
        
        function showScan3D(obj,isoVal)
            if nargin == 1
                isoVal = 0.5;
            end
            figure; isosurface(dataTo3D(obj),isoVal); axis image
        end
        
        function showScanScroll(obj,maxVal)
            if nargin == 1
                maxVal = 3;
            end
%             stackSlider(obj.data,maxVal)
            if ndims(obj.data) == 4     
                handle = implay(log10(sum(obj.data,3)));
            else
                handle = implay(log10(obj.data));
            end
            handle.Visual.ColorMap.MapExpression = 'hot'; 
            handle.Visual.ColorMap.UserRangeMin = 0.1;
            handle.Visual.ColorMap.UserRangeMax = maxVal;
            handle.Visual.ColorMap.UserRange = maxVal;
        end
        
        function showScanScrollMod(obj)             
            stackSliderMod(obj.data)
        end
        
        function handles = showScanSingle(obj, index)
            if nargin == 1
                index = 1;
            end
            handles.figHandle = figure;
            handles.imHandle = imagesc(log10(abs(obj.data(:,:,index))),[0 1]);
            axis image;
            handles.colorBar = colorbar;
            ylabel(handles.colorBar,'log');
            colormap jet;
            title([obj.metaData.sampleName ' | Scan ' num2str(obj.metaData.scanNumber) ' | Frame ' num2str(index)]);
        end
        
        function handles = showScanAverage(obj)
            handles.figHandle = figure;
            handles.imHandle = imagesc(log10(averageScan(obj)));
            axis image;
            handles.colorBar = colorbar;
            ylabel(handles.colorBar,'log');
            colormap jet;
            title(['Average: ' obj.metaData.sampleName ' | Scan ' num2str(obj.metaData.scanNumber)]);
        end
        
        function handles = showScanIntegral(obj) 
            handles.figHandle = figure;
            try
                handles.imHandle = plot(obj.metaData.Vector, integrateScan(obj),'-o');
            catch
                handles.imHandle = plot(integrateScan(obj),'-o');
            end
            ylabel('Integral intensity');
            xlabel('Scan motor position');
            title([obj.metaData.sampleName ' | Scan ' num2str(obj.metaData.scanNumber)]);
        end   
        
        function handles = showReflectivity(obj) 
            handles.figHandle = figure;
            handles.imHandle = plot(obj.metaData.Vector1,log10(integrateScan(obj)),'-o');
            ylabel('Integral intensity');
            xlabel(['Incidence angle ', obj.metaData.fastMotorName]);
        end   
        
    end
    
    % Save methods
    methods
        function saveGif(obj)
            disp('Saving GIF animation...');
            fileTemp = [obj.metaData.sampleName,'_',num2str(obj.metaData.scanNumber)];
            mkdir(fullfile(obj.metaData.saveFolder,fileTemp));
            
            gifName = [obj.metaData.saveFolder,'\',obj.metaData.sampleName,'_',num2str(obj.metaData.scanNumber),'.gif'];
            f1 = figure;
            for ii = 1:size(obj.data,3)
                disp(ii);

                imagesc(log10(squeeze(obj.data(:,:,ii))));
                colormap hot; axis image; %caxis([0.1 0.8]);
                title([obj.metaData.sampleName ' | Scan ' num2str(obj.metaData.scanNumber) ' | Frame ' num2str(ii)]);           

                GIFanimation(gifName, f1, 0.1, size(obj.data,3), ii);
            end
            disp('Done!');
        end
        
        function saveScan(obj)
            disp('Saving data to .mat ...');
            fileTemp = [obj.metaData.sampleName,'_',num2str(obj.metaData.scanNumber)];
            mkdir(fullfile(obj.metaData.saveFolder,fileTemp));
            save(fullfile(obj.metaData.saveFolder,fileTemp,[fileTemp,'.mat']),'obj','-v7.3');
            
            ttt = obj.data;
            save(fullfile(obj.metaData.saveFolder,fileTemp,[fileTemp,'_diff.mat']),'ttt','-v7.3');            
            disp('Done!');
            
            disp('Saving data to .bin ...');                        
            fid = fopen(fullfile(obj.metaData.saveFolder,fileTemp,[fileTemp,'.bin']),'wb');            
            fwrite(fid,ttt,'double');
            fclose(fid);
            clear ttt;
            disp('Done!');
        end
    end
end

