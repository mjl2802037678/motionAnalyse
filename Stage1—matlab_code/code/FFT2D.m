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
% %ʹ�õ���һ��Frame�źţ�һ��Iһ��Q
% 
% 
% for n=1:M*N*RX_NUM*TX_NUM
%     %����������8���ߣ�32��chirp��256�����㡣��ʵ�ֱ��
%     radar_cube0_re(n)=radar_cube0(2*n-1);
%     radar_cube0_im(n)=radar_cube0(2*n);
% end
%  
% din=radar_cube0_re+j*radar_cube0_im;%���в����㸴��

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
%%reshape������


data_2D=reshape(din,[N M*RX_NUM*TX_NUM])';
figure;mesh(abs(data_2D));
%���figure1��256�������㣨rangeBin�����ᣬ����256��8������32��chirp��
 
for n=1:M
    data_RX1_TX1(n,:) = data_2D( 1+4*(n-1) , :);
    data_RX2_TX1(n,:) = data_2D( 2+4*(n-1) , :);
    data_RX3_TX1(n,:) = data_2D( 3+4*(n-1) , :);
    data_RX4_TX1(n,:) = data_2D( 4+4*(n-1) , :);
    %��n��chirpʱ������RX���FFT�����ݡ�data_RX1_TX1��32��256��32��chirp��256�������㣨FFT��
end
 
for n=1:M
    data_RX1_TX2(n,:) = data_2D( 65+4*(n-1) , :);
    data_RX2_TX2(n,:) = data_2D( 66+4*(n-1) , :);
    data_RX3_TX2(n,:) = data_2D( 67+4*(n-1) , :);
    data_RX4_TX2(n,:) = data_2D( 68+4*(n-1) , :);
end



 
figure;mesh(abs(data_RX1_TX1));
%�ڶ���figure��RX1����chirp��FFT������32��rangeͼ


A=8+8*j;
avg=(sum(data_RX1_TX1)+A)/M;%FFT���32��chirp��ƽ��
for n=1:M
    data_m_RX1_TX1(n,:)=data_RX1_TX1(n,:)-avg;
end
%ȥֱ��������ȥ����̬�Ӳ���
%����Ǿ�̬���壬��ô��range��ÿ��chirp��ֵһ��������data_m_RX1_TX1��range��Ϊ0
%�����̬���壬��range��ÿ��chirp��λ�仯�����Լ�ȥ��������
figure;mesh((abs(data_m_RX1_TX1)));%����תΪdB


window_2D=hanning(M);
for n=1:N
    data_f_RX1_TX1(:,n)=fft(data_m_RX1_TX1(:,n).*window_2D);
end
%��һ������RX1��ÿ��range�Ͻ���һ�μӴ���fft

f=Fs/(N-1)*(0:N-1);
t=f/k;
r=c*t/2;
f_2D=PRF/(M-1)*(0:(M-1));
v=f_2D*lamda/2;
figure;mesh(r,v,(abs(data_f_RX1_TX1)));
title('��ά�ֲ�ͼ');axis tight;
xlabel('����/m','FontSize',12);ylabel('�ٶ�/m/s','FontSize',12);zlabel('�źŷ��ȣ�����ֵ��','FontSize',12);