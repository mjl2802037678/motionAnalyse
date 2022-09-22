
%% ֻ��һ��file��һ��file�㣬���������ļ���

%% ÿ�α����޸����в���
dataFile='D:\Minjl\4.29\�Լ���\�Ҽ綯adc_data.mat';%ԭ�ļ�D:\Minjl\4.5ͷɨ��\ͷ���״�\���ͷ��3��adc_data.mat
selRange=12;%��ͬ��λ����ͬrange��11��12, 16��23

%% ����
indexFile='D:\�˶�ʶ�����\�׶�����Ŀ�����Ʒ���\matlab\Version2\index.txt';%����̶�����
load(dataFile);
plot_dopplerTime(radarCube,selRange);
[startFrame,endFrame]=textread(indexFile,'%u%u');%debug�����ͼ�񣬸����ļ���frame
% saveData(startFrame,endFrame);
selStartFrame=startFrame(1);
selEndFrame=endFrame(1);
plot_RDImage_selFrames(radarCube,selStartFrame,selEndFrame);
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
        save (dataFileName, 'radarCubeData', '-v7.3');%ÿ���˶���һ������
    end
end

function plot_dopplerTime(radarCube,selRange)
    %% ��������
    global data_per_frame;
    numSamples=radarCube.rfParams.numRangeBins;%��������128
    numChirps=radarCube.rfParams.numDopplerBins;%һ��frame��chirp��90
    numTx=radarCube.dim.numChirps/numChirps;%3����������
    numFrames=radarCube.dim.numFrames;%�ܹ�frame����
    data_per_frame=radarCube.data;%radarCube��1D FFT���
    selectedRX=1;
    window_2D=hanning(numChirps);
    frameDatas=zeros(numChirps,numFrames);
    
%     frameDatas1=zeros(numChirps,numFrames);%��������rangeBin��һ��
    data_m_RX1_TX1=zeros(numChirps,numSamples);
    data_RX=zeros(numChirps,numSamples);
    for frameIdx=1:numFrames
        %% ���frame
        data_2D=data_per_frame{frameIdx};%���data_2D��δFFT��
        for i=1:numChirps
            rx=(i-1)*numTx+1;
            data_RX(i,:)=data_2D(rx,selectedRX,:);
        end
        data_RX1_TX1=data_RX;%TX1��RX1�ģ���90chirp*128ADCSample
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

end

%% plot����frame��RDͼ
function plot_RDImage_selFrames(radarCube,selStartFrame,selEndFrame)
    %% ��������
    global data_per_frame;
    numSamples=radarCube.rfParams.numRangeBins;%��������128
    numChirps=radarCube.rfParams.numDopplerBins;%һ��frame��chirp��90
    numTx=radarCube.dim.numChirps/numChirps;%3����������
    numFrames=radarCube.dim.numFrames;%�ܹ�frame����
    data_per_frame=radarCube.data;%radarCube��1D FFT���
    selectedRX=1;
    window_2D=hanning(numChirps);
    frameDatas=zeros(numChirps,numFrames);
    data_m_RX1_TX1=zeros(numChirps,numSamples);
    data_RX=zeros(numChirps,numSamples);
    
    x_range=(0:numChirps-1);
    y_doppler=(-63:64);
    for frameIdx=selStartFrame:selEndFrame
        %% ���frame
        data_2D=data_per_frame{frameIdx};%���data_2D��δFFT��
        for i=1:numChirps
            rx=(i-1)*numTx+1;
            data_RX(i,:)=data_2D(rx,selectedRX,:);
        end
        data_RX1_TX1=data_RX;%TX1��RX1�ģ���90chirp*128ADCSample
        A=8+8*i;
        avg=(sum(data_RX1_TX1)+A)/numChirps;
        for n=1:numChirps
            data_m_RX1_TX1(n,:)=data_RX1_TX1(n,:)-avg;
        end
        
        figure;
        RDData_perFrame=zeros(numChirps,numChirps);
        for rangeIdx=1:numChirps
            RDData_perFrame(:,rangeIdx)=abs(fftshift(fft(data_m_RX1_TX1(:,rangeIdx).*window_2D)));
        end
        f1=mesh(x_range,y_doppler,RDData_perFrame);
        title(frameIdx);
  
    end
%     f1=mesh(times,v,([frameDatas,frameDatas1]));
%     frameDatas= suppress_noise(frameDatas);
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
    
                

%% ���ԣ��Ƿ��ȡ������ȷ
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
%     %% ���frame
%     data_2D=radarCubeData{frameIdx};%���data_2D��δFFT��
%     for i=1:numChirps
%         rx=(i-1)*numTx+1;
%         data_RX(i,:)=data_2D(rx,selectedRX,:);
%     end
%     data_RX1_TX1=data_RX;%TX1��RX1�ģ���90chirp*128ADCSample
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
