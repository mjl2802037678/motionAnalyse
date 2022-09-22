
setupJsonFileName='D:\Minjl\3.4\1.setup.json';
setupJSON = jsondecode(fileread(setupJsonFileName));
binFilePath = setupJSON.capturedFiles.fileBasePath;
namelist = dir([binFilePath '\*.bin']); % ��ȡ�ļ���������.bin�ļ�
len = length(namelist);
for i = 1:len
    file_name=namelist(i).name; % ��ȡ�ļ���
    fullPath = [binFilePath '\' file_name];%�ļ�����
%         binFileName{idx} = strcat(binFilePath, '\', setupJSON.capturedFiles.files(idx).processedFileName);
    binFileName{idx} = fullPath;
    rawDataReader(setupJsonFileName,'adcData',binFileName, file_name(1:end-4), 0);
end