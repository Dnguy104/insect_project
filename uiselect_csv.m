%=========================================================================%
%   This code displays every signal and the spectrum in the srcFolder. 
%   User select the data by clicking on the image (you will see a red rectangle once the signal is successfully selected). 
%   If 'desFolder' is provided, the selected files will be moved to 
%   'desFolder', otherwise, only return the names of the selected files.
%   If you want to copy insetead of move, change "movefile" in line 188 to
%   "copyfile".
%   Output: Names of the selected files
%   Input:
%   srcFolder: the folder that contains the csv files
%   desFolder: the folder that you wish to put the selected files in
%   nSubRows: Rows of the display. Normally you can set this as 6.
%   nSubCols: Columns of the display. Normally you can set this to 1.
%   random: 0-display in order; 1-display in random order
%   Example input:
%   >>selectedNames=uiselect_csv('data\7.14','data\selected_7.14',6,1,0);
%   If you dont't want to specify a destination folder, then nothing will
%   be moved out of srcFolder:

%   >>selectedNames=uiselect_csv('data\7.14','',6,1,0);
%   Written by Yan Zhu and Yanping Chen
%=========================================================================%

function selectedFileNames = uiselect_csv(srcFolder,desFolder,nSubRows,nSubCols,random)
    if (nargin < 1)
        srcFolder = pwd;
    end
    if(nargin < 2)
        desFolder = '';
    end
    if(~isempty(desFolder) & exist(desFolder)~=7)
        mkdir(desFolder);
    end
    if(nargin < 3)
        nSubRows = 10; 
    end
    if(nargin < 4)
        nSubCols = 5; 
    end
    if(nargin < 5)
        display_spect = 0;
    end
    
    selectedFileNames = []; 
    nFrames = nSubCols * nSubRows;
    files = dir(fullfile(srcFolder, '*.wav'));
    nFiles = length(files);
        
    perm = 1:nFiles;
    if(random == 1)
       perm = randperm(nFiles);
    end

    [a,map]=imread('play.jpg');  %image for play button
   
    
    [r,c,d]=size(a); 
    x=ceil(r/20); y=ceil(c/20); 
    playim=a(1:x:end,1:y:end,:);
    
    playim(playim==255)=5.5*255;
    
    global STOP;
    STOP = 0;
    
    
    
    
    
    %===================     Lay out the GUI   ====================%
    for page = 1: ceil(nFiles/nFrames)
        if(STOP == 1) 
            break;  
        end

        tmpfig = figure('numbertitle','off','MenuBar','none','units',...
            'normalized','name',['Select the data to be REMOVED from '...
            srcFolder, '.    Page ',num2str(page)],...
            'pos',[0 0.045 1 0.92],'closerequestfcn',@mycloserequestfcn);
        
        txt = 'To select or un-select a data, click on its BLUE part:';
        msgdisplay = uicontrol('style','text','units','normalized',...
            'position',[0.08 -1.05 0.4 0.03],'string',txt,'FontUnits',...
            'normalized','FontSize', 0.7);      
 
        if(page < ceil(nFiles/nFrames))  buttonString = 'NEXT';
        else  buttonString = 'FINISH'; end
        okaybutton = uicontrol('style','pushbutton','string',buttonString,...
            'units','normalized','position',[0.35 0.025 0.275 0.05],...
            'callback',{@okay,page},'enable','on');

        subim = zeros(nFrames*2,1);
        ptch =zeros(nFrames,1); 
        playButton = zeros(nFrames,1);
        
        for i = 1:nFrames
            ix = (page-1) * nFrames + i;
            if(ix <= nFiles)
                fileID= audioread(fullfile(srcFolder,files(perm(ix)).name));
                fs = 16000;
                
                length_each_file=15883;
                %length_each_file=1024;
                
                laststring=' ';


                s=fileID;
                s=s-mean(s);
                s=s/max(abs(s));
                spect = time2spect(s);
                
                subplot(nSubRows,nSubCols*2,i*2-1);
                subim(i*2-1) = plot(s);
                set(gca,'xlim',[0 length_each_file]);
                %set(gca,'ylim',[-0.5 0.5]);
%                 set(gca,'YTickLabel',{'','',''},'XTickLabel',{'','',''});
                hold on
                subplot(nSubRows,nSubCols*2,i*2);
                interval=fs/2/(length(spect)-1);
                startidx=floor(0/interval)+1;
                endidx=floor(2500/interval)+1;
                range=startidx:endidx;
                subim(i*2) = plot((range-1)*interval,spect(range)./sum(spect(range)),'r');
                set(gca,'Xlim',[(range(1)-1)*interval (range(end)-1)*interval]);
                mainfreq=getMainFreq(spect,fs);
                if mainfreq>100
                    title(['mainfreq=',num2str(mainfreq), ',score=',num2str(CalculateXYZ(spect,fs,mainfreq)),'---',laststring]);
                else
                    title(['mainfreq=',num2str(mainfreq)]);
                end
