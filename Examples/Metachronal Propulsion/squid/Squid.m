function Squid()

% Grid Parameters (MAKE SURE MATCHES IN input2d !!!)
Nx = 240;        % Number of Eulerian Grid Points in the x-Direction (Must be Even)
Ny = 120;         % Number of Eulerian Grid Points in the y-Direction (Must be Even)
Lx = 15.0;        % Length of the Eulerian Grid in the x-Direction
Ly = 10.0;        % Length of the Eulerian Grid in the y-Direction
dsOrig = 0.5 * 15.0/100; % Original distance scaling factor
ds = 0.5 * Lx/Nx; % Distance scaling factor based on grid resolution

% Immersed Structure Geometric / Dynamic Parameters
N = 2 * Nx;      % Number of Lagrangian Points (Twice the resolution of the Eulerian grid)
ds_Rest = 0;     % Resting length of the springs
struct_name = 'squid'; % Name prefix for .vertex, .spring, etc files

% Call function to construct geometry
[x1, y1] = IB_Phase_1(Lx, Nx);
Nb1 = length(x1); % Number of points in the power stroke phase
disp("Power Stroke Points: " + Nb1);

% Plot Geometry to test BEFORE taking out points
figure(1)
plot(x1, y1, 'k-'); hold on;
plot(x1, y1, 'k.'); hold on;
xlabel('x'); ylabel('y');
x0 = 10;
y0 = 10;
width = 600;
height = 300;
set(gcf, 'position', [x0, y0, width, height])
xlim([0 40])
ylim([0 20])

% Print vertices to file
please_Print_Vertices_To_File(x1, y1)

% Prints .vertex file
print_Lagrangian_Vertices(x1, y1, struct_name);

% Prints .target file with stiffness scaling
STIFFNESS = 5e5;
% SCALED_STIFFNESS = STIFFNESS * (dsOrig/ds)^2;
SCALED_STIFFNESS = STIFFNESS;
print_Lagrangian_Target_Pts(x1, SCALED_STIFFNESS, struct_name);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION: Prints VERTEX points to a file called struct_name.vertex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function print_Lagrangian_Vertices(xLag, yLag, struct_name)
    N = length(xLag);
    vertex_fid = fopen([struct_name '.vertex'], 'w');
    fprintf(vertex_fid, '%d\n', N);

    % Loops over all Lagrangian Points
    for s = 1:N
        X_v = xLag(s);
        Y_v = yLag(s);
        fprintf(vertex_fid, '%1.16e %1.16e\n', X_v, Y_v);
    end

    fclose(vertex_fid);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION: Prints Target points to a file called struct_name.target
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function print_Lagrangian_Target_Pts(xLag, k_Target, struct_name)
    N = length(xLag);
    target_fid = fopen([struct_name '.target'], 'w');
    fprintf(target_fid, '%d\n', N);

    % Loops over all Lagrangian Points
    for s = 1:N
        fprintf(target_fid, '%d %1.16e\n', s, k_Target);
    end

    fclose(target_fid);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION: Creates the initial Lagrangian structure geometry UPDATED FOR SQUID
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xLag, yLag] = IB_Phase_1(Lx, Nx)
    struct_name5 = 'squid_body';
    [~, x1, y1] = read_Vertex_Points(struct_name5);

    xLag = x1;
    yLag = y1;

    for i = 1:length(xLag) % Loops over all target points!
        x = xLag(i);
        y = yLag(i);
        t = 0;

        if i <= 30 % mantle
            if(y > 10) 
                yLag(i) = sqrt((32-x) / (1.2 - 0.5 * cos(2 * pi * t))) + 10;
            else 
                yLag(i) = -1 * sqrt((32-x) / (1.2 - 0.5 * cos(2 * pi * t))) + 10;
            end
        elseif i <= 50 % siphon
            yLag(i) = (5.6 + 0.6 * cos(2 * pi * t)) / (1 + exp(-x+10)) + 7.4 - 0.6 * cos(2 * pi * t);
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION: Prints all Vertices to File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function please_Print_Vertices_To_File(X1, Y1)
    fileID = fopen('All_Positions.txt', 'w');
    for j = 1:length(X1)
        fprintf(fileID, '%1.16e %1.16e\n', X1(j), Y1(j));
    end
    fclose(fileID);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION: Reads in the number of vertex points and all the vertex points
%           from the .vertex file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [N, xLag, yLag] = read_Vertex_Points(struct_name)
    filename = [struct_name '.vertex'];
    fileID = fopen(filename);
    C = textscan(fileID, '%f %f', 'CollectOutput', 1);
    fclose(fileID);

    vertices = C{1}; % Stores all read in data in vertices (N+1,2) array
    N = vertices(1, 1); % Number of Lagrangian Points
    xLag = zeros(N, 1); % Initialize storage for Lagrangian Points
    yLag = xLag;        % Initialize storage for Lagrangian Points

    for i = 1:N
        xLag(i, 1) = vertices(i + 1, 1); % Stores x-values of Lagrangian Mesh
        yLag(i, 1) = vertices(i + 1, 2); % Stores y-values of Lagrangian Mesh
    end
