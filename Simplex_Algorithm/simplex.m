%% simplex: Solves a Maximization LP in Standard Form Using the Simplex Algorithm.

%% INPUTS:
%   c       - Cost vector for decision variables (decision variables objective coefficient or 
% reduced cost)
%   A       - Constraint matrix.
%   b       - Right-hand side vector.
%   eqSigns - A cell array of strings for each constraint: '<=', '>=', or '='.

%% Outputs
%   optSol      - Optimal solution vector (including decision vraible slack/surplus/artificial variables).
%   optVal      - Optimal objective function value.
%   finalTableau- Final simplex tableau.
%   status      - String indicating 'Optimal', 'Unbounded', or 'Infeasible'.

%% Further Explanations
% This implementation converts the LP to standard form.
% For constraints with '>=' it adds a surplus and an artificial variable.
% For '=' constraints where no obvious BFS is available, it also adds an artificial variable.

%% Example 
% From Wayne L. Winston - Operations Research - Applications and Algorithms 
% (Dakota Furniture Company - Resource Allocation Problem)

%   c = [60; 30; 20]; 
%   A = [8   6  1;
%        4   2  1.5;
%        2   1.5  0.5;
%        0   1    0];
%   b = [48; 20; 8; 5];
%   eqSigns = {'<=', '<=', '<=', '<='};
%   [sol, val, tab, stat] = simplex(c, A, b, eqSigns);

 %% Simplex

function [optSol, optVal, finalTableau, status] = simplex(c, A, b, eqSigns)
%% Initialization and Conversion to Standard Form
M = 1e6;    % Big M value
[numCons, numVars] = size(A);

A_aug = A;
c_aug = c;
varNames = cell(numVars,1);

for i = 1:numVars   % Storing the variables name for the future use
    varNames{i} = sprintf('x%d', i);
end

slackCount = 0;     % Counters for additional variables
artifCount = 0;

for i = 1:numCons

    if strcmp(eqSigns{i}, '<=')

        % Add slack variable
        slackCount = slackCount + 1;
        slackVar = zeros(numCons,1);    % This vector will represent the coefficients of the new slack variable across all constraints.
        slackVar(i) = 1;    % In the ith constraint we have a slack with coeff of 1
        A_aug = [A_aug slackVar];   % Add the new column to the constraint matrix includes the coefficients of slacks
        c_aug = [c_aug; 0];     % Add a zero to cost vector representing the reduced cost of slack in OF
        varNames{end+1} = sprintf('s%d', slackCount);   % Add slack variable name to variable name dictionary

    elseif strcmp(eqSigns{i}, '>=')

        % Add surplus variable (with -1 coefficient) and an artificial variable.
        slackCount = slackCount + 1;    
        artifCount = artifCount + 1;
        surplusVar = zeros(numCons,1);  % This vector will represent the coefficients of the new surplus variable across all constraints.
        surplusVar(i) = -1;     % Set its i‑th element to -1
        A_aug = [A_aug surplusVar];     % Add the new column to the constraint matrix includes the coefficients of surplus
        c_aug = [c_aug; 0];     % Add a zero to cost vector representing the reduced cost of surplus in OF
        varNames{end+1} = sprintf('s%d', slackCount);   % Add surplus variable name to variable name dictionary
        
        % Artificial variable
        artifVar = zeros(numCons,1);    % This vector will represent the coefficients of the new artificial variable across all constraints
        artifVar(i) = 1;    % Set its i‑th element to -1
        A_aug = [A_aug artifVar];   % Add the new column to the constraint matrix includes the coefficients of artificial
        c_aug = [c_aug; -M]; % subtracting Big M for maximization
        varNames{end+1} = sprintf('a%d', artifCount);   % Add atrificial variable name to variable name dictionary

    elseif strcmp(eqSigns{i}, '=')

        % Add an artificial variable if needed.
        artifCount = artifCount + 1;
        artifVar = zeros(numCons,1);
        artifVar(i) = 1;
        A_aug = [A_aug artifVar];
        c_aug = [c_aug; -M]; % Big M penalty
        varNames{end+1} = sprintf('a%d', artifCount);

    end
