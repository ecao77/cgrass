%-------------------------------------------------------------------------------------------------------------------%
%
% IB2d is an Immersed Boundary Code (IB) for solving fully coupled non-linear 
% 	fluid-structure interaction models. This version of the code is based off of
%	Peskin's Immersed Boundary Method Paper in Acta Numerica, 2002.
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

function Channel_Channel()

%------------------------------------------------------------------
% Grid Parameters
%   NOTE: (a) (Ny,Ly) are different in input2d 
%         (b) These values below were used to initialize geometry
%------------------------------------------------------------------
Nx =  512;    % # of Eulerian Grid Pts. in x-Direction (MUST BE EVEN!!!)
Ny =  512;    % # of Eulerian Grid Pts. in y-Direction (MUST BE EVEN!!!)
Lx = 1.0;     % Length of Eulerian Grid in x-Direction used to be 1.0
Ly = 1.0;     % Length of Eulerian Grid in y-Direction used to be 1.0

%------------------------------------------------------------------
% Immersed Structure Geometric / Dynamic Parameters %
%------------------------------------------------------------------
ds= 2.0*Lx/Nx;  % Lagrangian spacing used to be 0.5*Lx/Nx
L = 10.0*Lx;     % Length of Channel % used to be 0.9
w = 2.0*Ly;    % Width of Channel % used to be 0.15
struct_name = 'channel'; % Name for .vertex, .spring, etc files.

%------------------------------------------------------------------
% Call function to construct geometry
%------------------------------------------------------------------
[xLag,yLag] = give_Me_Immersed_Boundary_Geometry(ds,L,w,Lx,Ly);
yLag = yLag - 0.375;

%------------------------------------------------------------------
% Give me Poroelastic network
%------------------------------------------------------------------
[xPor, yPor, ind_1st, lenX, lenY] = give_Me_Poroelastic_Geometry(ds,L,w,Lx,Ly,yLag(1),xLag);

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
k_Spring = 5e6; % used to be 1e5
print_Lagrangian_Springs(xPor,yPor,xLag,yLag,k_Spring,ds,struct_name,ind_1st,lenX,lenY);

%------------------------------------------------------------------
% Prints .poroelastic file!
%------------------------------------------------------------------
alpha = 2000000;             % Brinkman coefficient % used to be 500000
offset = length(xLag);      % # of Channel pts before poroelastic pts in indexing
print_Lagrangian_PoroElastic_Pts(xPor,struct_name,alpha,offset);

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
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: prints SPRING points to a file called channel.spring
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function print_Lagrangian_Springs(xPor,yPor,xLag,yLag,k_Spring,ds,struct_name,ind_1st,lenX,lenY)

    N = lenY*(lenX-1)+lenX*(lenY);
    
    % FOR TESTING SET OFFSET=0 FOR LOGIC, YO!
    offset = length(xLag);       % Offset for total # of channel points (not poroelastic pts)s
    
    spring_fid = fopen([struct_name '.spring'], 'w');

    fprintf(spring_fid, '%d\n', N );

    %spring_force = kappa_spring*ds/(ds^2);

    %SPRINGS BETWEEN VERTICES GOING VERTICAL!
    for i = 1:lenX                   % Loops over X
        for j=1:lenY                 % Loops over Y
            
            s = (i-1)*lenY+offset;   % Gives which vertical arm (from left to right); offset for # of channel pts in indexing
            
            if j==1
                % Going vertical from channel -> 1st node
                channel_ind = ind_1st + (i-1); % Index of channel attachments
                fprintf(spring_fid, '%d %d %1.16e %1.16e\n', channel_ind, s+j, k_Spring, ds);
            else
                % Going Vertical off first node off channel
                fprintf(spring_fid, '%d %d %1.16e %1.16e\n', s+j-1, s+j, k_Spring, ds);  
            end
            
        end
    end
    
    %SPRINGS BETWEEN VERTICES GOING HORIZONTAL!
    for i = 1:lenY               % Loops over Y
        for j=1:lenX-1           % Loops over X
            
            s1 = 1 + (j-1)*lenY + (i-1) + offset; % Gives LEFT index
            s2 = 1 +   (j)*lenY + (i-1) + offset; % Gives RIGHT index
            
            fprintf(spring_fid, '%d %d %1.16e %1.16e\n', s1, s2, k_Spring, ds);  
            
        end
    end
    fclose(spring_fid); 
    

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

function [xPor, yPor, ind_1st, lenX, lenY] = give_Me_Poroelastic_Geometry(ds,L,w,Lx,Ly,yBottom,xLag)

% X CHANNEL PTS: x = (Lx-L)/2:ds:(L+(Lx-L)/2);  %xPts

xStart = 4.5;  xFinish = 5.5; % used to be 0.45 to 0.55.
poroHeight = 0.688; % we can customize this. used to be w/5. it doesn't matter, but we can do......
poroDensity = 10; % new line by the way
% xVals = xStart:ds:xFinish;
xVals = linspace(xStart, xFinish, poroDensity);
yVals = yBottom+ds:ds:yBottom+poroHeight;

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

% TEST ORDER!
%for i=1:lenX*lenY
%   plot(xPor(i),yPor(i),'*'); hold on;
%   pause(0.1);
%end

