
%% ����setupJson�ļ�·�����ʹ�ת��.bin�ļ�Ŀ¼��
%% ·�����������ģ������������˵��setup.json�ļ����ݴ���. ����֮ǰ��1.setup.json����

%mmwaveJSon�У�frame��Ŀ����ν�����Զ����á�����chirp��profile�Ȳ���������ȷ
% main_getMat('D:\Minjl\1.setup.json','D:\Minjl\4.26\����')

function main_getMat(setupJsonFileName,binFileDir)
%     setupNamelist = dir([jsonFileDir '\*.setup.json']);
%     setup_file_name=setupNamelist(1).name;
%     setupJsonFileName = [jsonFileDir '\' setup_file_name];
    
    namelist = dir([binFileDir '\*.bin']); % ��ȡ�ļ���������.bin�ļ�
    len = length(namelist)
    for i = 1:len
        file_name=namelist(i).name; % ��ȡ�ļ���
        fullPath = [binFileDir '\' file_name];%�ļ�����
        mat_file_path=[binFileDir '\' file_name(1:end-4) '.mat'];%����ȡ���radarCube����ԭ���ļ���
        binFileName{1} = fullPath;
        rawDataReader(setupJsonFileName,binFileName,'rawData', mat_file_path, 0);
    %     rawDataReader(setupJsonFileName,binFileName, rawDataFileName, radarCubeDataFileName, debugPlot)
        clearvars -except setupJsonFileName binFileDir namelist len i
    end
end


