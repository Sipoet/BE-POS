# README

This is open source extension Back end API server to database IPOS 5(https://inspirasi.biz/).

API standard format use json https://jsonapi.org/format/

server use library:
* ruby v3.2.2 for programming language
* rails v7.1 for server framework
* puma for app server
* sidekiq for background job
* redis used in sidekiq and cache

system requirement:
* ipos 5 v9.0.5.1
* docker
* git
* ipos 5 lisensi server
* access to postgresql database 9.6.xx (ask ipos customer service)


how to install:
* install docker: https://docs.docker.com/get-docker/
* install git
* open command line on folder you want to install
* clone repository git
  >``git clone https://github.com/Sipoet/BE-POS.git``
* go to repository
* rename file `example.env` into `.env`
* edit renamed file `.env`. change data inside that has retangular block([]) in it. ask ipos customer service for data needed
* to migrate database needed, run command
  >``docker compose build``
  >``docker compose up -d``
  >``docker exec -it backend-pos rails db:migrate``
  >``docker compose stop``
how to start server:
* run docker compose
  >`docker compose start`
* on default, the back-end server will be run in `http://localhost:3000`
* to change server port, you can change in `.env` file variable `SERVER_PORT`
how to stop server:
* go to repository
* run command
  >`docker compose stop`
