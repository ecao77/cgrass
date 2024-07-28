# Cordgrass

This repository contains the code for the cordgrass fluid simulation. The purpose of the simulation is 
to model the movement of cordgrass under storm surge fluid flows, characterized by high fluid velocity
and water levels, to compare the capabilities of different naturally occurring height-density combinations 
of cordgrass meadows in salt marshes.

### File Structure

```/Examples``` - sample simulations

```/Cordgrass``` - folder for cordgrass-specific files
- ```channel.beam``` - lagrangian point IDs for each torsional spring (beam). These model cordgrass plants.
- ```channel.target``` - lagrangian point IDs for each rigid target point. These model cordgrass bases and channel walls.
- ```channel.vertex``` - coordinates of all points.
- ```gen.py``` - script that generates ```.beam```, ```.target```, ```.vertex``` files for given plant height and density.
- ```input2d``` - inputs for the fluid simulation.
- ```main2d.m``` - program that executes the simulation.
- ```please_Compute_External_Forcing.m``` - auxiliary program that exerts the fluid force.
- ```viz.py``` - script that visualizes the points in ```channel.vertex```.

```/IBM_Blackbox``` - fluid simulator. Credit: Prof. Nicholas Battista.