#!/bin/bash
sudo docker network create web
sudo docker-compose up -d
sudo docker ps -a
