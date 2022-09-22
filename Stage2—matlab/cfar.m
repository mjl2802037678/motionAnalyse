clc;clear all; close all;
 
load D:\运动识别课题\阶段三：目标姿势分析\matlab\detmatrix(20201206).dat
detmatrix=detmatrix_20201206_;
 
c=3e8;
fc=77e9;
lamda=c/fc;
Fs=5.209e6; %1642 max is 6.25Msps
k=70e12;
N=256;
M=32;
PRT=314.28e-6;PRF=1/PRT;
RX_NUM=4;
TX_NUM=2; 
din=reshape(detmatrix,[M,N]);
for n=1:N
    din1(:,n)=fftshift(din(:,n));
end
din1=din1/2^8;
din1=2.^din1;
% din1=db(din1);
 
 
f=Fs/(N-1)*(0:N-1);
t=f/k;
r=c*t/2;
f_2D=linspace(-PRF/2,PRF/2-PRF/M,M);
v=f_2D*lamda/2;
figure;mesh(r,v,(din1));
title('二维分布图detmatrix');axis tight;
xlabel('距离/m','FontSize',12);ylabel('速度/m/s','FontSize',12);zlabel('信号幅度','FontSize',12);
 
 
guardlen=4;
noiselen=8;
Threshold=15;   %dB
const1=256*8*Threshold/6;
%col 38
din38=din1(:,38);
cut=[din38;din38;din38];
for c=M+1:M+M
    noise_sum(c)=0;
    noise_sum_right(c)=0;
    noise_sum_left(c)=0;
        for i=c+guardlen : c+noiselen+guardlen
            noise_sum_right(c)=cut(i)+noise_sum_right(c);
        end
        for i=c-guardlen : c-noiselen-guardlen
            noise_sum_left(c)=cut(i)+noise_sum_left(c);
        end
        noise_sum(c)=noise_sum_right(c)+noise_sum_left(c);
end
noise_avg1=noise_sum(M+1:M+M)/(noiselen*2);
VT=20*log10(noise_avg1)+Threshold*8;
% VT=noise_avg+const1;
figure;plot(v,20*log10(din38));hold on;
plot(v,VT);
 
for n=1:N
    dinn=din1(:,n);
    cut=[dinn;dinn;dinn];
    for c=M+1:M+M
        noise_sum(c)=0;
        noise_sum_right(c)=0;
        noise_sum_left(c)=0;
            for i=c+guardlen : c+noiselen+guardlen
                noise_sum_right(c)=cut(i)+noise_sum_right(c);
            end
            for i=c-guardlen : c-noiselen-guardlen
                noise_sum_left(c)=cut(i)+noise_sum_left(c);
            end
            noise_sum(c)=noise_sum_right(c)+noise_sum_left(c);
    end
    noise_avg(:,n)=noise_sum(M+1:M+M)/(noiselen*2);%没一列的cfar曲线
end
 
VT1=db(noise_avg)+Threshold*8;%对doppler维，所有range做cfar曲线，构成VT1矩阵
% VT=noise_avg+const1;
figure;mesh(r,v,db(din1));hold on;
surface(r,v,VT1,'EdgeColor','none');
xlabel('距离/m','FontSize',12);ylabel('速度/m/s','FontSize',12);zlabel('信号幅度','FontSize',12);
%%%%%%%%%%%%%%多普勒维CFAR结束%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
noiselen=4;
for m=1:M
    dinm=din1(m,:)';
    din00=zeros(1,n)';
    cut=[din00;dinm;din00]';
    for c=N+1:N+N
        noise_sum(c)=0;
        noise_sum_right(c)=0;
        noise_sum_left(c)=0;
            for i=c+guardlen : c+noiselen+guardlen
                noise_sum_right(c)=cut(i)+noise_sum_right(c);
            end
            for i=c-guardlen : c-noiselen-guardlen
                noise_sum_left(c)=cut(i)+noise_sum_left(c);
            end
            noise_sum(c)=noise_sum_right(c)+noise_sum_left(c);
    end
    noise_avg(m,:)=noise_sum(N+1:N+N)/(noiselen*2);
end
VT2=db(noise_avg)+Threshold*8;%range维也构建一个cfar曲线矩阵
figure;mesh(r,v,db(din1));hold on;
surface(r,v,VT1,'EdgeColor','none');hold on;
surface(r,v,VT2,'EdgeColor','none');
xlabel('距离/m','FontSize',12);ylabel('速度/m/s','FontSize',12);zlabel('信号幅度','FontSize',12);
for m=1:M
    for n=1:n
        if((db(din1(m,n))>VT1(m,n))&&(db(din1(m,n))>VT2(m,n)))%只有两个维度都大于cfar才可以
            target(m,n)=db(din1(m,n));
        else
            target(m,n)=0;
        end
    end
end
figure;mesh(r,v,target);
xlabel('距离/m','FontSize',12);ylabel('速度/m/s','FontSize',12);zlabel('目标幅度','FontSize',12);