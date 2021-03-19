
% Try to screen through p300 images to find peaks

clear variables
close all

addpath('openFunctions\');

% User input
scanN                  =  37;
%sample                 = 'align_06' ;
sample                 = 'Ge_No3_NPs';
detectorswitch         = 1 ; % 1 = p300
midp_x                 = 303 ;
midp_y                 = 342 ;
Mini_dist              = 120 ;


% Image series & detector specific...
AllDist   = zeros(619, 487) ;
for kk = 1:size(AllDist, 1)
    for ll = 1:size(AllDist, 2)
        AllDist(kk, ll) = sqrt((kk-midp_x)^2 + (ll-midp_y)^2) ;
    end
end

% Create Mask
Mask                 = AllDist ;
Mask(Mask<Mini_dist) = 0 ;
Mask(Mask ~= 0)      = 1 ;

Mask(197:211, :)     = 0 ;
Mask(408:424, :)     = 0 ;  % 
Mask(279:328, :)     = 0 ;  % Beamstop



% Script...
detectorCounter        = 'fluo03';
mot_1                  = 'phi' ;
mot_2                  = 'om' ;
prePath                = fullfile('T:','current','raw');

scanName               = [sample '_' sprintf('%05i',scanN)];
fioFile                = [scanName '.fio'];

if detectorswitch == 1
    fioPath   = [prePath, filesep, scanName, filesep, fioFile] ;
else
    error('Undefined...')
end

[data, counters, cstr] = readfio(fioPath);

Detector_indf  = find(ismember(counters,detectorCounter) == 1) ;
Mot1_indf      = find(ismember(counters,mot_1) == 1) ;
Mot2_indf      = find(ismember(counters,mot_2) == 1) ;

if ((size(Detector_indf, 1) == 0) || (size(Mot1_indf, 1) == 0) || (size(Mot2_indf, 1) == 0))
    error('Warning! Desired detector or motor is not found!')
end

image_path = [prePath, filesep, scanName, filesep, 'p300', filesep, ] ;

% Have to exclude last scan... not nice !
Dataset_size = (size(data, 1)-1) ; 

% Read in all images
for kk = 1:Dataset_size
    
    disp(kk)
    
    if ~exist([image_path, scanName, '_', num2str(kk, '%05i'), '.cbf'], 'file')
        error('File not found')
    end
    
    MyImm = opensinglecbf([image_path, scanName, '_', num2str(kk, '%05i'), '.cbf']) ;
    MyImm = MyImm.imm ;
    
    if kk == 1
        SumImage = MyImm ;
        AllImage = zeros([size(MyImm), Dataset_size]) ;
    else
        SumImage = SumImage + MyImm ;
    end
    
    AllImage(:,:,kk) = MyImm ;
    
    
end

figure(1)
imagesc(log10(abs(SumImage)), [4.5 6])
axis image
colorbar


%% Now create mean image from cleaned raw data

AllImage2 = AllImage ; 

for kk = 1:Dataset_size
    
    LookAtImage                   = AllImage(:,:,kk) ;
    LookAtImage                   = LookAtImage .* Mask ; % Masking
    LookAtImage(LookAtImage < 0)  = 0 ;
    
    AllImage2(:,:,kk)             = LookAtImage ;
    
end

MeanImage = mean(AllImage2, 3) ;

figure(2)
imagesc(log10(MeanImage), [1.5 3])
axis image
colorbar


%% And now normalize it and correct by mean image

MaxVector = zeros(Dataset_size, 1) ;

MeanImageMultiply                         = MeanImage ;
MeanImageMultiply(MeanImageMultiply == 0) = 1 ;
MeanImageMultiply                         = 1./MeanImageMultiply ;

for kk = 1:Dataset_size
    
    LookAtImage   = AllImage2(:,:,kk) ;
    
    % Normalization
    LookAtImage   = LookAtImage .* (sum(MeanImage(:))/sum(LookAtImage(:))) ;
    
    LookAtImage   = LookAtImage .* MeanImageMultiply ;
    
    MaxVector(kk) = max(max(LookAtImage)) ;
    
    AllImage2(:,:,kk) = LookAtImage ;

end



%% Define threshold

% Vary treshhold to find only intense peaks !
Threshold = 1.1 ;

SimpleMaxList = find(MaxVector > Threshold*mean(MaxVector)) ;
disp(['Peaks found: ', num2str(length(SimpleMaxList))])

for kk = SimpleMaxList'
    figure(kk)
    set(gcf, 'position', [100 100 1400 900])
    subplot(1,2,1)
    imagesc(flipud(AllImage2(:,:,kk)), [0.8 1.5])
    title(num2str(kk))
    axis image
    
    subplot(1,2,2)
    imagesc(flipud(log10(abs(AllImage(:,:,kk)))), [1 2.5])
    title(num2str(kk))
    axis image
    
    pause(0.25)
end

%% And show positions

clc
disp('frame-no  phi,   om,  fluo-signal')
disp([SimpleMaxList, data(SimpleMaxList,1), data(SimpleMaxList,2), data(SimpleMaxList,Detector_indf)])


