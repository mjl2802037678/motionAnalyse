

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
PRF=1/PRT;

data_per_frame=cell(1,numFrames);
data_per_frame=radarCube.data;%radarCube��1D FFT���


%% �˴��ǽ�����chirp�ֿ���ÿ��RX����3*90��chirp
for frame=1:numFrames
%% ���frame
data_2D=data_per_frame{frame};%���data_2D��δFFT��
data_RX=zeros(numChirps,numSamples);

selectedRX=0;
for i=1:numChirps
    rx=(i-1)*3+1;
    data_RX(i,:)=data_2D(rx,selectedRX,:);
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

N=numSamples;
M=numChirps;
f=Fs/N*(0:N-1);
t=f/k;
%% ��άͼ
% r=c*t/2;
% left=ceil((M-1)/2);
% f_2D=PRF/M*(-left:left-1);
% v=f_2D*lamda/2;
% f1=pcolor(r,v,abs(data_f_RX1_TX1));
% title('��ά�ֲ�ͼ');axis tight;
% xlabel('����/m','FontSize',12);ylabel('�ٶ�/m/s','FontSize',12);zlabel('�źŷ��ȣ�����ֵ��','FontSize',12);    

%% 3Dͼ
r=c*t/2;
left=ceil((M-1)/2);
f_2D=PRF/M*(-left:left-1);
v=f_2D*lamda/2;
f1=mesh(r,v,(abs(data_f_RX1_TX1)));
title('3D�ֲ�ͼ');axis tight;
xlabel('����/m','FontSize',12);ylabel('�ٶ�/m/s','FontSize',12);zlabel('�źŷ��ȣ�����ֵ��','FontSize',12);
pause(0.25);
end
 


  
    
    
    
    
    
    
    