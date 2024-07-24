%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: updates the target point positions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function targets = update_Target_Point_Positions(dt,current_time,targets)

IDs = targets(:,1);                 % Stores Lag-Pt IDs in col vector
xPts= targets(:,2);                 % Original x-Values of x-Target Pts.
yPts= targets(:,3);                 % Original y-Values of y-Target Pts.
kStiffs = targets(:,4);             % Stores Target Stiffnesses 

N_target = length(targets(:,1));    %Gives total number of target pts!

% Period Info
tP1     = 0.025;                        % Power Stroke Period
tP2     = 0.025;                        % Return Stroke Period
period  = tP1+tP2;                      % Period
PHI     = 0.010;                        % Phase Shift
c       = 0;                            % Parabola Constant

% Read In Points!
[xP1,yP1] = read_File_In('All_Positions.txt');

for i = 1:N_target        % Loops over all target points!

    cx = get_Center(xP1, i);                            % x coord of center
    cy = get_yCoord(cx, c);                             % y coord of center
    r = get_Distance(cx, cy, xP1(i), yP1(i));               % Radius of Motion

    shift = PHI * (4 - cx / 0.2);                           % Metachonal Time Shift
    t = rem(current_time - shift + 10 * period, period);    % Current time with respect to period

    if (get_yCoord(xP1(i), c) - yP1(i) > 0.001) % If this coordinate is a leg.

        if (t <= tP1) 	                            % Power Stroke
            arg = 5*pi/4 + (pi/2) * (t/tP1);
			
        elseif ((t > tP1) && (t <= (tP1 + tP2)))    % Return Stroke
            arg = 7*pi/4 + (-1*pi/2) * ((t-tP1)/tP2);
    
        end

        xPts(IDs(i)) = cx + r * cos(arg);
        yPts(IDs(i)) = cy + r * sin(arg);
        targets(IDs(i),2) = xPts(IDs(i)); % Store new xVals
        targets(IDs(i),3) = yPts(IDs(i)); % Store new yVals
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: reads in info from file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x1,y1] = read_File_In(file_name)

filename = file_name;  %Name of file to read in

fileID = fopen(filename);

    % Read in the file, use 'CollectOutput' to gather all similar data together
    % and 'CommentStyle' to to end and be able to skip lines in file.
    C = textscan(fileID,'%f %f','CollectOutput',1);

fclose(fileID);        %Close the data file.

mat_info = C{1};   %Stores all read in data

%Store all elements in matrix
mat = mat_info(1:end,1:end);

x1 =  mat(:,1); %store regular bingo expectation values 
y1 =  mat(:,2); %store inner bingo expectation values 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: gets center from x-coordinate
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [center] = get_Center(xP1, i)
center = 0;
if (xP1(i) > 0.12 && xP1(i) < 0.28)
    center = 0.2;
elseif (xP1(i) > 0.32 && xP1(i) < 0.48)
    center = 0.4;
elseif (xP1(i) > 0.52 && xP1(i) < 0.68)
    center = 0.6;
elseif (xP1(i) > 0.72 && xP1(i) < 0.88)
    center = 0.8;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: gets y-coordinate from x-coordinate and parabola equation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [y] = get_yCoord(x, c)
y = -1 * c * (x - 0.5) * (x - 0.5) + 0.3; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: gets distance between two points.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [d] = get_Distance(x1, y1, x2, y2)
d = sqrt((x1-x2).^2 + (y1-y2).^2);