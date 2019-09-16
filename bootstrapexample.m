clear all;close all;clc
myStatistic = @mean;

% Here's an option for an arbitrary statistic (commented out)
% myStatistic = @(x) abs(mean(x))
n = 25;  %size of each data set
nReps = 100000;  %number of data sets or 'experiments'

x = randn(1,n);
sampleStat = myStatistic(x);

id = ceil(rand(n,nReps)*n);

bootstrapData = x(id);

bootstrapStat = zeros(1,nReps);
for i=1:nReps
    bootstrapStat(i) = myStatistic(bootstrapData(:,i));
end

figure(2)
clf
hist(bootstrapStat,50)  %50 bins
xlabel(func2str(myStatistic))
title('Samples re-drawn from a single sample');

CIrange = 95;
bootstrapCI = bootstrap(myStatistic,x,nReps,CIrange);