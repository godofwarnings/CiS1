#!/bin/bash

mkdir ptcIs

cd ptcIs

wget https://github.com/godofwarnings/CiS1/blob/main/files.zip?raw=true
wget https://github.com/godofwarnings/CiS1/blob/main/script.sh?raw=true

mv files.zip?raw=true files.zip
mv script.sh?raw=true script.sh

cd ptcIs
chmod +x script.sh