# AUTO 566 Modeling Analysis & Control of Hybrid Electric Vehciles Project
# $Supermileage$  $Cedar$  $Modeling$
## Authors 
### Vijay Balasekaran   vbalasek@umich.edu
### Savannah Belton     sbelton@umich.edu
### Austin Leiphard     leiphart@umich.edu
### Skylar Lennon       skylarl@umich.edu
### Ryan O'Malley       romalley@umich.edu


# Introduction
This AUTO 566 project involves generating models of varying levels of complexity to capture and predict the dynamic behavior of the next University of Michigan Supermileage vehilce, Cedar. These models will help to make critical architetural decisions about the vehicle as the team undergoes a holistic systems engineering design process. 

This README will walk you through the entire project, allowing you to understand, tweak, and recreate models for similar future vehicles. While I encourage you to explore the repo, there is a natural progression through this repo to build up the drive cycle and vehicle models which is described briefly here:


## DRIVE CYCLE MODELING
A typical drive cycle contains a set of datapoints describing the speed of a vehicle over time. This can then be used to simulate the vehicle under development and estimate how it will perform. 

Some drive cycles also incorporate elevation change into the simulation in order to provide a more accurate representation of typical driving conditions. Within this repo, we will simulate both flat tracks, and tracks with elevation changes.

$Track$ $Modeling$: This section show how we generate track models that are both 2D and 3D. We've developed a [program](/drive_cycle/track_modeling/linear_track_generator.m) that can generate an arbitrary piecewise linear 2D track as well as a [program](/drive_cycle/track_modeling/linearizeTrack.m) that can take real life GPS data and 'flatten it out' to generate a 2D representation of a real life track. The [program](/drive_cycle/track_modeling/nonlinear_track_generator.m) to generate our 3D track models are simply comprised of real life GPS data for anticipated tracks that the Shell Eco Marathon competition may be held at over the next several years. 

$Drive$ $Strategy$ $Modeling$
- TODO


## [TODO] References
- MathWorks: For initial vehicle model which was modified for the purpose of this project. 
- University of Michigan Solar Car For their motor modeling code. 
- Papers we cite
- Explicit references (hyperlinks) to the documents which are cited.