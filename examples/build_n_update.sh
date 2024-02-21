#!/bin/bash

#to-do: automatically add/remove semester calender

docker build --tag=od_st ..
docker stop od_st
docker rm od_st
docker-compose up -d
