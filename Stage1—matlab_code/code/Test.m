
%% ����example����ֱ�Ӷ�ȡ.bin�ļ�dataSet��params����1D-FFT����radarCube
% rawDataReader('D:\Minjl\��������\���ϼ���\1.setup.json','adcData', 'radarCube', 0);
% load('radarCube.mat');

c=3e8;
f=radarCube.rfParams.startFreq*1e9%��ʼƵ��
lamda=c/f%5e-3
Fs=radarCube.rfParams.sampleRate*1e6 %5e6
k=radarCube.rfParams.freqSlope*1e12
numSamples=radarCube.rfParams.numRangeBins;%��������128
numChirps=radarCube.rfParams.numDopplerBins;%һ��frame��chirp��90
RX_NUM=radarCube.dim.numRxChan;
TX_NUM=radarCube.dim.numChirps/numChirps;%3����������
numFrames=radarCube.dim.numFrames;%�ܹ�frame����
Vres=radarCube.rfParams.dopplerResolutionMps
PRT=lamda/(2*Vres*numChirps);%ÿ��chirp����ʱ��310.8e-6
% PRT=lamda/(2*Vres*radarCube.dim.numChirps)%ÿ��chirp����ʱ��310.8e-6/3
PRF=1/PRT;

data_per_frame=cell(1,numFrames);
data_per_frame=radarCube.data;%radarCube��1D FFT���

%% �˴��ǽ�Chirp������һ���
% for frame=99:numFrames
% %% ���frame
% data_2D=data_per_frame{frame};%���data_2D��δFFT��
% data_RX=zeros(numChirps,numSamples);
% selectedRX=1;
% 
% for i=1:numChirps
%     data_RX(i,:)=data_2D(1+(i-1)*3,selectedRX,:);
% end
% data_RX1_TX1=data_RX;%TX1��RX1�ģ���90chirp*128ADCSample
% 
% 
% avg=(sum(data_RX1_TX1))/numChirps;%FFT���32��chirp��ƽ��
% for n=1:numChirps
%     data_m_RX1_TX1(n,:)=data_RX1_TX1(n,:)-avg;
% end
% %ȥֱ��������ȥ����̬�Ӳ���
% %����Ǿ�̬���壬��ô��range��ÿ��chirp��ֵһ��������data_m_RX1_TX1��range��Ϊ0
% %�����̬���壬��range��ÿ��chirp��λ�仯�����Լ�ȥ��������
% 
% % f1=mesh(db(abs(data_m_RX1_TX1)));%����תΪdB
% window_2D=hanning(numChirps);
% for rangeBin=1:numSamples
%     data_f_RX1_TX1(:,rangeBin)=fft(data_m_RX1_TX1(:,rangeBin).*window_2D);
% end
% %data_f_RX1_TX1��dopplerBin*rangeBin
% 
% 
% %��һ������RX1��ÿ��range�Ͻ���һ�μӴ���fft
% N=numSamples;
% M=numChirps;
% f=Fs/N*(0:N-1);
% t=f/k;
% r=c*t/2;
% f_2D=PRF/M*(0:(M-1));
% v=f_2D*lamda/2;
% % v=0.0606*(0:(M-1));
% f1=mesh(r,v,(abs(data_f_RX1_TX1)));
% title('��ά�ֲ�ͼ');axis tight;
% xlabel('����/m','FontSize',12);ylabel('�ٶ�/m/s','FontSize',12);zlabel('�źŷ��ȣ�����ֵ��','FontSize',12);    
% pause(0.5);
% end
% % close all;  
    

%% �˴��ǽ�����chirp�ֿ���ÿ��RX����3*90��chirp
numChirps=90;
for frame=1:100
%% ���frame
data_2D=data_per_frame{frame};%���data_2D��δFFT��
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
data_RX1_TX1=data_RX;%TX1��RX1�ģ���90chirp*128ADCSample
A=8+8*i;
avg=(sum(data_RX1_TX1)+A)/numChirps;%FFT���32��chirp��ƽ��
for n=1:numChirps
    data_m_RX1_TX1(n,:)=data_RX1_TX1(n,:)-avg;
end
%ȥֱ��������ȥ����̬�Ӳ���
%����Ǿ�̬���壬��ô��range��ÿ��chirp��ֵһ��������data_m_RX1_TX1��range��Ϊ0
%�����̬���壬��range��ÿ��chirp��λ�仯�����Լ�ȥ��������

% f1=mesh(db(abs(data_m_RX1_TX1)));%����תΪdB
window_2D=hanning(numChirps);
for rangeBin=1:numSamples
    data_f_RX1_TX1(:,rangeBin)=fftshift(fft(data_m_RX1_TX1(:,rangeBin).*window_2D));
end
%data_f_RX1_TX1��dopplerBin*rangeBin
% data_SUMRX=data_SUMRX+data_f_RX1_TX1;
% end
% data_f_RX1_TX1=data_SUMRX/4;

%��һ������RX1��ÿ��range�Ͻ���һ�μӴ���fft
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
title('��ά�ֲ�ͼ');axis tight;
xlabel('����/m','FontSize',12);ylabel('�ٶ�/m/s','FontSize',12);zlabel('�źŷ��ȣ�����ֵ��','FontSize',12);    
pause(0.25);
end
% % close all;  
% %����data_m_RX1_TX1Ϊdata_RX1TX1
 


  
    
    
    
    
    
    
    