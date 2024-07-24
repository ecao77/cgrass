%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: updates the target point positions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function targets = update_Target_Point_Positions(dt, current_time, targets)
    % Extract columns from the targets matrix
    IDs = targets(:, 1);      % Lagrangian Point IDs
    xPts = targets(:, 2);     % Original x-Coordinates of target points
    yPts = targets(:, 3);     % Original y-Coordinates of target points
    kStiffs = targets(:, 4);  % Stiffness values for each target point

    N_target = length(targets(:, 1));  % Total number of target points

    % Read in the initial positions of the points from a file
    [xP1, yP1] = read_File_In('All_Positions.txt');

    % Loop over all target points
    for i = 1:60
        x = xP1(i);
        y = yP1(i);
        t = current_time;

        if i <= 30 % mantle
            if y > 10
                xPts(IDs(i)) = x;
                yPts(IDs(i)) = sqrt((32 - x) / (1.2 - 0.5 * cos(2 * pi * t))) + 10;
            else
                xPts(IDs(i)) = x;
                yPts(IDs(i)) = -1 * sqrt((32 - x) / (1.2 - 0.5 * cos(2 * pi * t))) + 10;
            end
        elseif i <= 50 % siphon
            xPts(IDs(i)) = x;
            yPts(IDs(i)) = (5.6 + 0.6 * cos(2 * pi * t)) / (1 + exp(-x + 10)) + 7.4 - 0.6 * cos(2 * pi * t);
        end
        % Update the targets matrix
        targets(IDs(i), 2) = xPts(IDs(i));
        targets(IDs(i), 3) = yPts(IDs(i));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: reads in info from file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x1, y1] = read_File_In(file_name)
    filename = file_name;  % Name of the file to read in
    fileID = fopen(filename, 'r');  % Open the file

    % Check if the file opened successfully
    if fileID == -1
        error('File could not be opened: %s', filename);
    end

    % Read the data from the file
    C = textscan(fileID, '%f %f', 'CollectOutput', 1);
    fclose(fileID);  % Close the file

    mat_info = C{1};  % Store the read data

    % Extract x and y coordinates from the data
    x1 = mat_info(:, 1);
    y1 = mat_info(:, 2);
end
