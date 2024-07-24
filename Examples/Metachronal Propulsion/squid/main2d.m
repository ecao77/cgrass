%-------------------------------------------------------------------------------------------------------------------%
%
% IB2d is an Immersed Boundary Code (IB) for solving fully coupled non-linear 
% fluid-structure interaction models. This version of the code is based on
% Peskin's Immersed Boundary Method Paper in Acta Numerica, 2002.
%
% This code is capable of creating Lagrangian Structures using:
%   1. Springs
%   2. Beams (*torsional springs)
%   3. Target Points
%   4. Muscle-Model (combined Force-Length-Velocity model, "Hill+(Length-Tension)")
%
% One is able to update those Lagrangian Structure parameters, e.g., spring constants, resting lengths, etc.
% 
%--------------------------------------------------------------------------------------------------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: main2d is the function that gets called to run the code. It
%           reads in parameters from the input2d file and passes 
%           them to the IBM_Driver function to run the simulation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function main2d()

% This is the "main" function, which initializes the Immersed Boundary
% Simulation. It reads in all the parameters from "input2d" and sends them
% to the "IBM_Driver.m" function to actually perform the simulation.

%
% Path Reference to where Driving code is found
%
warning('off', 'all');
addpath('../IBM_Blackbox/', '../../IBM_Blackbox/', '../../../IBM_Blackbox/', '../../../../IBM_Blackbox/');

%
% THROW ERROR TO CORRECT PATH IF DRIVER IS NOT FOUND
%
assert(exist('IBM_Driver.m', 'file') == 2, 'IBM_Driver.m not found -> Please check path to IBM_Blackbox in main2d.m!');

%
% READ-IN INPUT PARAMETERS
%
[Fluid_Params, Grid_Params, Time_Params, Lag_Struct_Params, Output_Params, Lag_Name_Params, Con_Params] = please_Initialize_Simulation();

%
%-%-%-% DO THE IMMERSED BOUNDARY SOLVE!!!!!!!! %-%-%-%
%
[X, Y, U, V, xLags, yLags] = IBM_Driver(Fluid_Params, Grid_Params, Time_Params, Lag_Struct_Params, Output_Params, Lag_Name_Params, Con_Params);

%
% Print that the simulation has completed.
%
fprintf('\n\n');
fprintf(' |****** IMMERSED BOUNDARY SIMULATION HAS FINISHED! ******|\n\n')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Function to read in input files from "input2d" -> renames all
% quantities appropriately, just as they are in the input file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [params, struct_name] = give_Me_input2d_Parameters()

filename = 'input2d';  % Name of the file to read in

fileID = fopen(filename); % Opens file for 'textscan' function

% Read in the file, use 'CollectOutput' to gather all similar data together
% and 'CommentStyle' to skip lines in the file.
C1 = textscan(fileID, '%s %s %f', 'CollectOutput', 1, 'CommentStyle', '%');
C2 = textscan(fileID, '%s %s %s', 'CollectOutput', 1, 'CommentStyle', '%');

fclose(fileID);

params = C1{2}; % Extract parameters from the first textscan output

struct_name = C2{1, 1}; % Extract structure name from the second textscan output
