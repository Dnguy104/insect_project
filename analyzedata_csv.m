%=========================================================================%
% This code automatically filter out noisy data, and then analyze the winbeat 
% frequency distribution and circadian rhythm of the high-quality (or good) insect data in the folder.
% 
% Output:
% You will see three plots:
% 1. Frequency distribution
% 2. Circadian Rhythm during the whole recording period (the days are isoluated by dashed lines)
% 3. Average Circadian Rhythm in 24 hours
% Besides, you will find the output "info" contains all the useful
% infomation of the data.
% info: a struct that contains all the useful information of the good
% insect data. it has 6 fields:
% info.names: names of the good files, contained in cells;
% info.time: occurrence time of the good files, contained in cells, each cell is a vector [YYYY MM DD HH MM SS];
% info.mainfreq: winbeat frequency of the good files, contained in a vector;
% info.humidity: humidity of the good files, contained in a vector;
% info.pressure: pressure of the good files, contained in a vector;
% info.temperature: temperature of the good files, contained in a vector;
%
% Inputs:
% d: directory that includes t code he .csv files
% interval: interval used to smooth the data, for example 10 means 10 mins
% timeadjust(optional): the time adjust, for example, for PST input -7
% dawn(optional): dawn time(local time). E.g. 0600 means 6am
% dusk(optional): dusk time(local time). E.g. 1700 means 5pm
% starttimestr(optional): starting time of recording. You can ignore this input if the
% recording in d is continuous. The code will automatically figure it
% out. You can also input format 'YYYYMMDDHHMM'
% endtimestr(optional): end time of recording(optional) Similar as starttimestr
%
% Example input:
% >> info=analyzedata_csv('9June\9June\7.14',5,-7,0700,1800);
%
% Written by Yan Zhu
%=========================================================================%


function info=analyzedata_csv(d,interval,timeadjust,dawn,dusk,starttimestr,endtimestr)

threshold=0.85; %increase this value if you think there are lots of false positives. Decrease this value if you think there are a lot of false negatives.
%Set threshold to 0 if you don't want to filter the signals.
files=dir(d);
filenames={files.name};
filenames=sort(filenames);

L=1440; %1440 mins

%initialization
occurrence=zeros(1,L);
curstarttime=[9999 12 31 23 59 59];
curendtime=[1 1 1 0 0 0];
if (~exist('timeadjust'))
    timeadjust=0;
end
if (~exist('starttimestr')) %automatically find start and end time if they don't exist
for i=1:length(filenames)
    if (mod(i,1000)==0)
        fprintf('current file: %f\n', i/length(filenames));
    end
    filename=filenames{i};
    [pathstr,name,ext] = fileparts(filename);
    if (strcmpi(ext,'.csv'))
        fileID = fopen(fullfile(d,filename));
        length_each_file=1024;
        tmp=textscan(fileID,'%s\n',length_each_file);
        laststring=fgets(fileID);
        fclose(fileID);
        datainfo=regexp(laststring,'\d+\.?\d+','match');
        origtime=[str2double(['20',datainfo{1}]) str2double(datainfo{2}) str2double(datainfo{3}) str2double(datainfo{4}) str2double(datainfo{5}) str2double(datainfo{6})];
        [year month day hour minute second]=datevec(addtodate(datenum(origtime),timeadjust,'hour'));
        curtimevec=[year month day hour minute second];
        if etime(curtimevec,curstarttime)<0
            curstarttime=curtimevec;
        end
        if etime(curtimevec,curendtime)>0
            curendtime=curtimevec;
        end
    end
end
else
curstarttime=[str2num(starttimestr(1:4)) str2num(starttimestr(5:6)) str2num(starttimestr(7:8)) str2num(starttimestr(9:10)) str2num(starttimestr(11:12)) str2num(starttimestr(13:14))]
curendtime=[str2num(endtimestr(1:4)) str2num(endtimestr(5:6)) str2num(endtimestr(7:8)) str2num(endtimestr(9:10)) str2num(endtimestr(11:12)) str2num(starttimestr(13:14))]
end
curstarttime
curendtime
duration=etime(curendtime,curstarttime)/60/60/24;
display(['Duration: ',num2str(duration),' days.']);
daydiff=etime([curendtime(1:3) 0 0 0],[curstarttime(1:3) 0 0 0])/60/60/24;
totaloccurrence=zeros(1,(daydiff+1)*1440);
todivide=repmat(daydiff,1,1440);
startmin=curstarttime(4)*60+curstarttime(5)+1;
endmin=curendtime(4)*60+curendtime(5)+1;
if startmin>endmin
    todivide((endmin+1):(startmin-1))=daydiff-1;
else
    todivide(startmin:endmin)=daydiff+1;
