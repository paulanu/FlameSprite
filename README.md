# FlameSprite
Visual demo of a flame sprite in a kid witch's hideout. The goal of this project was to create a cozy scene to experiment with transparency and learn the 3D pipeline. I used Unity, Blender, and Substance Designer for this project. 


https://user-images.githubusercontent.com/10067058/234687874-ae83bc3d-f697-43cc-8373-54d82d31d2eb.mp4


## Player character 
The player character was inspired by Calcifer from the movie Howl's Moving Castle. I liked the challenge of rendering a stylized character made of fire. It is composed of three particle systems (top particles, side particles, and trailing particles) and a spherical mesh. 

Since I did not want the particles and mesh to overlap, I used the stencil buffer in my particle shader and base mesh shaders. The particles are rendered later in the render queue to make sure that the base mesh sets its stencil buffer first. 

![stencil](https://user-images.githubusercontent.com/10067058/234685788-ab0a885d-4335-4915-ad70-b9894cf3128d.png)

The base mesh uses fresnel for color banding blended with a scrolling noise texture to create the flame effects in the middle. The noise texture is mapped to the view dir in tangent space since I think this gives a better effect when the player character rotates. 

I then overlay a gradient on top of everything. Since the particle and mesh shader share some color variables, I set global shader variables in a script.  

All of these shader properties are exposed so the character can have lots of different effects: 

![types](https://user-images.githubusercontent.com/10067058/234685824-6ce91070-061c-4beb-bcee-07ab93ddfef7.png)

Finally, I used Unity's built in animation system to add some gentle up and down "breathing" movement and blinking. 

## Firelight effect 
The glowing firelight effect around the player is a custom post processing material rendered over the main image. I referenced these two great tutorials by [Ronja](https://www.ronja-tutorials.com/post/018-postprocessing-normal/) and [Harry Alisavakis](https://halisavakis.com/my-take-on-shaders-spherical-mask-post-processing-effect/) to create this.

It works by grabbing the depthnormal texture from the camera and referencing the player position to color a sphere around it. I use a dot product comparison between the normal texture and the direction to the player to determine if the pixel should be colored. These parameters are all set in a postprocessing script attached to the camera. 

## Environment 
I modelled the environment in Blender and textured it using Substance Designer. 

The trees have a custom shader that maps color to height so they can be easily customized and still look uniform. 

The jars have a simple shader that uses varying color banding with fresnel to create a fake highlight and stylized glass appearance. 

The skybox is using another custom shader for a color gradient. I referenced [this article](https://medium.com/@jannik_boysen/procedural-skybox-shader-137f6b0cb77c) to calculate the UVs of the skybox so I could overlay a star texture. 

I also added some ambient firefly particles and swaying jar animations to tie the whole scene together!
