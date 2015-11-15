This is a beta version of Pez 2.8.  Use this at your own risk!
Author: Craig Ulmer grimace@ee.gatech.edu (or gt7667a@prism.gatech.edu)
February 26,1996

Important: If you haven't used pez before, I suggest getting pez 2.7 and
reading the documentation first. This release is mainly for people who
wanted a few extra features.

All source code and information is released for use without
modifications or profit redistributions, as stated in the previous
release, found in pez27.zip at

http:/www.ece.gatech.edu/users/grimace/www/pez/index.html

The documentation has not been updated yet, but the previous version's
should be adequate(As well as found  at the above address).

Note: At the request of several people, an import option has been added
to pez. Right now it is a command line version(from matlab). To access
it,  - startup Matlab
	 - startup pez28  by typing pez
	 - type  help pez_import  in the Matlab window


This is the beta version of Pez 2.8b (Feb 25)
Changes:
- Added the dB button to mag plots
- Now clips dB at -140(With better scaling)
- Changed log-mag to  0 to pi, added grid
- Fixed import bug (Plotted to wrong window if 2 tries of same data)
- Added quick move stuff (ie, xor on move object)
- Added Gain to import (Is this right??)
- Cleaned up a few nic-nacks

pez 2.8a (Feb 11)
Changes: 
- Added a pez_import function for command line adding
- Fixed a bug with the adding at imag=0 results in shift, even if not at
	origin
- Fixed up the adding at origin. Now handles the (hopefully) right
	amount of e^jwn multiplication for the phase response
- Added the basic code for changing between magnitude of freq
	response and 20*log10(freq_response). No button yet, but you can
	change back and forth by typing on the command line



More to come...
-Craig
