clc;
clear;

%Loads Data from Physiobank
%*************************************************

%1
load SC4001E0-PSG_edfm.mat;
Subject(1).PzOz = val;
%2
load SC4002E0-PSG_edfm.mat;
Subject(2).PzOz = val;
%3
load SC4011E0-PSG_edfm.mat;
Subject(3).PzOz = val;
%4
load SC4012E0-PSG_edfm.mat;
Subject(4).PzOz = val;
%5
load SC4021E0-PSG_edfm.mat;
Subject(5).PzOz = val;
%6
load SC4022E0-PSG_edfm.mat;
Subject(6).PzOz = val;
%7
load SC4031E0-PSG_edfm.mat;
Subject(7).PzOz = val;
%8
load SC4032E0-PSG_edfm.mat;
Subject(8).PzOz = val;
%9
load SC4041E0-PSG_edfm.mat;
Subject(9).PzOz = val;
%10
load SC4042E0-PSG_edfm.mat;
Subject(10).PzOz = val;

%initializes jump and sampling frequency
%*************************************************
fs = 100;     %sampling frequency
jump = fs * 60 * 1;   %segment length

%Feature Extraction
%*************************************************
for s= 1 : length(Subject)
    %Creates empty matrix for power values (Raw and Normalized)
    Subject(s).ndData= []; %A container to the delta power value
    Subject(s).ntData= []; %A container to the theta power value
    Subject(s).naData= []; %A container to the alpha power value
    Subject(s).nbData= []; %A container to the beta power value
    Subject(s).dData= []; %A container to the delta power value
    Subject(s).tData= []; %A container to the theta power value
    Subject(s).aData= []; %A container to the alpha power value
    Subject(s).bData= []; %A container to the beta power value
    %Stores value of Band power at each segement (Raw and Normalized)
    for i= 1 : jump : length(Subject(s).PzOz)-jump
        segment = Subject(s).PzOz(i: i+jump-1);     %EEG segment
        %Raw powers
        [delta, theta, alpha, beta] = findNormBandPowers(segment, fs);   %extract the normalized band powers
        Subject(s).ndData= [Subject(s).ndData delta]; 
        Subject(s).ntData= [Subject(s).ntData theta]; 
        Subject(s).naData= [Subject(s).naData alpha]; 
        Subject(s).nbData= [Subject(s).nbData beta];
        %Normalized
        [delta, theta, alpha, beta] = findBandPowers(segment, fs);   %extract the band powers
        Subject(s).dData= [Subject(s).dData delta]; 
        Subject(s).tData= [Subject(s).tData theta]; 
        Subject(s).aData= [Subject(s).aData alpha]; 
        Subject(s).bData= [Subject(s).bData beta]; 
    end
    
    %Smooths data
    Subject(s).sndData= smooth(Subject(s).ndData,16);
    Subject(s).sntData= smooth(Subject(s).ntData,16);
    Subject(s).snaData= smooth(Subject(s).naData,16);
    Subject(s).snbData= smooth(Subject(s).nbData,16);
    Subject(s).sdData= smooth(Subject(s).dData,16);
    Subject(s).stData= smooth(Subject(s).tData,16);
    Subject(s).saData= smooth(Subject(s).aData,16);
    Subject(s).sbData= smooth(Subject(s).bData,16);
    %Transposes to match orginal dimensions
    Subject(s).sndData= transpose(Subject(s).sndData);
    Subject(s).sntData= transpose(Subject(s).sntData);
    Subject(s).snaData= transpose(Subject(s).snaData);
    Subject(s).snbData= transpose(Subject(s).snbData);
    Subject(s).sdData= transpose(Subject(s).ndData);
    Subject(s).stData= transpose(Subject(s).ntData);
    Subject(s).saData= transpose(Subject(s).naData);
    Subject(s).sbData= transpose(Subject(s).nbData);
    %Creates empty matrix for all data (Raw, Normalized, and Smoothed)
    Subject(s).Data= [];
    Subject(s).nData= [];
    Subject(s).snData= [];
    %Fills matrix for all data (Raw, Normalized, and Smoothed)
    Subject(s).nData = vertcat(Subject(s).ndData,Subject(s).ntData,Subject(s).naData,Subject(s).nbData);
    Subject(s).Data = vertcat(Subject(s).dData,Subject(s).tData,Subject(s).aData,Subject(s).bData);
    Subject(s).snData = vertcat(Subject(s).sndData,Subject(s).sntData,Subject(s).snaData,Subject(s).snbData);
    %Creates matrix of Data from deepest point of sleep (Normalized)
    [Subject(s).DSdData,Subject(s).DStData,Subject(s).DSaData,Subject(s).DSbData] = sleepAnalysis(Subject(s).ndData,Subject(s).ntData,Subject(s).naData,Subject(s).nbData);
    %Finds average from the deep sleep (Normalized)
    Subject(s).avgDS = [mean(Subject(s).DSdData), mean(Subject(s).DStData), mean(Subject(s).DSaData), mean(Subject(s).DSbData)];  
    %Creates matrix of Data from deepest point of sleep (Smoothed)
    [Subject(s).DSsdData,Subject(s).DSstData,Subject(s).DSsaData,Subject(s).DSsbData] = sleepAnalysis(Subject(s).sndData,Subject(s).sntData,Subject(s).snaData,Subject(s).snbData);
    %Finds average from the deep sleep (Smoothed)
    Subject(s).avgsDS = [mean(Subject(s).DSsdData), mean(Subject(s).DSstData), mean(Subject(s).DSsaData), mean(Subject(s).DSsbData)];
    %Finds average Gamma wave values based on remaining power level
    gamma = 1 - sum(Subject(s).avgsDS);
    %Adds Gamma values
    Subject(s).avgsDS = [Subject(s).avgsDS gamma];
    %Creates Deep vs Average Data matrix to be displayed in bar graph
    Subject(s).DvAsnd = [mean(Subject(s).DSsdData), mean(Subject(s).sndData)];
