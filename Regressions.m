clear;

% Michael Bian - April 7th, 2018

disp('Loading data');
input_file='Returns_econ_tech_results';
input_sheet='Equity premium';
premiums=xlsread(input_file,input_sheet,'b278:b1081');
premiums=premiums*100; % percent equity premium

cycle=xlsread(input_file,input_sheet,'d278:d1081');

results = ["Variable", "Constant", "Coefficient", "R-squared (non-adjusted)", "P-value", "Expansion R^2", "Recession R^2"];

% MACROECONOMIC VARIABLES
% from Janurary 1928 to December 2017
variable_names = ["DP", "DY", "EP", "DE", "RVOL", "BM", "NTIS", "TBL", "LTY", "LTR", "TM", "DFY", "DFR", "INFL"]

premiums_adjusted = premiums(2:end);

input_sheet='Macroeconomic variables';
X_ECON=xlsread(input_file,input_sheet,'b278:o1081');

for i = 1:14

    predictors_raw = X_ECON(:,i);
    
    predictors_adjusted = predictors_raw(1:end-1,:);
    cycle_adjusted = cycle(1:end-1,:);
    
    T = table(predictors_adjusted, premiums_adjusted,'VariableNames',{'Predictors', 'Premiums'});
    mdl = fitlm(T, 'Premiums ~ Predictors');
    
    predictors_expansion = predictors_adjusted(cycle_adjusted==1);
    premiums_expansion = premiums_adjusted(cycle_adjusted==1);
    
    T_exp = table(predictors_expansion, premiums_expansion,'VariableNames',{'Predictors','Premiums'});
    mdl_exp = fitlm(T_exp, 'Premiums ~ Predictors');
    
    predictors_recession = predictors_adjusted(cycle_adjusted==0);
    premiums_recession = premiums_adjusted(cycle_adjusted==0);
    
    T_rec = table(predictors_recession, premiums_recession,'VariableNames',{'Predictors','Premiums'});
    mdl_rec = fitlm(T_rec, 'Premiums ~ Predictors');
    
    results = [results ; variable_names(i), mdl.Coefficients.Estimate(1),...
        mdl.Coefficients.Estimate(2), mdl.Rsquared.Ordinary, mdl.Coefficients.pValue(2),...
        mdl_exp.Rsquared.Ordinary, mdl_rec.Rsquared.Ordinary];
    
end

% TECHNICAL VARIABLES
% from Feburary 1928 to December 2016
variable_names = ["MA(1,9)", "MA(1,12)", "MA(2,9)", "MA(2,12)", "MA(3,9)",...
    "MA(3,12)", "MOM(9)", "MOM(12)"];

premiums_adjusted = premiums(3:end);

input_sheet='Technical indicators';

X_TECH = xlsread(input_file,input_sheet,'b278:i1081');

for i = 1:8
    
    predictors_raw = X_TECH(:,i);
    predictors_adjusted = predictors_raw(2:end-1,:);
    
    cycle_adjusted = cycle(2:end-1,:);
    
    T = table(predictors_adjusted, premiums_adjusted,'VariableNames',{'Predictors', 'Premiums'});
    mdl = fitlm(T, 'Premiums ~ Predictors');
    
    predictors_expansion = predictors_adjusted(cycle_adjusted==1);
    premiums_expansion = premiums_adjusted(cycle_adjusted==1);
    
    T_exp = table(predictors_expansion, premiums_expansion,'VariableNames',{'Predictors','Premiums'});
    mdl_exp = fitlm(T_exp, 'Premiums ~ Predictors');
    
    predictors_recession = predictors_adjusted(cycle_adjusted==0);
    premiums_recession = premiums_adjusted(cycle_adjusted==0);
    
    T_rec = table(predictors_recession, premiums_recession,'VariableNames',{'Predictors','Premiums'});
    mdl_rec = fitlm(T_rec, 'Premiums ~ Predictors');
    
    results = [results ; variable_names(i), mdl.Coefficients.Estimate(1),...
        mdl.Coefficients.Estimate(2), mdl.Rsquared.Ordinary, mdl.Coefficients.pValue(2),...
        mdl_exp.Rsquared.Ordinary, mdl_rec.Rsquared.Ordinary];
end




