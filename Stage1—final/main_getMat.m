% 
% %% ֻ��Ҫ����setupJsonFileName��λ�ü��ɣ��ļ������capturedFiles.file����Ҫ����
% %% ����binFilePath����.bin�ļ������ļ���

%% ֻ��Ҫ����setupJsonFileName��λ�ü��ɣ��ļ������capturedFiles.file����Ҫ����
%% ����binFilePath����.bin�ļ������ļ���
function main_getMat(binFilePath)
    setupNamelist = dir([binFilePath '\*.setup.json']);
    setup_file_name=setupNamelist(1).name;
    setupJsonFileName = [binFilePath '\' setup_file_name];
    
    namelist = dir([binFilePath '\*.bin']); % ��ȡ�ļ���������.bin�ļ�
    len = length(namelist)
    for i = 1:len
        file_name=namelist(i).name; % ��ȡ�ļ���
        fullPath = [binFilePath '\' file_name];%�ļ�����
        mat_file_path=[binFilePath '\' file_name(1:end-4)];%����ȡ���radarCube����ԭ���ļ���
        binFileName{1} = fullPath;
        rawDataReader(setupJsonFileName,binFileName,'rawData', mat_file_path, 0);
    %     rawDataReader(setupJsonFileName,binFileName, rawDataFileName, radarCubeDataFileName, debugPlot)
        clearvars -except setupJsonFileName binFilePath namelist len i
    end
end


