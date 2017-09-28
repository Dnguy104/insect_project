function [ data  ] = insect_data(  )
        %folders = ["ten_classes_clean_dataset/aedes_female", "ten_classes_clean_dataset/aedes_male", "ten_classes_clean_dataset/fuit_flies", "ten_classes_clean_dataset/house_flies", "ten_classes_clean_dataset/quinx_female", "ten_classes_clean_dataset/quinx_male", "ten_classes_clean_dataset/stigma_female", "ten_classes_clean_dataset/stigma_male", "ten_classes_clean_dataset/tarsalis_female", "ten_classes_clean_dataset/tarsalis_male"];


        srcFolder = 'ten_classes_clean_dataset/tarsalis_male';
        files = dir(fullfile(srcFolder, '*.wav'));
        y = [ files(:).name ]';
        
        fileID = audioread(fullfile(srcFolder,files(1).name));
        disp(size(fileID'));
        data = fileID';
        
        for j = 2:5000
            fileID = audioread(fullfile(srcFolder,files(j).name));
            
            data = [ data ; fileID'];
            disp(size(data));
        end;
        
        
end

