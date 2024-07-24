function Crustacean()

%
% Grid Parameters (MAKE SURE MATCHES IN input2d !!!)
%
Nx =  230;       % # of Eulerian Grid Pts. in x-Direction (MUST BE EVEN!!!)
Ny =  46;        % # of Eulerian Grid Pts. in y-Direction (MUST BE EVEN!!!)
Lx = 3.0;        % Length of Eulerian Grid in x-Direction
Ly = 0.6;        % Length of Eulerian Grid in y-Direction
dsOrig = 0.5 * 3.0/100;
ds = 0.5 * Lx/Nx;

% Immersed Structure Geometric / Dynamic Parameters %
N = 2*Nx;        % Number of Lagrangian Pts. (2x resolution of Eulerian grid)
ds_Rest = 0;     % Resting length of springs
struct_name = 'shrimp'; % Name for .vertex, .spring, etc files.


% Call function to construct geometry
[x1,y1] = IB_Phase_1(Lx,Nx);
Nb1 = length(x1);
disp("Power Stroke Points: " + Nb1);

% Plot Geometry to test BEFORE taking out pts.
figure(1)
plot(x1,y1,'k-'); hold on;
plot(x1,y1,'k.'); hold on;
xlabel('x'); ylabel('y');
x0=10;
y0=10;
width=1500;
height=300;
set(gcf,'position',[x0,y0,width,height])
xlim([0 3])
ylim([0 0.6])

please_Print_Vertices_To_File(x1,y1)

% Prints .vertex file!
print_Lagrangian_Vertices(x1,y1,struct_name);

% Prints .target file!
STIFFNESS = 1e9;
SCALED_STIFFNESS = STIFFNESS * (dsOrig/ds)^2;
print_Lagrangian_Target_Pts(x1,SCALED_STIFFNESS,struct_name);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: prints VERTEX points to a file called shrimp.vertex
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function print_Lagrangian_Vertices(xLag,yLag,struct_name)

    N = length(xLag);

    vertex_fid = fopen([struct_name '.vertex'], 'w');

    fprintf(vertex_fid, '%d\n', N );

    %Loops over all Lagrangian Pts.
    for s = 1:N
        X_v = xLag(s);
        Y_v = yLag(s);
        fprintf(vertex_fid, '%1.16e %1.16e\n', X_v, Y_v);
    end

    fclose(vertex_fid); 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: prints Target points to a file called shrimp.target
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function print_Lagrangian_Target_Pts(xLag,k_Target,struct_name)

    N = length(xLag);

    target_fid = fopen([struct_name '.target'], 'w');

    fprintf(target_fid, '%d\n', N );

    %Loops over all Lagrangian Pts.
    for s = 1:N
        fprintf(target_fid, '%d %1.16e\n', s, k_Target);
    end

    fclose(target_fid); 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: creates the initial Lagrangian structure geometry
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xLag,yLag] = IB_Phase_1(Lx,Nx)

struct_name5 = 'shrimp_body';
[~, x1, y1] = read_Vertex_Points(struct_name5);

xLag = [x1];
yLag = [y1];

for i = 1:length(xLag)        % Loops over all target points!

    c               = 0;
    cx              = get_Center(xLag, i);
    cy              = get_yCoord(cx, c); 
    PHI             = 0.010;
    current_time    = 0;
    tP1             = 0.025;
    tP2             = 0.025;
    period          = 0.050;

	r       = get_Distance(cx, cy, xLag(i), yLag(i)); 
    shift   = PHI * (4 - (cx / 0.2));
    t       = rem(current_time - shift + 10*period, period);    % Current time in simulation (modded)

    if  (get_yCoord(xLag(i), c) - yLag(i) > 0.001)  % LEG.

        if (t <= tP1) % IN RANGE OF POWER STROKE 

                xLag(i) = cx + r * cos(5*pi/4 + (pi/2) * (t/tP1));
                yLag(i) = cy + r * sin(5*pi/4+ (pi/2) * (t/tP1));
                
        elseif ((t > tP1) && (t <= (tP1 + tP2)))  	% IN RANGE OF RETURN STROKE
        
                xLag(i) = cx + r * cos(7*pi/4 + (-1*pi/2) * ((t-0.025)/tP2));
                yLag(i) = cy + r * sin(7*pi/4 + (-1*pi/2) * ((t-0.025)/tP2));
        end
    end
end

N = length(xLag)/2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: prints all Vertices to File
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function please_Print_Vertices_To_File(X1,Y1)

fileID = fopen('All_Positions.txt','w');
for j=1:length(X1)
    %fprintf(fileID,'%1.16e %1.16e %1.16e %1.16e\n', X1(j),Y1(j),X2(j),Y2(j) );
    fprintf(fileID,'%1.16e %1.16e\n', X1(j),Y1(j) );

end
fclose(fileID);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: Reads in the # of vertex pts and all the vertex pts from the
%           .vertex file.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [N,xLag,yLag] = read_Vertex_Points(struct_name)

filename = [struct_name '.vertex']; 
fileID = fopen(filename);
C = textscan(fileID,'%f %f','CollectOutput',1);
fclose(fileID);   

vertices = C{1};    %Stores all read in data in vertices (N+1,2) array

N = vertices(1,1);  % # of Lagrangian Pts
xLag = zeros(N,1);  % Initialize storage for Lagrangian Pts.
yLag = xLag;        % Initialize storage for Lagrangian Pts.

for i=1:N
   xLag(i,1) = vertices(i+1,1); %Stores x-values of Lagrangian Mesh
   yLag(i,1) = vertices(i+1,2); %Stores y-values of Lagrangian Mesh
end

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