%% Bootstrapping a Correlation Coefficient Standard Error
% This example shows how to compute a correlation coefficient standard
% error using bootstrap resampling of the sample data.

% Copyright 2015 The MathWorks, Inc.


%%
% Load a data set containing the LSAT scores and law-school GPA for 15
% students. These 15 data points are resampled to create 1000 different
% data sets, and the correlation between the two variables is computed for
% each data set.
load 'listtimedev_timeTAWSsmaller60.mat'
rng default  % For reproducibility
[bootstat,bootsam] = bootstrp(10000,@mean,listtimedeviations);

%%
% Display the first 5 bootstrapped correlation coefficients.
bootstat(1:5,:)

%%
% Display the indices of the data selected for the first 5 bootstrap samples.
bootsam(:,1:5)
figure
histogram(bootstat)
%%
% The histogram shows the variation of the correlation coefficient across
% all the bootstrap samples. The sample minimum is positive, indicating
% that the relationship between LSAT score and GPA is not accidental.

%%
% Finally, compute a bootstrap standard of error for the estimated
% correlation coefficient.
se = std(bootstat)
