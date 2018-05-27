clear;

% Michael Bian - April 28th, 2018

disp('Loading data');
input_file='Predictor_Data_Update';
input_sheet='Data';
premiums=xlsread(input_file,input_sheet,'c2:c1081');
premiums=premiums*100; % percent equity premium

cycle=xlsread(input_file,input_sheet,'d2:d1081');

results = ["Variable", "Constant", "Coefficient", "R-squared (non-adjusted)", "P-value", "Expansion R^2", "Recession R^2"];

% from Janurary 1928 to December 2016
variable_names = ["DY", "PE", "CAPE", "BM", "TRES", "DFY", "DFR", "TERM", "LINFL", "DE", "NTIS", "SVAR", "MA", "MOM", "CSP", "BY","NOS","PRC","OILAL","SI","OILAG","OILWT","BDI","VIX","IC","PY","LI","GAP","CAY","EXP","ACC","CF"];
table_names = ["DY", "PE", "CAPE", "BM", "TRES", "DFY", "DFR", "TERM", "LINFL", "DE", "NTIS", "SVAR", "MA", "MOM", "CSP", "BY","NOS","PRC","OILAL","SI","OILAG","OILWT","BDI","VIX","IC","PY","LI","GAP","CAY","EXP","ACC","CF"];

premiums_adjusted = premiums(2:end); %Feburary 1928 - December 2016

X_ECON=xlsread(input_file,input_sheet,'f2:ak1081'); %Januaray 1928 - December 2016

kitchen_table = table();

for i = 1:32
    predictors_raw = X_ECON(:,i);
    
    predictors_adjusted = predictors_raw(1:end-1,:); % Jan 1928 - Novemeber 1928
    cycle_adjusted = cycle(1:end-1,:);
    
    kitchen_specific = table(predictors_adjusted);
    kitchen_specific.Properties.VariableNames = {char(table_names(i))};
    kitchen_table = [kitchen_table kitchen_specific];
    
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

trading_res = ["Predicted", "Actual", "Position", "Rfree"];

kitchen_table([1:756],:) = []; %Jan 1990 - Nov 2016
premiums_adjusted = premiums(758:end); %Feb 1990 - Dec 2016

for i = 121:323
    ten_year_table = table();
    
    ten_year_premiums = table(premiums_adjusted((i - 120) : (i - 1)));
    ten_year_premiums.Properties.VariableNames = {'Premiums'};
    ten_year_table = kitchen_table([(i - 120):(i - 1)],:);
    ten_year_table = [ten_year_table ten_year_premiums];
    
    t_mdl = fitlm(ten_year_table, 'Premiums ~ DY + PE + CAPE + BM + TRES + DFY + DFR + TERM + LINFL + DE + NTIS + SVAR + MA + MOM + BY + NOS + PRC + OILAL + OILAG + OILWT + BDI + VIX + PY + CAY + LI + GAP + EXP + ACC + CF');
    
    current_table = kitchen_table(i,:);
    rfree = (100*current_table.TRES/12);
    t_pred = predict(t_mdl, current_table);
    
    scale = t_pred / 5;
    if (scale < (-0.5))
        scale = -0.5;
    end
    
    if (scale > 1.5)
        scale = 1.5;
    end
    disp(num2str(scale));
    
    cur_res = [t_pred, premiums_adjusted(i), scale, rfree];
    trading_res = [trading_res ; cur_res];
end
