
%% 输入setupJson文件路径，和待转化.bin文件目录。
%% 路径可以有中文，如果解析出错，说明setup.json文件内容错误. 复制之前的1.setup.json覆盖

%mmwaveJSon中，frame数目无所谓，会自动设置。但是chirp，profile等参数必须正确
% main_getMat('D:\Minjl\1.setup.json','D:\Minjl\4.26\王晗')

function main_getMat(setupJsonFileName,binFileDir)
%     setupNamelist = dir([jsonFileDir '\*.setup.json']);
%     setup_file_name=setupNamelist(1).name;
%     setupJsonFileName = [jsonFileDir '\' setup_file_name];
    
    namelist = dir([binFileDir '\*.bin']); % 获取文件夹下所有.bin文件
    len = length(namelist)
    for i = 1:len
        file_name=namelist(i).name; % 获取文件名
        fullPath = [binFileDir '\' file_name];%文件名称
        mat_file_path=[binFileDir '\' file_name(1:end-4) '.mat'];%将提取后的radarCube存在原来文件夹
        binFileName{1} = fullPath;
        rawDataReader(setupJsonFileName,binFileName,'rawData', mat_file_path, 0);
    %     rawDataReader(setupJsonFileName,binFileName, rawDataFileName, radarCubeDataFileName, debugPlot)
        clearvars -except setupJsonFileName binFileDir namelist len i
    end
end


