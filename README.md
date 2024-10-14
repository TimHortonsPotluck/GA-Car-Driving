# GA-Car-Driving
Evolves "cars" using a genetic algorithm.

It doesn't seem to work when I download it for some reason. I think I might've messed something up with compiling it, I'm not sure. 

Can take around 500 generations to start seriously improving. This can take 5-10 minutes if you do quick generations continuously and let it run. If you do "watch multiple generations", you can return to the menu by hitting space. Once the current generation finishes it will take you back.

Uses the Processing environment/programming language (https://processing.org/), but can be run without it using the carsdriving2.exe file. Probably that whole folder would need to be downloaded in order for it to run properly, but I'm not sure.

The red line tracks the lowest distance to the goal of all cars in the generation. The blue and yellow lines track the median and mean distances, respectively. 

There's more to it than just what's in the .exe, like multiple "worlds" that can be generated and different car parameters, but back when I made this I didn't add in options for those in the main menu. Worlds don't appear to have been fully implemented anyway. I'd like to come back to this now that I have more programming experience.

Being able to adjust the mutation rate during the sim would be nice. Also to be able to specify the car parameters in the window, without having to adjust them in the code. 
