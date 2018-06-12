clear;

% Michael Bian - June 11, 2018

input_file='OOS';

premiums = xlsread(input_file, 'Average', 'b122:b1081');
premiums = premiums(2:end,:);

averages = xlsread(input_file, 'Average', 'd122:d1081');
averages = averages(1:(end-1),:);

averages_plus = xlsread(input_file, 'Average', 'f122:f1081');
averages_plus = averages_plus(1:(end-1),:);

a_tbl = table(premiums, averages);
a_tbl.Properties.VariableNames = {'Premiums', 'Averages'};

ap_tbl = table(premiums, averages_plus);
ap_tbl.Properties.VariableNames = {'Premiums', 'AveragesP'};

a_mdl = fitlm(a_tbl, 'Premiums ~ Averages');
ap_mdl = fitlm(ap_tbl, 'Premiums ~ AveragesP');

results = ["Name", "Coefficient", "Constant", "R squared", "P-value"];
results = [results; "Raw Average", a_mdl.Coefficients.Estimate(1), a_mdl.Coefficients.Estimate(2), a_mdl.Rsquared.Ordinary, a_mdl.Coefficients.pValue(2)];
results = [results; "Average+", ap_mdl.Coefficients.Estimate(1), ap_mdl.Coefficients.Estimate(2), ap_mdl.Rsquared.Ordinary, ap_mdl.Coefficients.pValue(2)];
