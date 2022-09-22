clear all;close all;clc;
N=256;         %��������
Fs=10e6;       %������
B=768e6;       %��Ƶ����
k=30e12;       %��Ƶб��
T=B/k;         %����ʱ��
c=3e8;  
din_re=load("one_chirp_data_real.dat");
din_im=load("one_chirp_data_imag.dat");
% figure;subplot(2,1,1);plot(din_re);
%        subplot(2,1,2);plot(din_im);
din=din_re+j*din_im;
figure;plot(abs(din));
% range_win = round(100*hamming(N));   %�Ӻ�����
range_win = round(100*blackman(N));   %�Ӳ���������
figure;plot(range_win);
data=din.*range_win;
figure;plot(abs(data)); 

yy=fft(din);
AY=abs(yy/N);
f=Fs/(N-1)*(0:N-1);
figure;plot(f,AY);
title('ԭʼ����FFT');xlabel('Ƶ��/Hz');ylabel('��ֵ');

yy=fft(data);
AY=abs(yy/N);
% f=Fs/(N-1)*(0:N-1);
figure;plot(f,AY);
title('�Ӵ���FFT');xlabel('Ƶ��/Hz');ylabel('��ֵ');



r=f*c/(2*k);
figure;plot(r,AY);
title('1D-FFT');xlabel('����/m');ylabel('��ֵ');


