clear all;close all;clc;
N=256;         %采样点数
Fs=10e6;       %采样率
B=768e6;       %调频带宽
k=30e12;       %调频斜率
T=B/k;         %采样时间
c=3e8;  
din_re=load("one_chirp_data_real.dat");
din_im=load("one_chirp_data_imag.dat");
% figure;subplot(2,1,1);plot(din_re);
%        subplot(2,1,2);plot(din_im);
din=din_re+j*din_im;
figure;plot(abs(din));
% range_win = round(100*hamming(N));   %加海明窗
range_win = round(100*blackman(N));   %加布莱克曼窗
figure;plot(range_win);
data=din.*range_win;
figure;plot(abs(data)); 

yy=fft(din);
AY=abs(yy/N);
f=Fs/(N-1)*(0:N-1);
figure;plot(f,AY);
title('原始数据FFT');xlabel('频率/Hz');ylabel('幅值');

yy=fft(data);
AY=abs(yy/N);
% f=Fs/(N-1)*(0:N-1);
figure;plot(f,AY);
title('加窗后FFT');xlabel('频率/Hz');ylabel('幅值');



r=f*c/(2*k);
figure;plot(r,AY);
title('1D-FFT');xlabel('距离/m');ylabel('幅值');


