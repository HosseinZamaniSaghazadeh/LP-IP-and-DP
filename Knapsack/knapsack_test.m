% Define item values (benefits), weights, and knapsack capacity
values = [12, 7, 11];  % Benefits of items
weights = [5, 3, 4];   % Weights of items
capacity = 10;         % Knapsack capacity

% Call the knapsack function
[maxValue, selectedItems] = knapsack(values, weights, capacity);

% Display the results
fprintf('Optimal knapsack benefit: %d\n', maxValue);
fprintf('Optimal item selection:\n');
for i = 1:length(values)
    fprintf('Item %d (Weight %d, Benefit %d): %d units\n', i, weights(i), values(i), selectedItems(i));
end
