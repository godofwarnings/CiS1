#!/bin/bash

mkdir ptcIs

cd ptcIs

wget https://raw.githubusercontent.com/godofwarnings/CiS1/main/T005-17thJune22-Parallel_tempering/script.sh
wget https://github.com/godofwarnings/CiS1/blob/main/T005-17thJune22-Parallel_tempering/files.zip?raw=true

mv files.zip?raw=true files.zip
mv script.sh?raw=true script.sh

chmod +x script.sh

clear
