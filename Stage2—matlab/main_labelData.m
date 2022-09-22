
%% 只能一个file，一个file搞，不能整个文件夹

%% 每次必须修改所有参数
dataFile="D:\Minjl\8.24\head1_qian2ci.mat";%原文件D:\Minjl\4.5头扫描\头端雷达\大幅头动3次adc_data.mat
destinationDir='D:\Minjl\8.24\头动\';%对应运动
% startCount=0;%每个文件夹中文件起始下标
selRange=24;%不同部位，不同range，11，12, 16，23

%% 主体
indexFile='D:\运动识别课题\阶段三：目标姿势分析\matlab\index.txt';%这个固定不变
global dataFileDir;
global dataCount;
dataFileDir=destinationDir;
dataCount=startCount;
load(dataFile);
plot_dopplerTime(radarCube,selRange);
[startFrame,endFrame]=textread(indexFile,'%u%u');%debug后根据图像，更改文件中frame
saveData(startFrame,endFrame);
close all;

startCount=startCount+length(startFrame)
clearvars -except startCount;
function saveData(startFrame,endFrame)
    global data_per_frame;
    global dataFileDir;
    global dataCount;
    for i=1:length(startFrame)
        startIndex=startFrame(i);
        endIndex=endFrame(i);
        radarCubeData=cell(1,endIndex-startIndex+1);
        for index=startIndex:endIndex
            radarCubeData{index-startIndex+1} = data_per_frame{index};
        end
        dataFileName=[dataFileDir '\' num2str(dataCount) '.mat'];
        dataCount=dataCount+1;
        save (dataFileName, 'radarCubeData', '-v7.3');%每次运动存一个数据
    end
end

function plot_dopplerTime(radarCube,selRange)
    %% 参数设置
%     selRange=12;
    global data_per_frame;
%     global radarCube;
    numSamples=radarCube.rfParams.numRangeBins;%采样点数128
    numChirps=radarCube.rfParams.numDopplerBins;%一个frame中chirp数90
    numTx=radarCube.dim.numChirps/numChirps;%3个发射天线
    numFrames=radarCube.dim.numFrames;%总共frame个数
    data_per_frame=radarCube.data;%radarCube是1D FFT后的
    selectedRX=1;
    window_2D=hanning(numChirps);
    frameDatas=zeros(numChirps,numFrames);
    
%     frameDatas1=zeros(numChirps,numFrames);%测试两个rangeBin放一起
    data_m_RX1_TX1=zeros(numChirps,numSamples);
    data_RX=zeros(numChirps,numSamples);
    for frameIdx=1:numFrames
        %% 逐个frame
        data_2D=data_per_frame{frameIdx};%这个data_2D是未FFT的
        for i=1:numChirps
            rx=(i-1)*numTx+1;
            data_RX(i,:)=data_2D(rx,selectedRX,:);
        end
        data_RX1_TX1=data_RX;%TX1和RX1的，共90chirp*128ADCSample
        A=8+8*i;
        avg=(sum(data_RX1_TX1)+A)/numChirps;
        for n=1:numChirps
            data_m_RX1_TX1(n,:)=data_RX1_TX1(n,:)-avg;
        end
        frameDatas(:,frameIdx)=abs(fftshift(fft(data_m_RX1_TX1(:,selRange).*window_2D)));
%         frameDatas1(:,frameIdx)=abs(fftshift(fft(data_m_RX1_TX1(:,28).*window_2D)));
    end
    times=(0:numFrames-1);
    v=(-63:64);
%     f1=mesh(times,v,([frameDatas,frameDatas1]));
%     frameDatas= suppress_noise(frameDatas);
    f1=mesh(times,v,frameDatas);
    colorbar;
end



function frameDatas= suppress_noise(frameDatas)
    [m,n]=size(frameDatas);
    for i=1:m
        for j=1:n
            if db(frameDatas(i,j))<60
                frameDatas(i,j)=0;
            else
                frameDatas(i,j)=db(frameDatas(i,j));
            end
        end
    end
end
    
                

%% 测试，是否截取保存正确
% numSamples=128;
% numChirps=128;
% numTx=2;
% numFrames=length(radarCubeData)
% selectedRX=1;
% selRange=11;
% window_2D=hanning(numChirps);
% frameDatas=zeros(numChirps,numFrames);
% data_m_RX1_TX1=zeros(numChirps,numSamples);
% data_RX=zeros(numChirps,numSamples);
% for frameIdx=1:numFrames
%     %% 逐个frame
%     data_2D=radarCubeData{frameIdx};%这个data_2D是未FFT的
%     for i=1:numChirps
%         rx=(i-1)*numTx+1;
%         data_RX(i,:)=data_2D(rx,selectedRX,:);
%     end
%     data_RX1_TX1=data_RX;%TX1和RX1的，共90chirp*128ADCSample
%     A=8+8*i;
%     avg=(sum(data_RX1_TX1)+A)/numChirps;
%     for n=1:numChirps
%         data_m_RX1_TX1(n,:)=data_RX1_TX1(n,:)-avg;
%     end
%     frameDatas(:,frameIdx)=abs(fftshift(fft(data_m_RX1_TX1(:,selRange).*window_2D)));
% end
% times=(0:numFrames-1);
% v=(-63:64);
% f1=mesh(times,v,(frameDatas));

