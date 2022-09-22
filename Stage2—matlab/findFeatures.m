
close all;
clear;
allChirps_singleFrame()
% singleChirp_allFrames();

%% ����frame����
function allChirps_singleFrame()
    path = "D:\Minjl\3.22ͷ��2��TX\data\move_once\front-left-2.mat";
    load(path);
    numRangeBins=radarCube.rfParams.numRangeBins;
    numChirps=radarCube.rfParams.numDopplerBins;
    numAngles=5;
    
    
    frameMedia=95;
    
    RANGEBIN_START=4;
    RANGEBIN_STOP=8;%3,7,12
    numSelectBins=RANGEBIN_STOP-RANGEBIN_START+1;
    

    binValAllFrames=zeros(numChirps,numSelectBins,numAngles);%����һ��frame��
    dataIn=radarCube.data{frameMedia};%����frame���в���
    
    %dataIn�ǵ���chirp
    for chirpIdx=0:numChirps-1
        chirpDataIn=dataIn(chirpIdx*3+1:chirpIdx*3+3,:,:);
        binVal=binAlg_singleFrame(chirpDataIn,numRangeBins,RANGEBIN_START,RANGEBIN_STOP);
        binValAllFrames(chirpIdx+1,:,:)=binVal;
    end

    figure();
    for row =1:numSelectBins
        for col =1:numAngles
            plotNum=(row-1)*numAngles+col;
            subplot(numSelectBins,numAngles,plotNum);
            plot(binValAllFrames(:,row,col));
        end
    end
end


function binVal=binAlg_singleFrame(dataIn,numRangeBins,RANGEBIN_START,RANGEBIN_STOP)
    rangeProf=zeros(8,numRangeBins);
    numSelectBins=RANGEBIN_STOP-RANGEBIN_START+1;
    binVal=zeros(numSelectBins,5);%һ��chirp�ģ��ۺ�
    virtualIdx=1;
    for tx=1:2:3
        for rx=1:4
            rangeProf(virtualIdx,:)=dataIn(tx,rx,:);
            virtualIdx=virtualIdx+1;
        end
    end
    w=hanning(8);
    for rangeBinIndex = RANGEBIN_START:RANGEBIN_STOP

        temp_binVal=fftshift(fft(rangeProf(:,rangeBinIndex).*w));%��������5Ϊ���ĵķ���
        for angleIdx=1:5
            binVal(rangeBinIndex-RANGEBIN_START+1,angleIdx)=temp_binVal(angleIdx+2);
        end
    end

%%�˴�������RX beamforming
%     focus_theta=[-30,-15,0,15,30];
%     w=hanning(8);
%     for rangeBinIndex = RANGEBIN_START:RANGEBIN_STOP
%        
%         for angleIdx =1:5
%             theta=focus_theta(angleIdx);
%             temp_bin_val = 0;
% 
%             for antennaIdx =1:8
%                 A=exp(-1j*pi*(antennaIdx-1)*sind(theta))*w(antennaIdx);
%                 temp_bin_val=temp_bin_val+(A*rangeProf(antennaIdx,rangeBinIndex));
%             end
% 
%             binVal(rangeBinIndex-RANGEBIN_START+1,angleIdx)=temp_bin_val;
%         end
%     end
end





%% ����chirp������Frame����
%ֱ�ӵ��ø�function�����frame���ݣ�ÿ��frame��ѡ���һ��chirp
function singleChirp_allFrames()
    path = "D:\Minjl\3.22ͷ��2��TX\data\move_once\front-left-2.mat";
    load(path);
    numFrames=radarCube.dim.numFrames;
    numRangeBins=radarCube.rfParams.numRangeBins;
    numAngles=5;
%     RANGEBIN_START=4;
%     RANGEBIN_STOP=8;%3,7,12
    RANGEBIN_START=8;
    RANGEBIN_STOP=12;

    numSelectBins=RANGEBIN_STOP-RANGEBIN_START+1;
%     frameMedia=31;
%     frameStart=frameMedia-10;
%     frameStop=frameMedia+9;
    frameStart=1;
    frameStop=200;
    numSelectFrames=frameStop-frameStart+1;
    binValAllFrames=zeros(numSelectFrames,numSelectBins,numAngles);

    for i=frameStart:frameStop
        dataIn=radarCube.data{i};
        binVal=binAlg(dataIn,numRangeBins,RANGEBIN_START,RANGEBIN_STOP);
        binValAllFrames(i-frameStart+1,:,:)=binVal;
    end


    figure();
    for row =1:numSelectBins
        for col =1:numAngles
            plotNum=(row-1)*numAngles+col;
            subplot(numSelectBins,numAngles,plotNum);
            plot(abs(binValAllFrames(:,row,col)));
        end
    end
end



function binVal=binAlg(dataIn,numRangeBins,RANGEBIN_START,RANGEBIN_STOP)
    rangeProf=zeros(8,numRangeBins);
    numSelectBins=RANGEBIN_STOP-RANGEBIN_START+1;
    binVal=zeros(numSelectBins,5);
    virtualIdx=1;
    for tx=1:2:3
        for rx=1:4
            rangeProf(virtualIdx,:)=dataIn(tx,rx,:);
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

            binVal(rangeBinIndex-RANGEBIN_START+1,angleIdx)=temp_bin_val;
        end
    end
end
