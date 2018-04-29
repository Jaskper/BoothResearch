clear;

% Michael Bian - April 28th, 2018

disp('Loading data');
input_file='Predictor_Data';
input_sheet='Data';
premiums=xlsread(input_file,input_sheet,'c2:c1081');
premiums=premiums*100; % percent equity premium

cycle=xlsread(input_file,input_sheet,'d2:d1081');

results = ["Variable", "Constant", "Coefficient", "R-squared (non-adjusted)", "P-value", "Expansion R^2", "Recession R^2"];

% from Janurary 1928 to December 2016
variable_names = ["DY", "PE", "CAPE", "B/M", "TRES", "DFY", "DFR", "TERM", "L-INFL", "D/E", "NTIS", "SVAR", "MA", "MOM", "CSP", "BY","NO/S","PRC","OIL-AL","SI","OIL-AG","OIL-WT","BDI","VIX","PY","CAY"];
%table_names = ["DY", "PE", "CAPE", "BM", "TRES", "DFY", "DFR", "TERM", "LINFL", "DE", "NTIS", "SVAR", "MA", "MOM", "CSP", "BY","NOS","PRC","OILAL","SI","OILAG","OILWT","BDI","VIX","PY","CAY"];

premiums_adjusted = premiums(2:end);

X_ECON=xlsread(input_file,input_sheet,'f2:ae1081');
%kitchen_table = table();

for i = 1:26
    predictors_raw = X_ECON(:,i);
    
    predictors_adjusted = predictors_raw(1:end-1,:);
    cycle_adjusted = cycle(1:end-1,:);
    %{
    kitchen_specific = table(predictors_adjusted);
    kitchen_specific.Properties.VariableNames = {char(table_names(i))};
    kitchen_table = [kitchen_table kitchen_specific];
    %}
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
%{
kitchen_premiums = table(premiums_adjusted);
kitchen_premiums.Properties.VariableNames = {'Premiums'};
kitchen_table = [kitchen_table kitchen_premiums];

k_mdl = fitlm(kitchen_table, 'Premiums ~ DY + PE + CAPE + BM + TRES + DFY + DFR + TERM + LINFL + DE + NTIS + SVAR + MA + MOM + CSP + BY + NOS + PRC + OILAL + SI + OILAG + OILWT + BDI + VIX + PY + CAY');
   
results = [results ; "Kitchen Sink", k_mdl.Coefficients.Estimate(1),...
        k_mdl.Coefficients.Estimate(2), k_mdl.Rsquared.Ordinary, k_mdl.Coefficients.pValue(2), 0, 0];
%}
