function [maxValue, selectedItems] = knapsack(values, weights, capacity)
    % Knapsack Problem - Dynamic Programming Solution
    % Inputs:
    %   values - array of item benefits
    %   weights - array of item weights
    %   capacity - total knapsack capacity
    % Outputs:
    %   maxValue - maximum possible benefit
    %   selectedItems - array showing the number of each item selected

    % Number of items
    num_items = length(values);

    % Initialize benefit table
    f = zeros(num_items + 1, capacity + 1);  % Rows: items (0 to num_items), Cols: weight capacity (0 to capacity)

    % Backward computation for stages 2 to num_items
    for t = num_items:-1:2
        for d = 0:capacity
            max_xt = floor(d / weights(t));  % Possible xt values for item t
            best_value = 0;
            for xt = 0:max_xt
                remaining_weight = d - weights(t) * xt;
                value = values(t) * xt + f(t + 1, remaining_weight + 1);
                if value > best_value
                    best_value = value;
                end
            end
            f(t, d + 1) = best_value;
        end
    end

    % Compute only f_1(capacity)
    best_value = 0;
    best_x1 = 0;
    max_x1 = floor(capacity / weights(1));  % Possible x1 values for item 1
    for x1 = 0:max_x1
        remaining_weight = capacity - weights(1) * x1;
        value = values(1) * x1 + f(2, remaining_weight + 1);
        if value > best_value
            best_value = value;
            best_x1 = x1;
        end
    end

    % Retrieve the optimal solution
    maxValue = best_value;
    selectedItems = zeros(1, num_items);
    selectedItems(1) = best_x1;
    remaining_weight = capacity - weights(1) * best_x1;

    % Backward tracking to find the optimal item selection for t = 2 to num_items
    for t = 2:num_items
        for xt = 0:floor(remaining_weight / weights(t))
            if f(t, remaining_weight + 1) == values(t) * xt + f(t + 1, remaining_weight - weights(t) * xt + 1)
                selectedItems(t) = xt;
                remaining_weight = remaining_weight - weights(t) * xt;
                break;
            end
        end
    end
end
