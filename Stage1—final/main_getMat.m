% 
% %% 只需要更改setupJsonFileName，位置即可；文件里面的capturedFiles.file不需要更改
% %% 更改binFilePath，到.bin文件所在文件夹

%% 只需要更改setupJsonFileName，位置即可；文件里面的capturedFiles.file不需要更改
%% 更改binFilePath，到.bin文件所在文件夹
function main_getMat(binFilePath)
    setupNamelist = dir([binFilePath '\*.setup.json']);
    setup_file_name=setupNamelist(1).name;
    setupJsonFileName = [binFilePath '\' setup_file_name];
    
    namelist = dir([binFilePath '\*.bin']); % 获取文件夹下所有.bin文件
    len = length(namelist)
    for i = 1:len
        file_name=namelist(i).name; % 获取文件名
        fullPath = [binFilePath '\' file_name];%文件名称
        mat_file_path=[binFilePath '\' file_name(1:end-4)];%将提取后的radarCube存在原来文件夹
        binFileName{1} = fullPath;
        rawDataReader(setupJsonFileName,binFileName,'rawData', mat_file_path, 0);
    %     rawDataReader(setupJsonFileName,binFileName, rawDataFileName, radarCubeDataFileName, debugPlot)
        clearvars -except setupJsonFileName binFilePath namelist len i
    end
end