end

%% Building the Initial Tableau
[numCons, totalVars] = size(A_aug);     % Number of constraints and varibales after standardization
tableau = [ -c_aug' , 0; A_aug, b];     % Creating the Tableau
basicIdx = (numVars + 1):totalVars;     % Indices of the basic variables which are from the column number (number of original variables + 1) all the way to the column number (Total Variables)
status = 'Optimal';     % Status flag

%% Simplex Iteration
while true

    % Check optimality: For maximization, all coefficients in row 0 (except RHS) must be >= 0.
    objRow = tableau(1,1:end-1);

    if all(objRow >= 0)

        break;  % optimal reached

    end
    
    % Choose entering variable: Most negative coefficient.
    [minVal, colPivot] = min(objRow);   % The value and the index of the entering variable
    
    % Check unboundedness: All entries in colPivot (below row 0) <= 0.
    column = tableau(2:end, colPivot);
    
    if all(column <= 0)
        status = 'Unbounded';
        optSol = [];
        optVal = [];
        finalTableau = tableau;
        return;
    end
    
    % Ratio test: Compute ratios for positive entries.
    ratios = tableau(2:end, end) ./ column;
    % Only consider rows with positive coefficients.
    ratios(column <= 0) = inf;
    [minRatio, rowPivotRel] = min(ratios);
    rowPivot = rowPivotRel + 1;     % Because ratios was computed from rows 2:end of the tableau, we add 1 to the relative index (rowPivotRel) to get the correct row index in the complete tableau.
    
    % Pivot on (rowPivot, colPivot)
    pivotElement = tableau(rowPivot, colPivot);
    tableau(rowPivot, :) = tableau(rowPivot, :) / pivotElement;     % Making the coeff of pivot element equal to 1
    
    % Eliminate the entering variable from other rows.
    for i = 1:size(tableau,1)
        if i ~= rowPivot
            tableau(i, :) = tableau(i, :) - tableau(i, colPivot) * tableau(rowPivot, :);
        end
    end
    
    % Update basic variable: replace variable leaving in rowPivot with entering variable.
    basicIdx(rowPivot - 1) = colPivot;    % -1 because the number of tableau rows is greater by amount of 1 than Basic Index vector (because of row 0 in tableau) 
end

%% Extract Optimal Solution
optSol = zeros(totalVars, 1);

% For each basic row, set the variable equal to RHS.
for i = 1:length(basicIdx)
    optSol(basicIdx(i)) = tableau(i+1, end);
end

optVal = tableau(1, end);

% Check for alternative optimal solutions: Only check nonbasic variables.
nonbasicIdx = setdiff(1:(totalVars), basicIdx);  % indices of nonbasic variables

if any(abs(tableau(1, nonbasicIdx)) < 1e-8)
    fprintf('Alternative optimal solutions exist.\n');
end

% Check infeasibility: If any artificial variable is positive in the final solution, the LP is infeasible.
artifIndices = find(startsWith(varNames, 'a'));  % find indices of variables whose names start with 'a'

if ~isempty(artifIndices) && any(optSol(artifIndices) > 1e-8)
    status = 'Infeasible';
    fprintf('The problem is infeasible because an artificial variable is positive.\n');
    return;
end

% Check nonnegativity: All variables must be >= 0.
if any(optSol < -1e-8)
    status = 'Infeasible';
    fprintf('Infeasibility detected: Some variables in the solution are negative.\n');
    finalTableau = tableau;
    return;
end

finalTableau = tableau;
fprintf('Optimal solution:\n');
for i = 1:totalVars
    fprintf('%s = %.4f\n', varNames{i}, optSol(i));
end
fprintf('Optimal objective value: %.4f\n', optVal);
fprintf('Status: %s\n', status);
fprintf('Final Tableau:\n');
disp(finalTableau);

end