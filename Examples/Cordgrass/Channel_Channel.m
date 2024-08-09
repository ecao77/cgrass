%-------------------------------------------------------------------------------------------------------------------%
%
% IB2d is an Immersed Boundary Code (IB) for solving fully coupled non-linear 
% 	fluid-structure interaction models. This version of the code is based off of
%	Peskins Immersed Boundary Method Paper in Acta Numerica, 2002.
%
% Author: Nicholas A. Battista
% Email:  battistn[@]tcnj.edu
% Date Created: May 27th, 2015
% Institution Created: UNC-CH
% Current Institution: TCNJ
%
% This code is capable of creating Lagrangian Structures using numerous fiber models
% 
% There are a number of built in Examples, mostly used for teaching purposes. 
% 
% If you would like us to add a specific muscle model, please let Nick know.
%
%--------------------------------------------------------------------------------------------------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: creates the CHANNEL_CHANNEL-EXAMPLE geometry and prints associated input files
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Channel_Channel(poroDensity, poroHeight)

%------------------------------------------------------------------
% Grid Parameters
%   NOTE: (a) (Ny,Ly) are different in input2d 
%         (b) These values below were used to initialize geometry
%------------------------------------------------------------------
Nx =  128;    % # of Eulerian Grid Pts. in x-Direction (MUST BE EVEN!!!) 512
Ny =  16;    % # of Eulerian Grid Pts. in y-Direction (MUST BE EVEN!!!) 512
Lx = 1.0;     % Length of Eulerian Grid in x-Direction
Ly = 1.0;     % Length of Eulerian Grid in y-Direction

%------------------------------------------------------------------
% Immersed Structure Geometric / Dynamic Parameters %
%------------------------------------------------------------------
ds= 0.5*Lx/Nx;  % Lagrangian spacing used to be 0.5
L = 0.9*Lx;     % Length of Channel
w = 0.15*Ly;    % Width of Channel
struct_name = 'channel'; % Name for .vertex, .spring, etc files.

%------------------------------------------------------------------
% Call function to construct geometry
%------------------------------------------------------------------
[xLag,yLag] = give_Me_Immersed_Boundary_Geometry(ds,L,w,Lx,Ly);
yLag = yLag - 0.375;

%------------------------------------------------------------------
% Give me Poroelastic network
%------------------------------------------------------------------
[xPor, yPor, ind_1st, lenX, lenY] = give_Me_Poroelastic_Geometry(poroDensity, poroHeight, ds,L,w,Lx,Ly,yLag(1),xLag);

%------------------------------------------------------------------
% Plot Geometry (Testing)
%------------------------------------------------------------------
plot(xLag(1:end/2),yLag(1:end/2),'r-'); hold on;
plot(xLag(end/2+1:end),yLag(end/2+1:end),'r-'); hold on;
plot(xPor,yPor,'g*'); hold on;
plot(xLag,yLag,'*'); hold on;
xlabel('x'); ylabel('y');
axis square;

%------------------------------------------------------------------
% Prints .vertex file!
%------------------------------------------------------------------
print_Lagrangian_Vertices([xLag xPor],[yLag yPor],struct_name);

%------------------------------------------------------------------
% Prints .spring file!
%------------------------------------------------------------------
k_Spring = 1e7; % used to be 1e5
print_Lagrangian_Springs(xPor,yPor,xLag,yLag,k_Spring,ds,struct_name,ind_1st,lenX,lenY);

%------------------------------------------------------------------
% Prints .poroelastic file!
%------------------------------------------------------------------
alpha = 5e8;             % Brinkman coefficient 500000
offset = length(xLag);      % # of Channel pts before poroelastic pts in indexing
print_Lagrangian_PoroElastic_Pts(xPor,struct_name,alpha,offset);

%------------------------------------------------------------------
% Prints .beam file!
%------------------------------------------------------------------
%k_Beam = 0.5; C = 0.0;
%print_Lagrangian_Beams(xLag,yLag,k_Beam,C,struct_name);

