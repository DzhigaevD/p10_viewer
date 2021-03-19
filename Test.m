

PathToData = 'T:\current\raw\' ;

Filename{ 1} = 'SampleJWX39B_00073' ;



% Create full filename
KKK     =  15 ;
Fullname{1} = [PathToData, Filename{ 1}, '/e4m/', Filename{ 1}, '_master.h5'] ;
Fullname{2} = [PathToData, Filename{ 1}, '/e4m/', Filename{ 1}, '_data_', num2str(1, '%06i'), '.h5']  ;
Fullname{3} = [PathToData, Filename{ 1}, '/e4m/', Filename{ 1}, '_data_'] ;

%if exist(Fullname{1})
    
    for kk = 1:KKK
        
        
        
        if ismember(kk, [11:15])
            
            NewFilename = [Fullname{3}, num2str(kk, '%06i'), '.h5']  ;
            MyData = double(h5read(NewFilename, '/entry/data/data/'));
            
            for ll = 1:10
                
                %MyImm = sum(MyData, 3) ;
                MyImm = MyData(:,:,ll) ;
                MyImm(MyImm > 3e7) = 0 ;
                MyImm = MyImm' ;
                
                figure(1)
                set(gcf, 'position', [100 100 600 1000])
                imagesc(log10(MyImm(1100:1800, 800:1800) + 1))
                %axis image
                %title(num2str(kk))
                title(num2str([kk, ll]))
                drawnow
                pause(0.1)
                
            end
        end
            
        
        %SummedImage  = zeros(size(MyData,2), size(MyData,1)) ;
        %TotIntensity = zeros(size(MyData,3), 1) ;
        
        %{
    
        for kk = 1:size(MyData, 3)

            MyImm = MyData(:, :, kk) ;
            MyImm(MyImm > 3e7) = 0 ;
            MyImm = MyImm' ;

            SummedImage      = SummedImage + MyImm ;
            TotIntensity(kk) = sum(sum(MyImm)) ;

            %{
            figure(1)
            set(gcf, 'position', [100 100 600 1000])
            subplot(2,1,1)
            imagesc(log10(MyImm + 1))
            axis image
            title(num2str(kk))

            subplot(2,1,2)
            imagesc(log10(SummedImage + 1))
            axis image
            drawnow
            %}
        end
        %}
    end
%end

%figure(2)
%plot(TotIntensity, 'r-o')


%% Try to look at 2 ROIs

%figure(1)
%imagesc(log10(SummedImage))
%imagesc(log10(SummedImage()))


%%
PathToData = 'T:\current\raw\' ;

Filename{ 1} = 'SampleJWX39B_00087' ;

KKK     =  100 ;



% Create full filename

Fullname = [PathToData, Filename{ 1}, '/e4m/', Filename{ 1}, '_data_', num2str(1, '%06i'), '.h5']  ;

if exist(Fullname)
    
    MyData      = double(h5read(Fullname, '/entry/data/data/'));
    
    for kk = 1:KKK
        
        MyImm = MyData(:,:,kk) ;
        
        MyImm(MyImm > 3e7) = 0 ;
        MyImm = MyImm' ;

        figure(1)
        set(gcf, 'position', [100 100 1000 1000])
        imagesc(log10(MyImm(1100:1600, 1100:1900) + 1))
        %axis image
        %title(num2str(kk))
        title(num2str(kk))
        drawnow
        pause(0.1)

    end
else
    disp('data not found')
end
            



