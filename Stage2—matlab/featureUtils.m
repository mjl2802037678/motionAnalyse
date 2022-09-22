clear;
close all;

global RANGEBIN_STOP;
global RANGEBIN_START;
global params;

%% ����ģ�飬�������ݣ���ʼ��
path = "D:\Minjl\3.22ͷ��2��TX\data\move_once\right-front.mat";
load(path);
params.numFrames = radarCube.dim.numFrames;
params.numChirps=radarCube.rfParams.numDopplerBins;
params.numTx=radarCube.dim.numChirps/(params.numChirps);
params.numRangeBins=radarCube.rfParams.numRangeBins;
RANGEBIN_START=6;
RANGEBIN_STOP=11;
params.numChirps=1;%ʹ�ö��ٸ�chirpȥIQͼ
focus_theta=[-30,-15,0,15,30];



%% ���ͷ������ͷƫ���������Ʒ���
% numRangeBinSelect = RANGEBIN_STOP + 1 - RANGEBIN_START;
% binValAllFrames=zeros(params.numFrames,params.numTx*4,numRangeBinSelect);
% 
% for i=1:params.numFrames
%     dataIn = radarCube.data{i};
%     binVal = process_rangeAngle_complex(dataIn);
%     binValAllFrames(i,:,:)=binVal;
% end
% 
% figure()
% i=0;
% StartFrame=50;
% StopFrame=StartFrame+20;
% for binIndex=1:numRangeBinSelect
%     for angleIndex=3:6%ֻѡ�м�4���Ƕȵ�
%         subplot(numRangeBinSelect, 4, i + 1);
%         i=i+1;
%         IQData=binValAllFrames(StartFrame:StopFrame,angleIndex,binIndex);
% %         I = real(IQData);
% %         Q = imag(IQData);
% %         angles=np.angle(IQData);
% %         angles=wrapAngle(angles);
% %         plot(np.array(range(len(I))),angles);
%         plot(IQData);
%         title(binIndex+RANGEBIN_START-1)
%     end
% end

