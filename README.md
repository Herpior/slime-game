# Slide the Slime
A puzzle game made for Games Now! Online Jam #1 in 2020. The jam was one week long and had the design constraint 'Minimal Instructions'.
The game is playable at https://qazhax.itch.io/slime-slide.

In the game, the player controls a ball of slime, and tries to reach the goal. 
The slime can be controlled to move in any direction using wasd, arrow keys, gamepad or the mouse.
As a slime, the player can move not only on the floor, but also up the walls and on the ceiling.
Levers control toggleable walls and form the core of the puzzles in this version.
There are only a few levels so it's very short, but I think it introduces the idea well enough.

This was a solo project, everything was done by me. 
This was the first time I used Godot so I learned my way around the engine. 
I also got some experience in designing levels that teach the mechanics without being too annoying and finishing game projects.
I also learned a lot of things that I could had done better, the movement using mouse makes the slime follow the mouse if the mouse is far away enough from the slime, but a better way to control the slime that way would had been to let the player set the direction by dragging the cursor to the direction they wish to move to.
I also left a hidden feature in, that I used to get through some of the stages faster, but it needlessly complicated the gameplay and was generally seen as a bug and I should had realized that it isn't good.

The pawns/actor.gd is probably the most complex class in the project, as it controls the movement and animation of the slime. It's a bit messy but I think it's a decent gauge for what I can make in a few days.
