clear;

% Michael Bian - June 8th, 2018

disp('Loading data');
input_file='OOS';

fitting_period = 0.5;

monthly_premiums = xlsread(input_file,'Monthly','c2:c1081');
monthly_premiums = monthly_premiums*100;

monthly_variables = xlsread(input_file,'Monthly','f2:ad1081');

monthly_names = ["DY","PE","CAPE","B/M","TRES","DFY","DFR","TERM","L-INFL","D/E","NTIS","SVAR","MA","MOM","CSP","BY","NO/S","PRC","OIL-AL","SI","OIL-AG","OIL-WT","BDI","VIX","IC"];

premiums_adjusted = monthly_premiums(2:end);

variables_adjusted = monthly_variables(1:end-1,:);

results = ["Variable", "Constant", "Coefficient", "IS R^2", "IS P-value", "OOS R^2", "OOS P-value"];

for i = 1:25
    current_variable = variables_adjusted(:,i);
    
    current_premiums = premiums_adjusted(~isnan(current_variable));
    current_variable = current_variable(~isnan(current_variable));
    
    observations = length(current_premiums);
    
    is_premiums = current_premiums(1 : floor(observations * fitting_period));
    is_variable = current_variable(1 : floor(observations * fitting_period));
    
    is_table = table(is_premiums, is_variable, 'VariableNames', {'Premiums','Predictors'});
    mdl = fitlm(is_table, 'Premiums ~ Predictors');
    
    oos_variable = current_variable(ceil(observations * fitting_period) : end);
    
    oos_premiums = current_premiums(ceil(observations * fitting_period) : end);
    oos_pred = feval(mdl, oos_variable);
    
    [oos_r, oos_p] = corrcoef(oos_pred, oos_premiums);
    
    oos_rsquare = power(oos_r(1,2), 2);
    oos_pvalue = oos_p(1,2);
    
    results = [results; monthly_names(i), mdl.Coefficients.Estimate(1), mdl.Coefficients.Estimate(2), mdl.Rsquared.Ordinary, mdl.Coefficients.pValue(2), oos_rsquare, oos_pvalue];
end
