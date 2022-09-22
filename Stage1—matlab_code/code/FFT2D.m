% clc;clear all; close all;
%  
% load RadarCube_2D(4).dat
% radar_cube0=RadarCube_2D_4_;
%  
% c=3e8;
% fc=77e9;
% lamda=c/fc;
% Fs=5.209e6; %1642 max is 6.25Msps
% k=70e12;
% N=256;
% M=32;
% PRT=314.28e-6;PRF=1/PRT;
% RX_NUM=4;
% TX_NUM=2;
% %使用的是一个Frame信号，一个I一个Q
% 
% 
% for n=1:M*N*RX_NUM*TX_NUM
%     %将所有数据8天线，32个chirp，256采样点。虚实分别存
%     radar_cube0_re(n)=radar_cube0(2*n-1);
%     radar_cube0_im(n)=radar_cube0(2*n);
% end
%  
% din=radar_cube0_re+j*radar_cube0_im;%所有采样点复数

c=3e8;
lamda=5e-3;
Fs=5e6; %1642 max is 6.25Msps
k=117.2112e12;
N=128;
M=90;
PRT=310.8e-6;PRF=1/PRT;
RX_NUM=4;
TX_NUM=3;

%plot(abs(din));
din=radarCube.data{50};
%%reshape有问题


data_2D=reshape(din,[N M*RX_NUM*TX_NUM])';
figure;mesh(abs(data_2D));
%这个figure1是256个采样点（rangeBin）纵轴，横轴256是8个天线32个chirp的
 
for n=1:M
    data_RX1_TX1(n,:) = data_2D( 1+4*(n-1) , :);
    data_RX2_TX1(n,:) = data_2D( 2+4*(n-1) , :);
    data_RX3_TX1(n,:) = data_2D( 3+4*(n-1) , :);
    data_RX4_TX1(n,:) = data_2D( 4+4*(n-1) , :);
    %第n个chirp时候，天线RX存的FFT后数据。data_RX1_TX1是32×256，32个chirp，256个采样点（FFT后）
end
 
for n=1:M
    data_RX1_TX2(n,:) = data_2D( 65+4*(n-1) , :);
    data_RX2_TX2(n,:) = data_2D( 66+4*(n-1) , :);
    data_RX3_TX2(n,:) = data_2D( 67+4*(n-1) , :);
    data_RX4_TX2(n,:) = data_2D( 68+4*(n-1) , :);
end



 
figure;mesh(abs(data_RX1_TX1));
%第二个figure，RX1所有chirp，FFT后。所有32个range图


A=8+8*j;
avg=(sum(data_RX1_TX1)+A)/M;%FFT后的32个chirp和平均
for n=1:M
    data_m_RX1_TX1(n,:)=data_RX1_TX1(n,:)-avg;
end
%去直流分量，去掉静态杂波。
%如果是静态物体，那么该range上每个chirp的值一样，所以data_m_RX1_TX1该range上为0
%如果动态物体，该range上每个chirp相位变化，所以减去后会有起伏
figure;mesh((abs(data_m_RX1_TX1)));%能量转为dB


window_2D=hanning(M);
for n=1:N
    data_f_RX1_TX1(:,n)=fft(data_m_RX1_TX1(:,n).*window_2D);
end
%这一个天线RX1，每个range上进行一次加窗和fft

f=Fs/(N-1)*(0:N-1);
t=f/k;
r=c*t/2;
f_2D=PRF/(M-1)*(0:(M-1));
v=f_2D*lamda/2;
figure;mesh(r,v,(abs(data_f_RX1_TX1)));
title('二维分布图');axis tight;
xlabel('距离/m','FontSize',12);ylabel('速度/m/s','FontSize',12);zlabel('信号幅度（量化值）','FontSize',12);