# Lab deploy ms 
Se despliega los recursos mediante terraform, se usa una SA para ejecutar el despliege en GCP de los recursos.
Re realizo  la instalación de docker y ansible. Docker para poder buildear localmente la imagen del ms en la vm bastion, con ansible se realiza las tareas de build de imagen, push a repositorio y despliegue de servicios en el  GCK. 


