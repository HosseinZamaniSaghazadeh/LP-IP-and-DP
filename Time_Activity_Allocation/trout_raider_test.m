num_lakes = 4;
total_time = 12;
r = [3, 7, 5, 9]; 
travel_time = [0 2 3 4;
               2 0 1 2;
               3 1 0 3;
               4 2 3 0];
start_lake = 1;

[max_fish, path] = trout_raider_solver(num_lakes, total_time, r, travel_time, start_lake);

disp('Optimal number of fish caught:');
disp(max_fish);

disp('Optimal fishing path:');
disp(path);