function main2d()

warning('off','all');
addpath('../IBM_Blackbox/','../../IBM_Blackbox/','../../../IBM_Blackbox/','../../../../IBM_Blackbox/');
assert( exist( 'IBM_Driver.m', 'file' ) == 2, 'IBM_Driver.m not found -> Please check path to IBM_Blackbox in main2d.m!' );

[Fluid_Params, Grid_Params, Time_Params, Lag_Struct_Params, Output_Params, Lag_Name_Params,Con_Params] = please_Initialize_Simulation();

[X, Y, U, V, xLags, yLags] = IBM_Driver(Fluid_Params,Grid_Params,Time_Params,Lag_Struct_Params,Output_Params,Lag_Name_Params,Con_Params);


fprintf('\n\n');
fprintf(' |****** IMMERSED BOUNDARY SIMULATION HAS FINISHED! ******|\n\n')

function [params,struct_name] = give_Me_input2d_Parameters()

filename= 'input2d';  %Name of file to read in

fileID = fopen(filename);
    C1 = textscan(fileID,'%s %s %f','CollectOutput',1,'CommentStyle','%');
    C2 = textscan(fileID,'%s %s %s','CollectOutput',1,'CommentStyle','%');
fclose(fileID);

params = C1{2};
struct_name = C2{1,1};