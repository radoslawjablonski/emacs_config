#! /bin/bash -xe

# installing irony apt packages
sudo apt install libclang-dev clang cmake python3-pip python-pip cppcheck autotools-dev

# instaling pip packages (for python 2)
sudo pip install edi flake8 importmagic autopep8

# instaling pip packages (for python 3)
sudo pip3 install edi flake8 importmagic autopep8  
