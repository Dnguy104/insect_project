function [ data  ] = insect_data(  )
        %folders = ["ten_classes_clean_dataset/aedes_female", "ten_classes_clean_dataset/aedes_male", "ten_classes_clean_dataset/fuit_flies", "ten_classes_clean_dataset/house_flies", "ten_classes_clean_dataset/quinx_female", "ten_classes_clean_dataset/quinx_male", "ten_classes_clean_dataset/stigma_female", "ten_classes_clean_dataset/stigma_male", "ten_classes_clean_dataset/tarsalis_female", "ten_classes_clean_dataset/tarsalis_male"];
            fs = 8000;
            length_each_file=1024;

        %srcFolder = 'ten_classes_clean_dataset/tarsalis_male';
        srcFolder = '9.22.17_D.Suz_30C_Males_N=60_Young_Good';
        files = dir(fullfile(srcFolder, '*.csv'));
        a=dir([srcFolder '/*.csv']);
        out=size(a,1);
        
            fileID = fopen(fullfile(srcFolder,files(1).name));
            tmp=textscan(fileID,'%s\n',length_each_file);
            fclose(fileID);
            tmp=tmp{1};
            s=cellfun(@str2num,tmp(1:length_each_file));
            data = s';
        
        for j = 2:out
            fileID = fopen(fullfile(srcFolder,files(j).name));

            tmp=textscan(fileID,'%s\n',length_each_file);
            tmp=tmp{1};
            files(j).name
            size(tmp)
            s=cellfun(@str2num,tmp(1:length_each_file));
            
            data = [ data ; s'];
            %disp(size(data));
            fclose(fileID);
        end;
        
        
end

