**Steps to deploy to Azure:**
**doc is WIP (i.e. NOT COMPLETE YET):**

----------------------
Required:

* Azure login and have someone add you as member of MAB account (NO, you cannot borrow someone's login/password)
* Azure CLI installed 
* Docker installed (link to Docker Desktop goes here)
* This stuff will I hope mostly eventually be done through CI but for now this documents the process.
--------------------
* push image with code changes to repository (see `build.md`)

* Log in (you don't need params if you configured defaults as in `build.md`)

      az acr login --name babywearing -g midatlantic_babywearing_registries / log in to resource group with images in it

* Get the subscription id.

      sub=$(az account show --query "id" -o tsv)

* Create the VM (this is ONLY on first deploy to an instance)

      docker-machine create -d azure \
       --azure-subscription-id $sub \
       --azure-ssh-user babywearing \
       --azure-open-port 80 \
       --azure-size "Standard_B2s" \ 
       --azure-resource-group midatlantic_babywearing_stage \ # rg..one per instance
       --azure-location "eastus" \
       --engine-env RAILS_MASTER_KEY=9ac27b849870ae4cfbfdfdbd8d587af8 \
         babywearing-stage  # name of VM (adjust here and below if different)
 
* ssh to the new VM

      docker-machine ssh babywearing-stage
    
* get the internal IP

      ifconfig eth0 

* Need to change permissions but we should find a way around this:

      sudo chmod 666 /var/run/docker.sock  \ :(  https://stackoverflow.com/questions/48957195/how-to-fix-docker-got-permission-denied-issue   

* Init a new docker swarm (replace ip below with internal IP found above)

      docker swarm init --advertise-addr 192.168.0.4
 
* Go back to your local terminal

      exit
       
* Point some environment variables to the machine:

      eval $(docker-machine env babywearing-stage)       

* Deploy build to swarm

      docker stack deploy -c docker-stack.yml babywearing_stage --with-registry-auth / from project directory
 
* To see status of startup:

      docker service ps --no-trunc babywearing_stage_web 
      
Note: When deploying to a machine for the first time, the `db-migrator` service will take a while (10 mins or so) 
because it takes that long to migrate the db and run the seeds. You will know it is done when you do:

      docker service ps babywearing_stage_db-migrator
      
and see that it is no longer "Running" (it should change to "Shutdown")

DNS Note: We should ultimately be pointing a DNS entry for each machine to the machine's IP address. For now I have
been just setting a name in the Azure portal (there should be a way to do this in the CLI but I haven't tried
to figure it out). To do it in the portal (after the VM is created with the `deploy` above), Go to the VM in the Azure
portal (you can find it in the resource group you created above when you created the VM) and look for the `Configure`
link next to DNS name.       