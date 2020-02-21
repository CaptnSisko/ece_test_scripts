#!/bin/bash

# Change this if not running on EWS
netid="$(whoami)"
term="ECE220SP20"

# Start with the script's disclaimer
printf '\033[8;40;100t'
clear
echo """
 █████╗ ██╗   ██╗████████╗ ██████╗  ██████╗ ██████╗  █████╗ ██████╗ ███████╗██████╗ 
██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗██╔════╝ ██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
███████║██║   ██║   ██║   ██║   ██║██║  ███╗██████╔╝███████║██║  ██║█████╗  ██████╔╝
██╔══██║██║   ██║   ██║   ██║   ██║██║   ██║██╔══██╗██╔══██║██║  ██║██╔══╝  ██╔══██╗
██║  ██║╚██████╔╝   ██║   ╚██████╔╝╚██████╔╝██║  ██║██║  ██║██████╔╝███████╗██║  ██║
╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝

Written by Martin Michalski and Trevor Wong

Please read the following disclaimer and press \"y\" to indicate your agreement or any other key to stop this script.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

This is a student project, so passing test cases here does not garentee you will pass your test cases when the assignment is graded. This script was written to run on EWS lab machines, and for it to run correctly you must have pushed your code to your ECE 220 Git repository.
"""
read -p "Do you agree to the disclaimer above [y/N]: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo "You did not agree to the disclaimer. Aborting."
	exit
fi 

# Install required libraries
echo "Installing prerequisites..."
pip3 install --user pexpect

# Setup the directory structure
echo "Setting up directory structure..."
cd /tmp
mkdir -p ece_student_autograder
cd ece_student_autograder

# Clone test script repository
echo "Updating test scripts..."
if [ -d "ece_test_scripts" ]; then
	cd ece_test_scripts
	gitlog="$(git status)"
	if [[ ! $gitlog =~ "Your branch is up to date" ]]; then	
		git fetch --all
		git reset --hard origin/master
	fi
	cd ..
else
	git clone https://github.com/CaptnSisko/ece_test_scripts # TODO update url after merge
fi

# Clone student repository
echo "Updating your ECE 220 repository (Term=$term, NetID = $netid)..."

if [ -d "$netid" ]; then
	cd "$netid"
	gitlog="$(git status)"
	if [[ ! $gitlog =~ "Your branch is up to date" ]]; then
		echo "********"
		echo "In order to clone your ECE 220 Github repository, you must log in using your NetID"
		echo "********"
		git fetch --all
		git reset --hard origin/master
	fi
else
	echo "********"
	echo "In order to clone your ECE 220 Github repository, you must log in using your NetID"
	echo "********"
	gitlog="$(git clone https://github-dev.cs.illinois.edu/"$term"/"$netid".git)"
	cd "$netid"
fi

gitlog="$(git status)"
if [[ ! $gitlog =~ "Your branch is up to date" ]]; then
	echo "There was an error fetching your repository! Aborting."
	exit
fi

version="$(python3 --version)"
echo "Starting python grading script ($version)..."
python3 ece_test_scripts/autograder/ece220_autograde.py
#pwd