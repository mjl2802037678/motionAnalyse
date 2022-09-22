
setupJsonFileName='D:\Minjl\3.4\1.setup.json';
setupJSON = jsondecode(fileread(setupJsonFileName));
binFilePath = setupJSON.capturedFiles.fileBasePath;
namelist = dir([binFilePath '\*.bin']); % 获取文件夹下所有.bin文件
len = length(namelist);
for i = 1:len
    file_name=namelist(i).name; % 获取文件名
    fullPath = [binFilePath '\' file_name];%文件名称
%         binFileName{idx} = strcat(binFilePath, '\', setupJSON.capturedFiles.files(idx).processedFileName);
    binFileName{idx} = fullPath;
    rawDataReader(setupJsonFileName,'adcData',binFileName, file_name(1:end-4), 0);
end