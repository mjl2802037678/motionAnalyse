%DCA1000 With x16xx and IWR6843 MATLAB Example
%% 使用的文件是adc_data.bin文件
%% 一开始采集的adc_data_raw_0.bin，然后点击PostProc(等同packet_reorder_zerofill.exe程序)，变成adc_data.bin文件


function retVal = interpretBin(fileName)

    %% global variables
    % change based on sensor config
    numADCSamples = 128; % number of ADC samples per chirp
    numADCBits = 16; % number of ADC bits per sample
    numRX = 3*4; % number of receivers
    numLanes = 2; % do not change. number of lanes is always 2
    isReal = 0; % set to 1 if real only data, 0 if complex data0

    %% 因为MIMO是TDM，根据虚拟阵列数设置numRX=8,12

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
    fileSize = size(adcData, 1);%整个file中数据量，4个天线的

    % real data reshape, filesize = numADCSamples*numChirps
    if isReal
        numChirps = fileSize/numADCSamples/numRX;
        LVDS = zeros(1, fileSize);
        %create column for each chirp
        LVDS = reshape(adcData, numADCSamples*numRX, numChirps);
        %each row is data from one chirp
        LVDS = LVDS.';
    
    %% 此处正式开始
    else
        % for complex data
        % filesize = 2 * numADCSamples*numChirps
        numChirps = fileSize/2/numADCSamples/numRX; %TX发了多个个chirp
        LVDS = zeros(1, fileSize/2); %总共用了多个个lanes。2个lanes能存下来2个复sample信号。
        %LVDS一个对一个sample复信号

        %combine real and imaginary part into complex data
        %read in file: 2I is followed by 2Q
        %先Lane1 I（sample1、2），再Lane2 Q（sample1、2）

        counter = 1;%counter是生成的复信号sample
        for i=1:4:fileSize-1%i是右边小方块
            LVDS(1,counter) = adcData(i) + sqrt(-1)*adcData(i+2); 
            LVDS(1,counter+1) = adcData(i+1)+sqrt(-1)*adcData(i+3); 
            counter = counter + 2;
        end
        %LVDS是先存了第一个chirp的，RX1所有samples，然后RX2的
        % create column for each chirp
        LVDS = reshape(LVDS, numADCSamples*numRX, numChirps);%reshape的逻辑是先排位一整列，再下一列
        %each row is data from one chirp
        LVDS = LVDS.';
    end

    %organize data per RX
    adcData = zeros(numRX,numChirps*numADCSamples);
    for row = 1:numRX
        for i = 1: numChirps
            adcData(row, (i-1)*numADCSamples+1:i*numADCSamples) = LVDS(i, (row-1)*numADCSamples+1:row*numADCSamples);
            %每一行是一个RX，第一个chirp的所有ADCSample，第二个chirp的。。。
        end
    end
    % return receiver data
    retVal = adcData;
end