
%% 调用example程序，直接读取.bin文件dataSet和params，并1D-FFT生成radarCube
% rawDataReader('D:\Minjl\测试数据\急上急下\1.setup.json','adcData', 'radarCube', 0);
% load('radarCube.mat');

c=3e8;
f=radarCube.rfParams.startFreq*1e9%起始频率
lamda=c/f%5e-3
Fs=radarCube.rfParams.sampleRate*1e6 %5e6
k=radarCube.rfParams.freqSlope*1e12
numSamples=radarCube.rfParams.numRangeBins;%采样点数128
numChirps=radarCube.rfParams.numDopplerBins;%一个frame中chirp数90
RX_NUM=radarCube.dim.numRxChan;
TX_NUM=radarCube.dim.numChirps/numChirps;%3个发射天线
numFrames=radarCube.dim.numFrames;%总共frame个数
Vres=radarCube.rfParams.dopplerResolutionMps
PRT=lamda/(2*Vres*numChirps);%每个chirp持续时间310.8e-6
% PRT=lamda/(2*Vres*radarCube.dim.numChirps)%每个chirp持续时间310.8e-6/3
PRF=1/PRT;

data_per_frame=cell(1,numFrames);
data_per_frame=radarCube.data;%radarCube是1D FFT后的

%% 此处是将Chirp，三合一情况
% for frame=99:numFrames
% %% 逐个frame
% data_2D=data_per_frame{frame};%这个data_2D是未FFT的
% data_RX=zeros(numChirps,numSamples);
% selectedRX=1;
% 
% for i=1:numChirps
%     data_RX(i,:)=data_2D(1+(i-1)*3,selectedRX,:);
% end
% data_RX1_TX1=data_RX;%TX1和RX1的，共90chirp*128ADCSample
% 
% 
% avg=(sum(data_RX1_TX1))/numChirps;%FFT后的32个chirp和平均
% for n=1:numChirps
%     data_m_RX1_TX1(n,:)=data_RX1_TX1(n,:)-avg;
% end
% %去直流分量，去掉静态杂波。
% %如果是静态物体，那么该range上每个chirp的值一样，所以data_m_RX1_TX1该range上为0
% %如果动态物体，该range上每个chirp相位变化，所以减去后会有起伏
% 
% % f1=mesh(db(abs(data_m_RX1_TX1)));%能量转为dB
% window_2D=hanning(numChirps);
% for rangeBin=1:numSamples
%     data_f_RX1_TX1(:,rangeBin)=fft(data_m_RX1_TX1(:,rangeBin).*window_2D);
% end
% %data_f_RX1_TX1，dopplerBin*rangeBin
% 
% 
% %这一个天线RX1，每个range上进行一次加窗和fft
% N=numSamples;
% M=numChirps;
% f=Fs/N*(0:N-1);
% t=f/k;
% r=c*t/2;
% f_2D=PRF/M*(0:(M-1));
% v=f_2D*lamda/2;
% % v=0.0606*(0:(M-1));
% f1=mesh(r,v,(abs(data_f_RX1_TX1)));
% title('二维分布图');axis tight;
% xlabel('距离/m','FontSize',12);ylabel('速度/m/s','FontSize',12);zlabel('信号幅度（量化值）','FontSize',12);    
% pause(0.5);
% end
% % close all;  
    

%% 此处是将三个chirp分开，每个RX接收3*90个chirp
numChirps=90;
for frame=1:100
%% 逐个frame
data_2D=data_per_frame{frame};%这个data_2D是未FFT的
data_RX=zeros(numChirps,numSamples);
% data_SUMRX=zeros(numChirps,numSamples);
% 
% for selectedRX=1:4
selectedRX=2;
for i=1:90
    rx=(i-1)*2+1;
    data_RX(i,:)=data_2D(rx,selectedRX,:);
%     data_RX(i,:)=data_2D(rx,selectedRX,:)+data_2D(rx+1,selectedRX,:)+data_2D(rx+2,selectedRX,:);
end
data_RX1_TX1=data_RX;%TX1和RX1的，共90chirp*128ADCSample
A=8+8*i;
avg=(sum(data_RX1_TX1)+A)/numChirps;%FFT后的32个chirp和平均
for n=1:numChirps
    data_m_RX1_TX1(n,:)=data_RX1_TX1(n,:)-avg;
end
%去直流分量，去掉静态杂波。
%如果是静态物体，那么该range上每个chirp的值一样，所以data_m_RX1_TX1该range上为0
%如果动态物体，该range上每个chirp相位变化，所以减去后会有起伏

% f1=mesh(db(abs(data_m_RX1_TX1)));%能量转为dB
window_2D=hanning(numChirps);
for rangeBin=1:numSamples
    data_f_RX1_TX1(:,rangeBin)=fftshift(fft(data_m_RX1_TX1(:,rangeBin).*window_2D));
end
%data_f_RX1_TX1，dopplerBin*rangeBin
% data_SUMRX=data_SUMRX+data_f_RX1_TX1;
% end
% data_f_RX1_TX1=data_SUMRX/4;

%这一个天线RX1，每个range上进行一次加窗和fft
N=numSamples;
M=numChirps;
f=Fs/N*(0:N-1);
t=f/k;
r=c*t/2;
left=ceil((M-1)/2);
f_2D=PRF/M*(-left:left-1);
v=f_2D*lamda/2
% v=0.0606*(0:(M-1));
% f1=mesh(r,v,(abs(data_f_RX1_TX1)));
% v=0:(M-1);
% r=0:(N-1);
f1=pcolor(r,v,abs(data_f_RX1_TX1));
title('二维分布图');axis tight;
xlabel('距离/m','FontSize',12);ylabel('速度/m/s','FontSize',12);zlabel('信号幅度（量化值）','FontSize',12);    
pause(0.25);
end
% % close all;  
% %保存data_m_RX1_TX1为data_RX1TX1
 


  
    
    
    
    
    
    
    