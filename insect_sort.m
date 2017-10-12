function [ main  ] = insect_sort( fileID )
    fs = 16000;
    length_each_file=15883;
    
    s=fileID;

    s=s-repmat(mean(s,2),1,15883);
    s=s ./ repmat(max(abs(s), [], 2), 1, 15883);
    
    
    spect = arrayfun(@(n) time2spect(s(n,:)), 1:size(s,1),'UniformOutput',0)';

    
    interval=fs/2/(length_each_file-1);
    startidx=floor(0/interval)+1;
    endidx=floor(2500/interval)+1;
    range=startidx:endidx;
    
    spect = cell2mat(spect);
    
    main = [];
    
    temp1 = spect(:,range)./repmat(sum(spect(:,range),2),1,size(range,2));
    %size(temp1)
    temp2 = (range - 1)*interval;
    %size(temp2)
    for i = 1:5000
    [x1 x2] = findpeaks(temp1(i,:),temp2,'MinPeakHeight', 0.00005, 'MinPeakDistance', 200 );
    if ~isempty(x1)
        [x1 x2] = findpeaks(temp1(i,:),temp2,'MinPeakHeight', x1(1)*0.1, 'MinPeakDistance', 200 );
    end
    x2 = x2';
    x1 = x1';

    y = [ x1 x2 ];
    y = y(x2 > 250, :);
    z1 = 0;
    z2 = 0;
    z3 = 0;
    if ~isempty(y)
        z1 = y(1,2);
        z2 = size(y,1);
        z3 = mean(y(:,2));
    end

    main = [ main ; z1 z2 z3];
    end
    %f1 = figure;
    %plot((range-1)*interval,spect(range)./sum(spect(range)),'r');

    %f2 = figure;
    %disp(num2str(mainfreq,'%.2f'))
end

function mainfreq=getMainFreq(spect,fs)
    interval=fs/2/(length(spect)-1);
    starting=100;
    startidx=floor(starting/interval);
    bandwidthidx=floor(100/interval);    bwidx=floor(75/interval);
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
    %spect = smooth(spect,10);
    %spect = reshape(spect,1,[]);
end