%% ���ǵ�������ʹ��
% numRangeBinSelect = RANGEBIN_STOP + 1 - RANGEBIN_START;
% binValAllFrames=zeros(params.numFrames,params.numChirps,numRangeBinSelect);
% rx=1;
% for i=1:params.numFrames
%     dataIn = radarCube.data{i};
%     for txIndx =1:params.numChirps
%         tx=txIndx*params.numTx;
%         binValAllFrames(i,txIndx,:)=dataIn(tx,rx,RANGEBIN_START:RANGEBIN_STOP);%ͬһ����������rx��һ��frame������chirp
%     end
% end
% figure()
% i=0;
% StartFrame=50;
% StopFrame=StartFrame+20;
% for binIndex=1:numRangeBinSelect
% %     subplot(numRangeBinSelect,1, i + 1);
%     i=i+1;
% %     IQData=reshape(binValAllFrames(StartFrame:StopFrame,:,binIndex)',(StopFrame+1-StartFrame)*params.numChirps,1);
%     IQData=binValAllFrames(StartFrame:StopFrame,1,binIndex);
%     figure;
%     plot(IQData);
%     title(binIndex+RANGEBIN_START-1)
% end


%% ���Ƕ������beamforming����������chirps
% numRangeBinSelect = RANGEBIN_STOP + 1 - RANGEBIN_START;
% binValAllFrames=zeros(params.numFrames*params.numChirps,numRangeBinSelect,5);
% rx=1;
% for i=1:params.numFrames
%     dataIn = radarCube.data{i};
%     binValAllFrames((i-1)*params.numChirps+1:i*params.numChirps,:,:)=Rx_beamforming(dataIn);
% end
% figure()
% i=0;
% StartFrame=60;
% StopFrame=StartFrame+40;
% for binIndex=1:numRangeBinSelect
%     for angleIdx=1:5
%         subplot(numRangeBinSelect,5, i + 1);
%         i=i+1;
%         IQData=binValAllFrames((StartFrame-1)*params.numChirps+1:StopFrame*params.numChirps,binIndex,angleIdx);
%         plot(IQData);
%         title(binIndex+RANGEBIN_START-1)
%     end
% end


%% ���Ƕ������beamforming�����ҽ���һ��chirps���۲�5���Ƕ��ϣ�������ʱ��仯
numRangeBinSelect = RANGEBIN_STOP + 1 - RANGEBIN_START;
binValAllFrames=zeros(params.numFrames*params.numChirps,numRangeBinSelect,5);

for i=1:params.numFrames
    dataIn = radarCube.data{i};
    binValAllFrames((i-1)*params.numChirps+1:i*params.numChirps,:,:)=Rx_beamforming(dataIn);
end
figure()
i=0;
StartFrame=1;
StopFrame=StartFrame+199;
energyAllFrames=zeros(5,StopFrame-StartFrame+1);
%���ͬһ���Ƕ�������rangeBin����
% for angleIdx=1:5
%     IQData=binValAllFrames((StartFrame-1)*params.numChirps+1:StopFrame*params.numChirps,:,angleIdx)';
%     energyAllFrames(angleIdx,:)=abs(sum(IQData));
%     
%     subplot(5,1,angleIdx);
%     plot(energyAllFrames(angleIdx,:));
%     title(focus_theta(angleIdx));
% end

%�������нǶ��ϣ�����rangeBin����
i=0;
for binIndex=1:numRangeBinSelect
    for angleIdx=1:5
        IQData=binValAllFrames((StartFrame-1)*params.numChirps+1:StopFrame*params.numChirps,binIndex,angleIdx)';
        energyAllFrames(angleIdx,:)=abs(IQData);
        subplot(numRangeBinSelect,5, i + 1);
        i=i+1;
        plot(energyAllFrames(angleIdx,:));
        title(binIndex+RANGEBIN_START-1);
    end
end


function binVal=process_rangeAngle_complex(dataIn)
    global RANGEBIN_STOP;
    global RANGEBIN_START;
    global params;
    numTx=params.numTx;
    numRangeBin=RANGEBIN_STOP+1-RANGEBIN_START;
    rangeProf=zeros(numTx*4,numRangeBin);
    binVal=zeros(numTx*4,numRangeBin);
    virtualIdx=1;

    for tx=1:2
        for rx=1:4
            %ֻѡ��һ��chirp��
            rangeProf(virtualIdx,:)= dataIn(tx,rx,RANGEBIN_START:RANGEBIN_STOP);
            virtualIdx=virtualIdx+1;
        end
    end

    for i=RANGEBIN_START:RANGEBIN_STOP
        index=i-RANGEBIN_START+1;%����rangeBin�У����8����
        binVal(:,index)=fftshift(fft(rangeProf(:,index),numTx*4));
    end
    %binVal��8���Ƕȡ�7��rangeBin
end



function binVal=Rx_beamforming(dataIn)
%5��rangeBin��5��angle���棬beamforming��ʽ
    global RANGEBIN_STOP;
    global RANGEBIN_START;
    global params;
    rangeProf=zeros(8,params.numRangeBins);%8���ߣ�����rangeBin
    numSelectBins=RANGEBIN_STOP-RANGEBIN_START+1;
    binVal=zeros(params.numChirps,numSelectBins,5);%ֻ��5���ǶȾۺ�
    
    for chirpIdx=0:params.numChirps-1
        virtualIdx=1;
        for tx=1:2
            txIdx=chirpIdx*params.numTx+tx;
            for rx=1:4
                rangeProf(virtualIdx,:)=dataIn(txIdx,rx,:);
                virtualIdx=virtualIdx+1;
            end
        end
    
        focus_theta=[-30,-15,0,15,30];
        w=hanning(8);
        for rangeBinIndex = RANGEBIN_START:RANGEBIN_STOP
            for angleIdx =1:5
                theta=focus_theta(angleIdx);
                temp_bin_val = 0;
                for antennaIdx =1:8
                    A=exp(-1j*pi*(antennaIdx-1)*sind(theta))*w(antennaIdx);
                    temp_bin_val=temp_bin_val+(A*rangeProf(antennaIdx,rangeBinIndex));
                end

                binVal(chirpIdx+1,rangeBinIndex-RANGEBIN_START+1,angleIdx)=temp_bin_val;%8�����ߣ�ѡ��rangeBin
            end
        end
    end
end

