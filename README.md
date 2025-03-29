# AUTO 566 Modeling Analysis & Control of Hybrid Electric Vehciles Project
# $Supermileage$  $Cedar$  $Modeling$
## Authors 
### Vijay Balasekaran   vbalasek@umich.edu
### Savannah Belton     sbelton@umich.edu
### Austin Leiphard     leiphart@umich.edu
### Skylar Lennon       skylarl@umich.edu
### Ryan O'Malley       romalley@umich.edu


# Introduction
This AUTO 566 project involves generating models of varying levels of complexity to capture and predict the dynamic behavior of the next University of Michigan Supermileage vehilce, Cedar. These models will help to make critical architetural decisions about the vehicle as the team undergoes a holistic systems engineering design process with the effort to win the 2026 and 2027 Shell Eco Marathon (SEM) competition. 

This README will walk you through the entire project, allowing you to understand, tweak, and recreate models for similar future vehicles. While I encourage you to explore the repo in its entirety on your own, there is a natural progression one can take through the project which is described in depth thoughout this README, and summarized here:

1. Model the track
2. Generate a drive strategy
3. Model the vehicle dynamics
4. Model vehicle energy flow
    Battery -> Inverter --> Motor --> Transmission --> Road
5. Simulate & view results
6. Tweak one variable within steps 1-4. 
7. Repeat step 5.

One very important thing to note is that a reverse-modeling strategy is employed. In reverse modeling, the input is the desired vehicle behavior-what we'll refer to as the drive cycle-which defines a speed profile of the vehicle. The drive cycle also encapsulates route (or racing line) the vehicle will drive, including turning and elevation changes. We have anticipated 3 potential courses for the '26 & '27 SEM.

1. **The Streets of Detroit**: This course will be modeled as a flat track with the start-finish line at Huntington Place and taking the following route through the streets of Detroit:

![Detroit Course](media/Detroit_Track_Google_Maps.png)

2. **The Indianapolis Motor Speedway Road course**: This is the track at which the '22, '23, '24, and '25 SEM has been held. While the location of the '26, & '27 SEM unknown (as of 3-29-25) is the most likely candidate. As such, we will model the track including its minor elevation changes, and a manually chosen racing line derrived from heuristics found in [this paper](TODO).

![Indy Road Course](media/indy-road-course-layout.jpg)

3. **The Sonoma Raceway**: We will regard the Sonoma Raceway as the 'worse-case scenario' track. Meaning, Sonoma's relative elevation change of 160 ft dwarfs that of the Indy Road Course and our flat model of the streets of Detroit. Consequentially, racing at Sonoma would yeild the highest power requirements for our system. In a competition where power  

Initial models will only only account for longitudinal (straight line) dynamics and will not account for elevation changes throughout the course (Think ΔX only). The drive cycle will account for the stopping points required for urban concept vehicles at each of the SEM courses. It will optimize vehicle efficiency by experimenting with different speed profiles, including variations of the pulse-and-glide (PnG) strategy defined below. 
[TODO: DEFINE BELOW, hyperlink to the code here as well]

The intermediate models cycles will capture both the longitudinal vehicle dynamics and the courses elevation changes (Think ΔX & ΔY). Again, various speed profiles including PnG will be experimented with in order to optimize efficiency. However, the drive strategy may adapted in order to segment the course to effectively make the most use of the elevation changes by coasting down hills as much as possible. 

Finally, our most advanced models will incorporate both longitudinal and basic lateral changes in elevation of the course into this drive cycle. Even more advanced models will account for the vehicle turns

To be clear on terminology, when referring to the drive cycle, we are referring to .... need to decide on terminology for consistency......
- speed over time
- elevation changes over time
- turning

## DRIVE CYCLE MODELING
A typical drive cycle contains a set of datapoints describing the speed of a vehicle over time. This can then be used to simulate the vehicle under development and estimate how it will perform. 

Some drive cycles also incorporate elevation change into the simulation in order to provide a more accurate representation of typical driving conditions. Within this repo, we will simulate both flat tracks, and tracks with elevation changes.

$Track$ $Modeling$: This section show how we generate track models that are both 2D and 3D. We've developed 3 track modeling programs. The first is a [linear track generator program](/drive_cycle/track_modeling/linear_track_generator.m) that can generate an arbitrary continuous piecewise linear 2D track. The second [program](/drive_cycle/track_modeling/linearizeTrack.m) can take real life GPS data and 'flatten it out' to generate a 2D representation of a 3D track. The final [program](/drive_cycle/track_modeling/nonlinear_track_generator.m) generates a 3D track models using GPS data from anticipated tracks that the Shell Eco Marathon competition may be held at over the next several years.

It's worth noting that when generating 3D tracks, there is an element of race strategy involved. The tutorial below describes how to obtain GPS data from google earth to be used in the track model. The tutorial describes a method in which you only select the points on the map where the vehicle will drive. Thus you are effectively selecting the racing line when generating the 3D track model, and must do so intentionally.  

[This paper]() describes how to use several heuristics to define an optimal racing line. 

[TODO]: 
- DESCRIBE INPUTS AND OUTPUTS
    -  SPECIFICALLY HOW FOR 2D TRACKS, XPOS IS DISTANCE ALONG THE TRACK, NOT JUST CHANGE IN X 
    - SHOW PICTURE OF THE TRIG
- TODO: make sure the time domains line up, and mess with the solver if they don't 




$Drive$ $Strategy$ $Modeling$: Whether it be traditional racing or efficiency marathons, the way in which the vehicle is driven makes all the difference. In this section we introduce [N-TBD] race strategy models categorized by their drive strategy and their accompanying track model.

1. [Steady State-Flat Track](/drive_cycle/drive_strat/steady_state_flat_track.m): This model generates the time speed points for a drive cycle where the vehicle accelerates and decellerates at constant values, then remains at a steady state speed  
2. 

## VEHICLE MODELING

$Vehicle$ $Dynamics$ $Modeling$
- [TODO]

$Drive$ $Strategy$ $Modeling$
- [TODO]

$Battery$ $Modeling$
- [TODO]

$Inverter$ $Modeling$
- [TODO]

$Motor$ $Modeling$
- [TODO]

$Transmission$ $Modeling$
- [TODO]


## [TODO] References
- MathWorks: For initial vehicle model which was modified for the purpose of this project. 
- University of Michigan Solar Car For their motor modeling code. 
- Papers we cite
- Explicit references (hyperlinks) to the documents which are cited.