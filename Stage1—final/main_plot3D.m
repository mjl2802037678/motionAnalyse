



%% 参数设置
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
PRF=1/PRT;

data_per_frame=cell(1,numFrames);
data_per_frame=radarCube.data;%radarCube是1D FFT后的


sumEnergyAllFrame=zeros(numFrames,2);%默认只存2个range段数据
%% 此处是将三个chirp分开，每个RX接收3*90个chirp
for frame=1:numFrames
    %% 逐个frame
    data_2D=data_per_frame{frame};%这个data_2D是未FFT的
    data_RX=zeros(numChirps,numSamples);

    selectedRX=1;
    for i=1:numChirps
        rx=(i-1)*3+1;
        data_RX(i,:)=data_2D(rx,selectedRX,:);
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

    N=numSamples;
    M=numChirps;
    f=Fs/N*(0:N-1);
    t=f/k;
    %% 二维图
    % r=c*t/2;
    % left=ceil((M-1)/2);
    % f_2D=PRF/M*(-left:left-1);
    % v=f_2D*lamda/2;
    % f1=pcolor(r,v,abs(data_f_RX1_TX1));
    % title('二维分布图');axis tight;
    % xlabel('距离/m','FontSize',12);ylabel('速度/m/s','FontSize',12);zlabel('信号幅度（量化值）','FontSize',12);    

    %% 3D图
%     r=c*t/2;
%     left=ceil((M-1)/2);
%     f_2D=PRF/M*(-left:left-1);
%     v=f_2D*lamda/2;
%     f1=mesh(r,v,(abs(data_f_RX1_TX1)));
%     title('3D分布图');axis tight;
%     xlabel('距离/m','FontSize',12);ylabel('速度/m/s','FontSize',12);zlabel('信号幅度（量化值）','FontSize',12);
%     pause(0.25);
    
    
    %% 多段range处能量变化图
    f=Fs/N;
    t=f/k;
    r=c*t/2;
    rangeArr=[[1,ceil(1/r)];[floor(2/r),ceil(3/r)]];
    sumEnergy = accumEnergy(abs(data_f_RX1_TX1),rangeArr);
    sumEnergyAllFrame(frame,:)=sumEnergy;
end
x=1:1:numFrames;
plot(x,sumEnergyAllFrame(:,1),x,sumEnergyAllFrame(:,2));
legend('0-1m','2-3m');




function sumEnergy = accumEnergy(absDataRxTx,rangeArr)
    [m,n]=size(rangeArr);
    sumEnergy=zeros(1,m);
    for row=1:m
        startIdx=rangeArr(row,1);
        endIdx=rangeArr(row,2);
        sumEnergy(row)=sum(absDataRxTx(:,startIdx:endIdx),'all');
    end
end





