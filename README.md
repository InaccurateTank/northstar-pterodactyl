# northstar-pterodactyl

Pterodactyl egg for the Titanfall|2 Northstar mod based heavily on the https://github.com/pg9182/northstar-dedicated container. Notable differences include:
- Working with Pterodactyl
- Storing all the neccesary files in /home/container
- A smaller docker image with the custom wine build

The egg still requires the game files to be mounted at /mnt/titanfall in order to work. Only a small amount of the settings have been integrated into the panel at this point. This is mostly a proof of concept if anything.