clear;

% Michael Bian - June 10, 2018

years = 10;
periods = years * 12;

disp('Loading data');
input_file='OOS';

dates = xlsread(input_file,'Data','a2:a1081');

rfrees = xlsread(input_file,'Data','j2:j1081');

premiums = xlsread(input_file,'Data','c2:c1081');
premiums = premiums*100;

variables = xlsread(input_file,'Data','f2:ak1081');

results = ["Date", "Actual", "Predicted", "RFree", "Position", "Num"];

for i = 1:1081
    
    disp(num2str(i));
    
    if (i <= periods)
        results = [results; dates(i), premiums(i), "NaN", rfrees(i), 'NaN', 0];
    else
        num = 0;
        
        cur_variables = variables(((i - periods) : (i - 1)),:);
        cur_variables = cur_variables(1:(end-1),:);
        
        variables_now = variables((i-1),:);
        
        cur_premiums = premiums(((i - periods) : (i - 1)),:);
        cur_premiums = cur_premiums(2:end,:);
        
        predictions = zeros([1 32]);
        
        for j = 1:32
            
            cur_var = cur_variables(:,j);
            
            observations = nnz(~isnan(cur_var));
            
            var_now = variables_now(j);
            
            if ((observations == periods-1) && (~isnan(var_now)))
                
                tbl = table(cur_premiums, cur_var);
                tbl.Properties.VariableNames = {'Premiums', 'Predictor'};
                
                mdl = fitlm(tbl, 'Premiums ~ Predictor');
                
                pred = predict(mdl, var_now);
                
                if(mdl.Coefficients.pValue(2) <= 0.05)
                    predictions(j) = pred;
                    num = num+1;
                else
                    predictions(j) = 0;
                end
                
            else
                predictions(j) = 0;
            end
            
        end
        
        average_pred = (sum(predictions) / num);
        
        scale = average_pred / 5;
        if (scale < (-0.5))
            scale = -0.5;
        end

        if (scale > 1.5)
            scale = 1.5;
        end
        
        results = [results; dates(i), premiums(i), average_pred, rfrees(i), scale, num];
    end
    
    


end
