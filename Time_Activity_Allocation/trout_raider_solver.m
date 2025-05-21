function [max_fish, path] = trout_raider_solver(num_lakes, total_time, r, travel_time, start_lake)
    % Ensure the inputs are valid
    if start_lake < 1 || start_lake > num_lakes
        error('Invalid starting lake. It must be between 1 and %d.', num_lakes);
    end
    
    % Initialize DP table (f(i,d))
    f = zeros(num_lakes, total_time + 1);
    
    % Compute the maximum possible d for each lake based on the starting lake
    max_d = total_time - 1 - travel_time(start_lake, :);
    max_d(start_lake) = total_time; % The starting lake has full d range
    
    % Compute f(i,d) using dynamic programming
    for d = 1:total_time
        for i = 1:num_lakes
            % Check if d is within valid range for lake i
            if d > max_d(i)
                continue;
            end
            
            % Compute f(i,d) using the recursive formula
            max_val = 0;
            for j = 1:num_lakes
                if j ~= i
                    remaining_time = d - (1 + travel_time(i, j));
                    if remaining_time >= 0
                        max_val = max(max_val, f(j, remaining_time + 1));
                    end
                end
            end
            f(i, d + 1) = r(i) + max_val;
        end
    end
    
    % Get the optimal solution
    max_fish = f(start_lake, total_time + 1);
    
    % Backtracking to find optimal path
    i = start_lake;
    d = total_time;
    path = [start_lake]; % Start at the given starting lake
    while d > 0
        best_j = -1;
        best_val = -1;
        for j = 1:num_lakes
            if j ~= i
                remaining_time = d - (1 + travel_time(i, j));
                if remaining_time >= 0 && f(j, remaining_time + 1) > best_val
                    best_val = f(j, remaining_time + 1);
                    best_j = j;
                end
            end
        end
        if best_j == -1
            break; % No valid move, stop backtracking
        end
        path = [path, best_j];
        d = d - (1 + travel_time(i, best_j));
        i = best_j;
    end
end
