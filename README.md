# Softserve_Demo-1
Demo Project to demonstrate the pipeline flow via Jenkins and AWS services


Basic ShareYourText app was developed by 4 KNU students as their university project:
Julia Tkach 
Zaichko Oleksandr 
Zabudskyy Vladyslav
Kostroba Ivan

Many thanks to the other members of this development team for letting me to use our code for this demo project. 
Basically, I needed something to deploy, so I did manage to build an image out of our app using Jenkins, Docker, AWS and hosted it in an ECR. 
Then, this image is being pulled by a deployment server and used to create a container to run our app. Check it out on:

http://deployment.kostroba.pp.ua:8080 
