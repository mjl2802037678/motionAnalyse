%DCA1000 With x16xx and IWR6843 MATLAB Example
%% ʹ�õ��ļ���adc_data.bin�ļ�
%% һ��ʼ�ɼ���adc_data_raw_0.bin��Ȼ����PostProc(��ͬpacket_reorder_zerofill.exe����)�����adc_data.bin�ļ�


function retVal = interpretBin(fileName)

    %% global variables
    % change based on sensor config
    numADCSamples = 128; % number of ADC samples per chirp
    numADCBits = 16; % number of ADC bits per sample
    numRX = 3*4; % number of receivers
    numLanes = 2; % do not change. number of lanes is always 2
    isReal = 0; % set to 1 if real only data, 0 if complex data0

    %% ��ΪMIMO��TDM��������������������numRX=8,12

    %% read file
    % read .bin file
    fid = fopen(fileName,'r');
    adcData = fread(fid, 'int16');

    % if 12 or 14 bits ADC per sample compensate for sign extension
    if numADCBits ~= 16
        l_max = 2^(numADCBits-1)-1;
        adcData(adcData > l_max) = adcData(adcData > l_max) - 2^numADCBits;
    end
    fclose(fid);
    fileSize = size(adcData, 1);%����file����������4�����ߵ�

    % real data reshape, filesize = numADCSamples*numChirps
    if isReal
        numChirps = fileSize/numADCSamples/numRX;
        LVDS = zeros(1, fileSize);
        %create column for each chirp
        LVDS = reshape(adcData, numADCSamples*numRX, numChirps);
        %each row is data from one chirp
        LVDS = LVDS.';
    
    %% �˴���ʽ��ʼ
    else
        % for complex data
        % filesize = 2 * numADCSamples*numChirps
        numChirps = fileSize/2/numADCSamples/numRX; %TX���˶����chirp
        LVDS = zeros(1, fileSize/2); %�ܹ����˶����lanes��2��lanes�ܴ�����2����sample�źš�
        %LVDSһ����һ��sample���ź�

        %combine real and imaginary part into complex data
        %read in file: 2I is followed by 2Q
        %��Lane1 I��sample1��2������Lane2 Q��sample1��2��

        counter = 1;%counter�����ɵĸ��ź�sample
        for i=1:4:fileSize-1%i���ұ�С����
            LVDS(1,counter) = adcData(i) + sqrt(-1)*adcData(i+2); 
            LVDS(1,counter+1) = adcData(i+1)+sqrt(-1)*adcData(i+3); 
            counter = counter + 2;
        end
        %LVDS���ȴ��˵�һ��chirp�ģ�RX1����samples��Ȼ��RX2��
        % create column for each chirp
        LVDS = reshape(LVDS, numADCSamples*numRX, numChirps);%reshape���߼�������λһ���У�����һ��
        %each row is data from one chirp
        LVDS = LVDS.';
    end

    %organize data per RX
    adcData = zeros(numRX,numChirps*numADCSamples);
    for row = 1:numRX
        for i = 1: numChirps
            adcData(row, (i-1)*numADCSamples+1:i*numADCSamples) = LVDS(i, (row-1)*numADCSamples+1:row*numADCSamples);
            %ÿһ����һ��RX����һ��chirp������ADCSample���ڶ���chirp�ġ�����
        end
    end
    % return receiver data
    retVal = adcData;
end