end
allfreq=[];
alltemp=[];
allhumidity=[];
allpressure=[];
allnames={};
alltime={};
totalfilenum=0;
for i=1:length(filenames)
    if (mod(i,1000)==0)
        fprintf('current file: %f\n', i/length(filenames));
    end
    filename=filenames{i};
    [pathstr,name,ext] = fileparts(filename);
    if (strcmpi(ext,'.csv'))
        totalfilenum=totalfilenum+1;
        fileID = fopen(fullfile(d,filename));
        length_each_file=1024;
        tmp=textscan(fileID,'%s\n',length_each_file);
        laststring=fgets(fileID);
        fclose(fileID);
        datainfo=regexp(laststring,'\d+\.?\d+','match');
        origtime=[str2double(['20',datainfo{1}]) str2double(datainfo{2}) str2double(datainfo{3}) str2double(datainfo{4}) str2double(datainfo{5}) str2double(datainfo{6})];
        [year month day hour minute second]=datevec(addtodate(datenum(origtime),timeadjust,'hour'));
        temperature=str2double(datainfo{7});
        pressure=str2double(datainfo{8});
        humidity=str2double(datainfo{9});
        
        curtimevec=[year month day hour minute second];
        
        if etime(curtimevec,curstarttime)>=0 && etime(curtimevec,curendtime)<=0 %only consider the instances inbetween starttime and endtime
            occurrence(hour*60+minute+1)= occurrence(hour*60+minute+1)+1;
            totalmin=floor(etime(curtimevec,[curstarttime(1:3) 0 0 0])/60)+1;
            totaloccurrence(totalmin)=totaloccurrence(totalmin)+1;
            tmp=tmp{1};
            s=cellfun(@str2num,tmp(1:length_each_file));
            s=s-mean(s);
            s=s/max(abs(s));
            fs=8000;
            spect = time2spect(s);
            mainfreq=getMainFreq(spect,fs);
            if mainfreq>100 && mainfreq<2500 && CalculateXYZ(spect,fs,mainfreq)>threshold
                allnames=[allnames filename];
                alltime=[alltime curtimevec];
                allfreq=[allfreq mainfreq];
                allhumidity=[allhumidity humidity];
                allpressure=[allpressure pressure];
                alltemp=[alltemp temperature];
            end
        end
    end
end
info.names=allnames;
info.time=alltime;
info.mainfreq=allfreq;
info.humidity=allhumidity;
info.pressure=allpressure;
info.temperature=alltemp;
display(['Found ',num2str(length(allfreq)),' good Signals out of ',num2str(totalfilenum),' files.']);
figure;
[counts curcenters]=hist(allfreq,0:10:1000);
bar(curcenters,counts);
xlabel('Frequency(Hz)');
ylabel('count');
title(['Wingbeat Frequency Distribution of ',num2str(length(allfreq)),' Good Signals']);

avgoccurrence=occurrence./todivide;
avgoccurrence(occurrence==0)=0;
%save([d '_circadian_rhythm_minute'],'avgoccurrence','totaloccurrence','curstarttime','curendtime');

atfront=floor(interval/2);
atback=interval-atfront-1;

tempoccur=[0 avgoccurrence((1440-atfront+1):1440) avgoccurrence avgoccurrence(1:atback)];
sumoccur=cumsum(tempoccur);
s_avgoccurrence=(sumoccur((interval+1):length(sumoccur))-sumoccur(1:1440))/interval;

figure;
plot((1:length(totaloccurrence))/60,totaloccurrence);
maxoccurrence=max(totaloccurrence);
hold on;
dividelines=24:24:(length(totaloccurrence)/60);
for i=1:length(dividelines)
    plot([dividelines(i), dividelines(i)],[0, maxoccurrence],'k--');
end
xlabel('hour');
ylabel('occurrence');
set(gca,'XTick',dividelines);
title('General Circadian Rhythm');

figure;
plot((0:1439)/60,s_avgoccurrence);
xlabel('hour');
ylabel('average occurrence/day');
title('Circadian Rhythm');
if (exist('dawn') && exist('dusk'))
    hold on;
    dawnmin=((floor(dawn/100)*60+mod(dawn,100)))/60;
    duskmin=((floor(dusk/100)*60+mod(dusk,100)))/60;
    yvec=ylim;
    %dawn is shown in a red line
    %dust is shown in a black line
    plot([dawnmin dawnmin],yvec,'r');ylim(yvec);
    plot([duskmin duskmin],yvec,'k');ylim(yvec);
end
%dawnstr=sprintf('%04d', dawn);
%duskstr=sprintf('%04d', dusk);
%title(['Dawn: ', dawnstr(1:2),':', dawnstr(3:4),',Dusk: ', duskstr(1:2), ':', dawnstr(3:4)]);
%save([d '_circadian_rhythm_oneday_' num2str(interval) 'minute'],'avgoccurrence');
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

    