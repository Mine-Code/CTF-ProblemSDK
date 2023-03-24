#!/bin/bash

cd $(dirname $0)

printf "\e[1;32mChecking for dependencies...\e[0m\n"
printf "\e[33mDocker container\e[0m\n"
docker image ls 2>/dev/null | grep -q mc_ctf
if [ $? -ne 0 ]; then
    printf "\e[2;33m Not found => doing Install...\e[0m\n"
    git clone https://github.com/Mine-Code/ctf-runtime
    cd ctf-runtime
    make
    cd ..
fi


mkdir -p ~/.local/share/MC-CTF || exit 0

cp sdk/mc_ctf ~/.local/bin/mc_ctf
chmod +x ~/.local/bin/mc_ctf

cp sdk/Problem.mk ~/.local/share/MC-CTF/Makefile.problem

cd skel
tar -czf ~/.local/share/MC-CTF/skel.tar.gz * .mc_ctf .gitignore
cd ..

echo "Installed files:"
ls -l ~/.local/share/MC-CTF
ls -l ~/.local/bin/mc_ctf