
fileName='D:\�˶�ʶ�����\�׶ζ������ݷ���\Minjl\2.23\һ������\adc_data.bin';
newFileDir='D:\�˶�ʶ�����\�׶ζ������ݷ���\Minjl\��������\adcRetVal\';
% dataCountIndex=dataCountIndex+1;
% newFileName=[num2str(dataCountIndex) '.mat'];
newFileName='һ������.mat';
newFilePath=fullfile(newFileDir,newFileName);
retVal = interpretBin(fileName);
save(newFilePath,'retVal');