%-------------------------------------------------------------------------------------------------------------------%
%
% IB2d is an Immersed Boundary Code (IB) for solving fully coupled non-linear 
% 	fluid-structure interaction models. This version of the code is based off of
%	Peskin's Immersed Boundary Method Paper in Acta Numerica, 2002.
%
% Author: Nicholas A. Battista
% Email:  nick.battista@unc.edu
% Date Created: May 27th, 2015
% Institution: UNC-CH
%
% This code is capable of creating Lagrangian Structures using:
% 	1. Springs
% 	2. Beams (*torsional springs)
% 	3. Target Points
%	4. Muscle-Model (combined Force-Length-Velocity model, "HIll+(Length-Tension)")
%
% One is able to update those Lagrangian Structure parameters, e.g., spring constants, resting %%	lengths, etc
% 
% There are a number of built in Examples, mostly used for teaching purposes. 
% 
% If you would like us %to add a specific muscle model, please let Nick (nick.battista@unc.edu) know.
%
%--------------------------------------------------------------------------------------------------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: creates the BEAM-EXAMPLE geometry and prints associated input files
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Beam_and_Cells()

%
% Grid Parameters (MAKE SURE MATCHES IN input2d !!!)
%
Nx = 256;        % # of Eulerian Grid Pts. in x-Direction (MUST BE EVEN!!!) %NOTE: MAY BE DIFFERENT THAN INPUT2D FILE!
Ny = 256;        % # of Eulerian Grid Pts. in y-Direction (MUST BE EVEN!!!) %NOTE: MAY BE DIFFERENT THAN INPUT2D FILE!
Lx = 1.0;        % Length of Eulerian Grid in x-Direction
Ly = 1.0;        % Length of Eulerian Grid in y-Direction


% Immersed Structure Geometric / Dynamic Parameters %
N = 2*Nx;        % Number of Lagrangian Pts. (2x resolution of Eulerian grid)
Ln = 0.1;        % Length of nematocyst 
ds = Lx/(2*Nx);  % Lagrangian spacing
struct_name = 'Nematocyst'; % Name for .vertex, .spring, .beam, .target, etc files.
r = 0.05;        % radii of circular cell
x0 = 0.5;        % x-Center for cell
y0 = 0.75;       % y-Center for cell

% Call function to construct geometry
[xLag,yLag] = give_Me_Immsersed_Boundary_Geometry(N,Lx,Ln);              % GIVES NEMATOCYST
[xLag2,yLag2] = give_Me_Immsersed_Boundary_Geometry_Cell(ds,r,x0,y0);    % GIVES CELL

% Shift Geometry Over for Rectangular Grid [0,Lx]x[0,Ly] -> [0,Lx/4]x[0,Ly]
xLag = xLag- Lx/2 + Lx/8;
xLag2= xLag2- Lx/2 + Lx/8;

% Plot Geometry to test
plot(xLag,yLag,'r-'); hold on;
plot(xLag,yLag,'*'); hold on;
plot(xLag2,yLag2,'b-'); hold on;
plot(xLag2,yLag2,'*'); hold on;
xlabel('x'); ylabel('y');
axis([0 Ly/4 0 Ly]);

% BOOK KEEPING FOR PRINTING INPUT FILES
len_beam = length(xLag);                    % # of nematocyst pts
xLag = [xLag xLag2]; yLag = [yLag yLag2];   % # combine into single vector

% Prints .vertex file!
print_Lagrangian_Vertices(xLag,yLag,struct_name);

% Prints .spring file! 
k_Spring = 5e5; ds_Rest = ds;
print_Lagrangian_Springs(xLag,yLag,k_Spring,ds_Rest,struct_name,len_beam)


% Prints .beam file! (TORSIONAL SPRINGS)
%k_Beam = 5.0e11; C = 0.0;
%print_Lagrangian_Beams(xLag(1:len_beam),yLag(1:len_beam),k_Beam,C,struct_name)


% Prints .nonInv_beam file! (NON-INVARIANT))
k_Beam = 1.0e7; 
print_Lagrangian_nonInv_Beams(xLag,yLag,k_Beam,struct_name,len_beam)

