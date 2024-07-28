# file structure
```/Examples``` sample simulations.
&nbsp; ```/Cordgrass``` folder for cordgrass-specific files.
&nbsp; &nbsp; ```channel.beam``` lagrangian point IDs for each torsional spring (beam). these model cordgrass plants.
&nbsp; &nbsp; ```channel.target``` lagrangian point IDs for each rigid target point. these model cordgrass bases and channel walls.
&nbsp; &nbsp; ```channel.vertex``` coordinates of all points.
&nbsp; &nbsp; ```gen.py``` script that generates ```.beam```, ```.target```, ```.vertex``` files for given plant height and density.
&nbsp; &nbsp; ```input2d``` inputs for the fluid simulation
&nbsp; &nbsp; ```main2d.m``` program that executes the simulation
&nbsp; &nbsp; ```please_Compute_External_Forcing.m``` auxiliary program that exerts the fluid force
&nbsp; &nbsp; ```viz.py``` script that visualizes the points in ```channel.vertex```.
```/IBM_Blackbox``` fluid simulator. Credit: Prof. Nicholas Battista.