
fileName='D:\运动识别课题\阶段二：数据分析\Minjl\2.23\一个动点\adc_data.bin';
newFileDir='D:\运动识别课题\阶段二：数据分析\Minjl\测试数据\adcRetVal\';
% dataCountIndex=dataCountIndex+1;
% newFileName=[num2str(dataCountIndex) '.mat'];
newFileName='一个动点.mat';
newFilePath=fullfile(newFileDir,newFileName);
retVal = interpretBin(fileName);
save(newFilePath,'retVal');