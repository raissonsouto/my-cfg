#!/bin/bash

# Raisson Souto, 2023

# The goal of this script is to automate the
# configuration of my Ubuntu environment

LOG_FILE="cfg.log"

sh ./install.sh $LOG_FILE -i
sh ./ui.sh $LOG_FILE -i
sh ./shortcuts.sh $LOG_FILE -i

# missing .bashrc

if $1; then
    sh ./tools/docker.sh $LOG_FILE
if

# https://gist.github.com/ammuench/0dcf14faf4e3b000020992612a2711e2