%                 set(gca,'Ylim',[0 0.01]);
                

                %create patch;	Pad x- and y-lim of current axis to include
                %  patch; and send the patch behind the plot
                subplot(nSubRows,nSubCols*2,i*2-1);
                x_aug = 0.05*diff(get(gca,'xlim'));
                y_aug = 0.05*diff(get(gca,'ylim'));
                tmpvalx=get(gca,'xlim');

                tmpvaly=get(gca,'ylim');
                ptch(i) = patch([tmpvalx(1)-x_aug tmpvalx(2)+x_aug tmpvalx(2)+x_aug tmpvalx(1)-x_aug],...
                    [tmpvaly(1)-y_aug tmpvaly(1)-y_aug tmpvaly(2)+y_aug tmpvaly(2)+y_aug],[1 0 0],...
                    'visible','off','edgecolor','none','selected','off');
                %ptch(i) = patch([-x_aug 2000+x_aug 2000+x_aug -x_aug],...
                %    [-y_aug-0.5 -y_aug-0.5 y_aug+0.5 0.5+y_aug],[1 0 0],...
                %    'visible','off','edgecolor','none','selected','off');
                
                set(gca,'children',flipud(get(gca,'children')),...
                    'xlim',get(gca,'xlim')+[-x_aug x_aug],...
                    'ylim',get(gca,'ylim')+[-y_aug y_aug]);
                set(subim(i*2-1),'userdata',i);

                %create play button
                pos = get(gca,'Position'); shift = 0.0007;
                playButton(i) = uicontrol('style','pushbutton',...
                     'units','normalized','CData',playim,...
                     'position',[pos(1)+pos(3)+shift pos(2)-shift 0.015 0.03],...
                     'callback',{@playSound,s,fs});
            end
        end

        set(subim,'buttondownfcn',@imsel);
        uiwait(tmpfig);
    end
    
    
    
    
    if(~isempty(desFolder) & numel(dir(fullfile(desFolder,'*.wav')))<1)
        rmdir(desFolder);
    end

    %====================  NESTED FUNCTIONS  ============================%
    function playSound(varargin)
        signal = varargin{3};
        fs = varargin{4};
        sound(signal,fs);
    end

	function newselected = imsel(varargin)
		newselected = get(varargin{1},'userdata');
        if(strcmp(get(ptch(newselected),'selected'),'off'))
            set(ptch(newselected),'selected','on');
        else
            set(ptch(newselected),'selected','off');
        end
        unselected = find(strcmp(get(ptch,'selected'),'off'));
        set(ptch(unselected),'visible','off');
		selected = find(strcmp(get(ptch,'selected'),'on'));
        set(ptch(selected),'visible','on','Selected','on');
    end

	function okay(varargin)
        ptchVis = get(ptch,'visible');
		selected = find(strcmp(ptchVis,'on'));
        set(ptch(selected),'visible','on','SelectionHighlight','on','Selected','on');
        nselected = length(selected);
        p = varargin{3};
        for j = 1: nselected
            ix = (p -1) * nFrames + selected(j);
            if(ix < nFiles)
                selectedFileNames = [selectedFileNames; cellstr(files(perm(ix)).name)];
                if(~isempty(desFolder))
                    movefile(fullfile(srcFolder,files(perm(ix)).name),...
                            fullfile(desFolder, files(perm(ix)).name));
                end
            end
        end     
        delete(gcf);
        drawnow;
    end

	function mycloserequestfcn(varargin)
        selectedFileNames = [];
		closereq;
        STOP = 1;
	end

end

function score=CalculateXYZ(spect,fs,mainfreq)
    if mainfreq>100 && mainfreq<2500
        interval=fs/2/(length(spect)-1);
        bandwidth=50;
        mainidx=floor(mainfreq/interval)+1;
        idxbandwidth=ceil(bandwidth/interval);
        filter=false(1,length(spect));
        endidx=floor(2500/interval);
        for i=1:floor(endidx/mainidx)
            curmin=max(1,mainidx*i-idxbandwidth);
            curmax=min(endidx,mainidx*i+idxbandwidth);
            filter(curmin:curmax)=true;
        end
        startidx=floor(100/interval)+1;
        %startidx=max(1,mainidx-idxbandwidth);
        filter2=true(1,length(spect));
        filter2([1:(startidx-1) (endidx+1):length(spect)])=false;
        score=sum(spect(filter))/sum(spect(filter2));
    else
        score=0;
    end
end

function mainfreq=getMainFreq(spect,fs)
    interval=fs/2/(length(spect)-1);
    starting=100;
    startidx=floor(starting/interval);
    bandwidthidx=floor(100/interval);
    bwidx=floor(75/interval);
    [maxpow, maxidx]=max(spect(startidx:end));
    maxidx=startidx+maxidx-1;
    maxfreq=(maxidx-1)*interval;
    mainfreq=maxfreq;
    if mainfreq>200
        %spect(maxidx-bandwidthidx:maxidx+bandwidthidx)=0;
        spect(maxidx-bandwidthidx:end)=0;
        halfmid=floor(maxidx/2);
        [secondmaxpow,secondmaxidx]=max(spect(startidx:end));
        secondmaxidx=startidx+secondmaxidx-1;
        front=halfmid-bwidx;
        back=halfmid+bwidx;  
        
        if secondmaxidx>front && secondmaxidx < back && secondmaxpow>max(spect(front),spect(back))*1.5 
            idx=[floor(maxidx/2) ceil(maxidx/2)];
            half_freq_pow=max(spect(idx));
            if half_freq_pow>=maxpow/10
                mainfreq=maxfreq/2;
            end
        end
    end
end

function spect = time2spect(s)
% convert a time-domain signal s to power spectrum using fft
    n=length(s);
    NFFT = 2^nextpow2(n)*4;
    spect = fft(s,NFFT);
    spect = abs(spect(1:NFFT/2+1)).^2;
    spect(2:end-1)=spect(2:end-1)*2;
    %spect = spect/sum(spect);
    spect = spect/NFFT;
    spect = smooth(spect,10);
    %spect = reshape(spect,1,[]);
end