% Prints .target file! 
k_Target = 1.75e7;
print_Lagrangian_Target_Pts(xLag(1:len_beam),k_Target,struct_name)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: prints VERTEX points to a file called rubberband.vertex
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
% FUNCTION: prints TARGET points to a file called <structure>.target
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function print_Lagrangian_Target_Pts(xLag,k_Target,struct_name)

    N = length(xLag);     % should be inputted only nematocyst points

    target_fid = fopen([struct_name '.target'], 'w');

    fprintf(target_fid, '%d\n', N );
    for s = 1:N
        fprintf(target_fid, '%d %1.16e\n', s, k_Target);
    end   

    fclose(target_fid); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: prints BEAM (NON-INVARIANT) points to a file called <structure>.target
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function print_Lagrangian_nonInv_Beams(xLag,yLag,k_Beam,struct_name,lag_beam)

    % k_Beam: beam stiffness
    % C: beam curvature
    % lag_beam: # of points on nematocyst for bookkeeping
    
    Ntot = length(xLag);        %  # of Lagrangian pts on cell
    Nc = length(xLag)-lag_beam; %  # of Lagrangian pts on cell


    beam_fid = fopen([struct_name '.nonInv_beam'], 'w');

    fprintf(beam_fid, '%d\n', Nc  );

    %spring_force = kappa_spring*ds/(ds^2);

    %BEAMS BETWEEN VERTICES ON CELL
    for s = lag_beam+1:Ntot
            if  s == lag_beam+1
                left = Ntot;
                mid = s;
                right = s+1;
                xBeam = xLag(left)-2*xLag(mid)+xLag(right);
                yBeam = yLag(left)-2*yLag(mid)+yLag(right);
                fprintf(beam_fid, '%d %d %d %1.16e %1.16e %1.16e\n',Ntot, s, s+1, k_Beam, xBeam, yBeam);  
            elseif s == Ntot
                %Case s=N
                left = s-1;
                mid = s;
                right = Ntot;
                xBeam = xLag(left)-2*xLag(mid)+xLag(right);
                yBeam = yLag(left)-2*yLag(mid)+yLag(right);
                fprintf(beam_fid, '%d %d %d %1.16e %1.16e %1.16e\n',s-1, s, Ntot,   k_Beam, xBeam, yBeam);
            else
                left = s-1;
                mid = s;
                right = s+1;
                xBeam = xLag(left)-2*xLag(mid)+xLag(right);
                yBeam = yLag(left)-2*yLag(mid)+yLag(right);
                fprintf(beam_fid, '%d %d %d %1.16e %1.16e %1.16e\n',s-1, s, s+1,   k_Beam, xBeam, yBeam);
            end        
    end
    fclose(beam_fid); 
    
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: prints BEAM (Torsional Spring) points to a file called <structure>.target
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function print_Lagrangian_Beams(xLag,yLag,k_Beam,C,struct_name)

    % k_Beam: beam stiffness
    % C: beam curvature
    
    N = length(xLag); % NOTE: Total number of beams = Number of Total Lag Pts. - 2

    beam_fid = fopen([struct_name '.beam'], 'w');

    fprintf(beam_fid, '%d\n', N-2 );

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
% FUNCTION: prints SPRING points to a file called <structure>.target
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function print_Lagrangian_Springs(xLag,yLag,k_Spring,ds_Rest,struct_name,len_beam)

    Ntot = length(xLag);        %  # of Lagrangian pts on cell
    Nc = length(xLag)-len_beam; %  # of Lagrangian pts on cell
    
    spring_fid = fopen([struct_name '.spring'], 'w');

    fprintf(spring_fid, '%d\n', Nc );

    %spring_force = kappa_spring*ds/(ds^2);

    %SPRINGS BETWEEN VERTICES ON BEAM
    for s=len_beam+1:Ntot
            if s < Ntot        
                fprintf(spring_fid, '%d %d %1.16e %1.16e\n', s, s+1, k_Spring, ds_Rest);  
            else
                fprintf(spring_fid, '%d %d %1.16e %1.16e\n', Ntot, len_beam+1, k_Spring, ds_Rest);
            end
    end
    fclose(spring_fid); 

    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: creates the Lagrangian structure geometry
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xLag,yLag] = give_Me_Immsersed_Boundary_Geometry(N,Lx,Ln)

% The immsersed structure is a curved line %
ds = Lx/(2*N);

Npts = floor(0.5*Ln/ds);

yLag = linspace(-Ln/2,Ln/2,Npts+1);
xLag = 0.5*ones(1,length(yLag));

yLag = yLag + 0.25;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: creates the Lagrangian structure geometry
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xLag,yLag] = give_Me_Immsersed_Boundary_Geometry_Cell(ds,r,x0,y0)

    % ds:      Lagrangian spacing
    % r:       radius
    % (x0,y0): center of circle

Npts = floor(2*pi*r/ds);
theta = linspace(0,2*pi,Npts+1);
theta = theta(1:end-1);

% The immsersed structure is an ellipse %
for i=1:Npts
    
    xLag(i) = x0 + r * cos( theta(i) );
    yLag(i) = y0 + r * sin( theta(i) );
    
end

