fastdfs-tengine-docker
=============
fastdfs tengine in docker https://github.com/fongzii/fastdfs-tengine-docker/

Create image
-------------
* Dockerfile
``````
## Go to the directory of Dockerfile 
## Notice there's a point at the line end.
## you can use your image name to replace name fastdfs-tengine
docker build -t fastdfs-tengine .
``````
Create container
-------------
* Create docker network
``````
## Network name 'mynet'
docker network create --driver bridge --subnet 172.16.0.0/24 --gateway 172.16.0.1 mynet
``````

* Create hosts file 
``````
## you can also change /etc/hosts 
172.16.0.62     mynet.tracker
127.16.0.64     mynet.storage1
``````

* Check or change docker-compose.yml 
``````
services:
  tracker:
    image: fastdfs-tengine #docker image tag name
    container_name: tracker
    ports:
      - "22122:22122"
    environment: 
      - FASTDFS_MODE=tracker # tracker or storage
    volumes:
      - /docker/fastdfs/tracker:/var/fdfs  
      - /docker/fastdfs/conf:/etc/fdfs
      - /etc/localtime:/etc/localtime:ro
      - /docker/hosts:/etc/hosts:ro  #if you choose use '/etc/hosts',then change this '/docker/hosts' to '/etc/hosts'
    networks: 
      default:
        ipv4_address: 172.16.0.62
    hostname: mynet.tracker
networks: 
   default: 
     external:
       name: mynet #use created network 'mynet'
``````

* Build docker-compose.yml
``````
## go to the directory of docker-compose.yml
## auto create container 'tracker','storage1' and start them.
docker-compose up -d 
``````

Conf
-------------
* storage.conf
``````
## can not use 127.0.0.1
tracker_server=mynet.tracker:22122
``````
* mod_fastdfs.conf
``````
tracker_server=mynet.tracke:22122
``````
* nginx.conf
``````
## update ngx_fastdfs_module 
location /group1 {
      root /var/fdfs/data;
      ngx_fastdfs_module;
}
``````
* other conf files if you needed

Test
-------------
``````
## Upload test
/usr/bin/fdfs_test     /etc/fdfs/client.conf  upload  anti-steal.jpg
``````
* You will see url like as follows,copy the url and change the IP to you server IP,You'll be able to access the picture.
``````
example file url: http://172.16.0.64/group1/M00/00/00/rBAAQFysTvaAMnXjAAVIDEP9rus106.jpg
``````

