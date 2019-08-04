function T = MergeTwoTables(T1,T2)
% Merges two tables, fills nans in columns which are not common

missingCol1 = setdiff(T2.Properties.VariableNames, T1.Properties.VariableNames);
missingCol2 = setdiff(T1.Properties.VariableNames, T2.Properties.VariableNames);

T1MissingCols = array2table(nan(height(T1), length(missingCol1)), 'VariableNames', missingCol1);
T1 = [T1 T1MissingCols];
T2MissingCols = array2table(nan(height(T2), length(missingCol2)), 'VariableNames', missingCol2);
T2 = [T2 T2MissingCols];

T = [T1; T2];
end