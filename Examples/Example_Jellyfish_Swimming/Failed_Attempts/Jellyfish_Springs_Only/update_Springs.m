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
%	4. Muscle-Model (combined Force-Length-Velocity model, "Hill+(Length-Tension)")
%
% One is able to update those Lagrangian Structure parameters, e.g., spring constants, resting lengths, etc
% 
% There are a number of built in Examples, mostly used for teaching purposes. 
% 
% If you would like us to add a specific muscle model, please let Nick (nick.battista@unc.edu) know.
%
%--------------------------------------------------------------------------------------------------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: updates the spring attributes!
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function springs_info = update_Springs(dt,current_time,xLag,yLag,springs_info)

%springs_info: col 1: starting spring pt (by lag. discretization)
%              col 2: ending spring pt. (by lag. discretization)
%              col 3: spring stiffness
%              col 4: spring resting lengths

%RL = springs_info(:,4); % resting-length vector

dist = 8.649829e-02; %coming from Jellyfish.m (distance between ends of jellyfish bell)

distVec = [8.660254e-02
8.829346e-02
8.985511e-02
9.129139e-02
9.260716e-02
9.380641e-02
9.489209e-02
9.586726e-02
9.673485e-02
9.749671e-02
9.815495e-02
9.871098e-02
9.916637e-02
9.952229e-02
9.977934e-02
9.993819e-02
9.999924e-02
9.996260e-02
9.982821e-02
9.959568e-02
9.926457e-02
9.883399e-02
9.830305e-02
9.767028e-02
9.693457e-02];

% CHANGE RESTING LENGTH BTWN SIDES OF JELLYFISH BELL
for i=1:length(distVec)
    %springs_info(107+(i-1),4) = distVec(i)*abs( cos(4*pi*current_time) );
    springs_info(107+(i-1),4) = distVec(i) * ( 1 - 0.75*( sin(4*pi*current_time) ) );
end
