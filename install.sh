#!/bin/bash

cd $(dirname $0)

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