%------------------------------------------------------------------
% Prints .target file!
%------------------------------------------------------------------
k_Target = 1e6;
print_Lagrangian_Target_Pts(xLag,k_Target,struct_name);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: prints VERTEX points to a file called channel.vertex
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
% FUNCTION: prints POROELASTICITY points to a file called 
%           channel.poroelastic
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function print_Lagrangian_PoroElastic_Pts(xPor,struct_name,alpha,offset)

    N = length(xPor);
    
    % alpha = brinkman coefficient

    poro_fid = fopen([struct_name '.poroelastic'], 'w');

    fprintf(poro_fid, '%d\n', N );

    %Loops over all Lagrangian Pts.
    for ss = 1:N
        s = ss + offset;  
        fprintf(poro_fid, '%d %1.16e\n', s, alpha);
    end

    fclose(poro_fid);     
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: prints Vertex points to a file called channel.target
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
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: prints BEAM (Torsional Spring) points to a file called channel.beam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function print_Lagrangian_Beams(xLag,yLag,k_Beam,C,struct_name)

    % k_Beam: beam stiffness
    % C: beam curvature
    
    N = length(xLag); % NOTE: Total number of beams = Number of Total Lag Pts. - 2

    beam_fid = fopen([struct_name '.beam'], 'w');

    fprintf(beam_fid, '%d\n', N );

    %spring_force = kappa_spring*ds/(ds^2);

    %BEAMS BETWEEN VERTICES
    for s = 2:N-1
            if  s <= N-1         
                fprintf(beam_fid, '%d %d %d %1.16e %1.16e\n',s-1, s, s+1, k_Beam, C);  
            else
                %Case s=N
                fprintf(beam_fid, '%d %d %d %1.16e %1.16e\n',s-1, s, 1,   k_Beam, C);  
            end
    end
    fclose(beam_fid); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: prints SPRING points to a file called channel.spring
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function print_Lagrangian_Springs(xPor,yPor,xLag,yLag,k_Spring,ds,struct_name,ind_1st,lenX,lenY)

    N = lenX*(lenY);
    
    % FOR TESTING SET OFFSET=0 FOR LOGIC, YO!
    offset = length(xLag);       % Offset for total # of channel points (not poroelastic pts)s
    
    spring_fid = fopen([struct_name '.spring'], 'w');

    fprintf(spring_fid, '%d\n', N );

    %SPRINGS BETWEEN VERTICES GOING VERTICAL!
    for i = 1:lenX                   % Loops over X
        for j=1:lenY                 % Loops over Y
            
            s = (i-1)*lenY+offset;   % Gives which vertical arm (from left to right); offset for # of channel pts in indexing
            
            if j==1
                % Going vertical from channel -> 1st node
                channel_ind = ind_1st;
                min_dist = abs(xLag(channel_ind) - xPor((i-1)*lenY+j));
                for k = ind_1st+1:length(xLag)
                    dist = abs(xLag(k) - xPor((i-1)*lenY+j));
                    if dist < min_dist
                        min_dist = dist;
                        channel_ind = k;
                    end
                end
                % disp(channel_ind + " " + s+j);
                % disp( xLag(channel_ind) + " " + yLag(channel_ind));
                % disp( xPor((i-1)*lenY+j) + " " + yPor((i-1)*lenY+j));
                fprintf(spring_fid, '%d %d %1.16e %1.16e\n', channel_ind, s+j, k_Spring, ds);
            else
                % Going Vertical off first node off channel
                fprintf(spring_fid, '%d %d %1.16e %1.16e\n', s+j-1, s+j, k_Spring, ds);  
            end
            
        end
    end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: creates the Lagrangian structure geometry
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xLag,yLag] = give_Me_Immersed_Boundary_Geometry(ds,L,w,Lx,Ly)

% The immsersed structure is a channel %
x = (Lx-L)/2:ds:(L+(Lx-L)/2);  %xPts
yBot = (Ly-w)/2;               %yVal for bottom of Channel
yTop = Ly - (Ly-w)/2;          %yVal for top of Channel

xLag = [x x];
yLag = [yBot*ones(1,length(x)) yTop*ones(1,length(x))];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: creates Poroelastic network
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xPor, yPor, ind_1st, lenX, lenY] = give_Me_Poroelastic_Geometry(poroDensity, poroHeight, ds,L,w,Lx,Ly,yBottom,xLag)

% X CHANNEL PTS: x = (Lx-L)/2:ds:(L+(Lx-L)/2);  %xPts

xStart = 0.45;  xFinish = 0.55;
% poroHeight = w/2.103;
% xVals = xStart:ds:xFinish;
xVals = linspace(xStart, xFinish, poroDensity);
yVals = yBottom+ds:ds:yBottom+poroHeight; % normally ds

% Finds first index for spring attachment :)
not_found = 1; i=0;
while not_found
    i=i+1;
    x=xLag(i);
    if ( x > xStart )
        not_found=0;
        ind_1st = i-1;
    end
end

% Shifts over so pts are lined up
diff = xStart - xLag(ind_1st);
xVals = xVals - diff;

% Computes lengths of vectors
lenX = length(xVals);
lenY = length(yVals);

% Creates vector of repeating y pts
yPor = yVals;
for i=2:lenX
    yPor = [yPor yVals];
end

% Creates vector of repeated stacked x pts
n=1;
for i=1:lenX
    for j=1:lenY
        xPor(n) = xVals(i);
        n=n+1;
    end
end