end
%Start of graphing
hold on
%For loop to graph all figures for each subject
for x = 1 : 10
    t = 2 : 2 : 166*2; %defines time (x-axis)
    %Plots Smoothed Normalized Data
    %******************************************
    figure(3*x - 2);
    subplot(4,1,1);
    plot(t,Subject(x).sndData,'k-');
    title('Smoothed Normalized Delta');
    subplot(4,1,2);
    plot(t,Subject(x).sntData,'b-');
    title('Smoothed Normalized Theta');
    subplot(4,1,3);
    plot(t,Subject(x).snaData,'r-');
    title('Smoothed Normalized Alpha');
    ylabel('Normalized Power (%)');
    subplot(4,1,4);
    plot(t,Subject(x).snbData,'g-');
    title('Smoothed Normalized Beta');
    xlabel('Time (min)');
    

    %Plots Subject Distrubtion of Band Powers during Deep Sleep
    %******************************************
    label = {'Delta', 'Theta', 'Alpha', 'Beta','Gamma'};
    figure(3*x - 1);
    pie(Subject(x).avgsDS);
    legend(label,'Location','northwest');
    title('Average Normalized Band Power during Deep Sleep for Subject')
    %Plots Subject Distrubtion of Band Powers during Overall Sleep
    %******************************************
    figure(3*x);
    Subject(x).avgData = mean(transpose(Subject(x).snData));
    gamma = 1 - sum(Subject(x).avgData);
    Subject(x).avgData = [Subject(x).avgData gamma];
    pie(Subject(x).avgData);
    legend(label,'Location','northwest');
    title('Average Normalized Band Power during Overall Sleep for Subject');

end



%Average Distrubtion of Band Powers during Deep Sleep
%******************************************
xf = 1;%first subject
xl = 10;%last subject
SampDS = [];
for i = xf : xl
    SampDS = vertcat(SampDS,Subject(i).avgDS);
end
avgSampDS = mean(SampDS);
gamma = 1 - sum(avgSampDS);
avgSampDS = [avgSampDS gamma];
figure(31);
pie(avgSampDS);
legend(label);
title('Average Normalized Band Power during Deep Sleep for ALL Subjects');

%Delta Power in Deep Sleep vs. Average Sleep
DvAdata =[];
for x = 1:10
    DvAdata = [DvAdata; Subject(x).DvAsnd];
end
figure(32)
bar(DvAdata);
title('Delta Power in Deep Sleep vs. Average Sleep')
barlabel = {'Deep Sleep', 'Average Sleep'};
legend(barlabel);
ylabel('Normalized Power (%)');
hold off





%******************************************
function [delta, theta, alpha, beta] = findBandPowers(data, samplingFreq)
    [p,f] = pwelch(data, [], [], [], samplingFreq);
    delta = 0;
    theta = 0;
    alpha = 0;
    beta = 0;
    for i= 1 : length(f)
        if f(i) < 4
            delta = delta + p(i);
        elseif f(i) < 8
            theta = theta + p(i);
        elseif f(i) < 16
            alpha = alpha + p(i);
        elseif f(i) < 32
            beta = beta + p(i);
        end
    end
end

function [delta, theta, alpha, beta] = findNormBandPowers(data, samplingFreq)
    [p,f] = pwelch(data, [], [], [], samplingFreq);
    delta = 0;
    theta = 0;
    alpha = 0;
    beta = 0;
    for i= 1 : length(f)
        if f(i) < 4
            delta = delta + p(i);
        elseif f(i) < 8
            theta = theta + p(i);
        elseif f(i) < 16
            alpha = alpha + p(i);
        elseif f(i) < 32
            beta = beta + p(i);
        end
    end
    delta = delta/sum(p);
    theta = theta/sum(p);
    alpha = alpha/sum(p);
    beta = beta/sum(p);
    
end

function [DSsndData,DSsntData,DSsnaData,DSsnbData] = sleepAnalysis(sndData,sntData,snaData,snbData)
    DSsndData = [];
    DSsntData = [];
    DSsnaData = [];
    DSsnbData = [];
    [dMAX,dst] = max(sndData(6:length(sndData)-6));
    dst= dst+5;
    for i = (dst-5) : (dst+4)
        DSsndData = [DSsndData sndData(i)];
        DSsntData = [DSsntData sntData(i)];
        DSsnaData = [DSsnaData snaData(i)];
        DSsnbData = [DSsnbData snbData(i)];
    end    
end
