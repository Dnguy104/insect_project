function [ main  ] = test( fileID )
    fs = 16000;
    length_each_file=15883;
    
    s=fileID(815,:);

    s=s-mean(s,2);
    s=s / max(abs(s));
    
    
    spect = time2spect(s);

    
    interval=fs/2/(length_each_file-1);
    startidx=floor(0/interval)+1;
    endidx=floor(2500/interval)+1;
    range=startidx:endidx;
    
    main = [];
    
    temp1 = spect(range)./sum(spect(range));
    temp2 = (range - 1)*interval;
    
    f1 = figure;
    plot((range-1)*interval,spect(range)./sum(spect(range)),'r');
    
    [x1 x2] = findpeaks(temp1,temp2,'MinPeakHeight', 0.0003, 'MinPeakDistance', 200 );

    x2 = x2';
    x1 = x1';

    y = [ x1 x2 ];

    y = y(x2 > 200, :)
    
    for i = 1:size(y,1)
        if y(i,2) 
        end
    end
    
    z1 = 0;
    z2 = 0;
    if ~isempty(y)
        z1 = y(1,2);
        z2 = max(max(y));
    end
    main = y;
    %main = [ main ; z1 z1];
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

