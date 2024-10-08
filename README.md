# Cordgrass

This repository contains the code for a fluid simulation relating to cordgrass, a plant found in 
salt marshes and estuaries. The simulation models the movement of cordgrass under storm surge fluid flows (high fluid velocity
and water levels) to compare the flow-reducing, anti-erosion abilities of cordgrass meadows with different 
biologically realistic height-density combinations.

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