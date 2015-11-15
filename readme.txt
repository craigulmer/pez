-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-


            ################     ################   ################
                         #####                               
                         #####   #####                      ######   
                         #####   #####                    ######
            ################     ###########            ######   
            #####                #####                 ###### 
            #####                #####               ###### 
            #####                ################   ################



		    A Graphical Pole Zero Editor for Matlab

				      v3.0

				       by
		      Craig Ulmer / Grimace@ee.gatech.edu
		      
		 [  http://www.ece.gatech.edu/users/grimace  ]
		 
				June 10, 1996
				
-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-

Welcome to PeZ, a Pole Zero Editor.  This zip file contains all of the files
you should need to get PeZ up and running on your graphical Matlab system.

What it is
~~~~~~~~~~
PeZ is a bit of Matlab code that builds a Graphical User Interface for you
to interact with the Z-Plane. Since Matlab code is a run-time interpreted
language(at least in 4.2), the unique feature of PeZ is that it can 
be run from just about any platform that runs a graphical version of 
Matlab.  PeZ allows you to graphically add poles and zeros to the Z-Plane,
then lets you shift and modify the pole/zero locations while showing you
the real-time frequency response.

Application
~~~~~~~~~~~
PeZ was built to help teach basic signal processing techniques to 
Sophomore-Senior level students. While PeZ has lost a lot of its
blocky-hard-to-use-look, it still has the basic power that higher
I-need-something-blocky-&-hard-to-use people require. 

Old Features:
 - Different forms of Adding/Deleting/Moving
 - Adds symmetric to the unit circle
 - Real-Imaginary / Magnitude-Phase editing
 - Save/Load to file
 - Export to Roots or Polynomial Equation Vectors
 - Print to File, PS, EPS, or GIF
 - (!!)REAL TIME drag pole/zero and update plots option(!!)
 - (Somewhat) Handles poles/zeros at origin that freqz() chokes on(see below)
 - Runs on just about anything that runs Matlab
 - It's more or less free!(See the legal blurb)

**New Features**
 - New configuration editor
     - Change Mirroring
     - Set Precision
 - Import/Export Window:
     - By equations
     - From .MAT file
     - Grab from "FILTDEMO" 
     - Export to .MAT file
 - Filter Gain Control
 - Added Group Delay/Mag plots
    
 
Shameless Plug
~~~~~~~~~~~~~~
If all goes right, PeZ is expected to be packaged with an upcoming 
Book/CD-Rom package written by Dr. Schafer and Dr. McClellan at the
Georgia Institute of Technology.  The CD-Rom should contain DSP
material written in hyper-text HTML, and is being tested, like PeZ,
on Georgia Tech's own EE2200 class.  If you or your school
is interested in using new technology to better teach students,
please contact the author or check out the web page listed below.

Real Documentation
~~~~~~~~~~~~~~~~~~
Real documentation is being worked on..rather slowly. Check for docs
and updates off of my web page. For now, refer to the old docs found
there.

Being that there's something bound to go wrong among the different 
systems this can be run off of, the documentation can be found on the
World-Wide-Web at http://www.ece.gatech.edu/users/grimace/pez/Demos/index.html.

The Big System Question
~~~~~~~~~~~~~~~~~~~~~~~
The big question is "Will it actually work on my system?". The short
answer is "more-or-less".  A fair amount of time was spent writing the
Matlab code so that it was more "friendly" towards different systems.
Here at Georgia Tech, we're running the code on HP 712/60MHz workstations
with reasonably large monitors.  Screen real estate is usually the big kicker-
since we have reasonably large monitors here, we can afford to let 
our application windows get kind of big(say 700x400 pixels). Anticipating
that I'd want to run this at home on my own PC, I wrote the code so
that all of the windows and gadgets are relative. SO, is the window that
comes up is too small, just resize it down to an appropriate size.

As far as speed, I was actually impressed with my PC at home: even with
the more complex operations, my 486dx4-100 was able to keep up with it.
I've seen similar results on the MACs around here, but I should be testing
compatibilities out more this quarter.

Poles / Zeros at Origin
~~~~~~~~~~~~~~~~~~~~~~~
One point that I will admit in advance is a little less than desirable
is the way PeZ (and Matlab for that matter) handle poles and zeros at
the origin. If you yourself place poles/zeros at the origin, it should
have the effect of shifting the impulse response as a delay(left or 
right).  The shift should have no effect on the magnitude of the 
frequency response, but should adjust the phase response by a corresponding
exponential.  Calls to freqz() don't acknowledge this, so I had to
rewrite freqz() to fit my needs.  While the impulse response is affected,
the phase response has not yet been modified in the code. This is also
partly due to the next problem.

There is an issue of "implied poles/zeros" that PeZ at the current time
ignores. An implied pole or zero means that there are additional poles
or zeros added to the origin for each pole or zero you add elsewhere,
simply due to notation. If you added a zero at A, you could have
either
                H1(z) = z-A    or  H2(z) = (1 - A*z^-1)

Both mean more or less the same thing, it's just that you divided
H1(z) by z to get H2(z).  However to be technical, they differ
because H2(z) has an additional pole at z=0, since 0^-1 blows up.
This implied pole has no other effect on the system, but is definately
a problem if you were to code the system and pretend it was not there.

PeZ currently does not display implied poles or zeros since they don't
make changes to any of the responses being measured.  I expect to 
do a bit of rework o this later, but for now, you'll have to live with
a little bit of hand waving.

Quick Note on Polynomials
~~~~~~~~~~~~~~~~~~~~~~~~~
If you have no poles in the system, and you want to represent the
pole list as a polynomial, PeZ exports a value of [1]. If you send this
off to zplane.m, you will get a pole at 1 instead of an empty list.
This is kind of wrong for zplane, I'm betting that there is an
assumption that if there is only one value, it thinks it is a root of
a polynomial instead of an actual polynomial. Be warned if you start
getting a single zero or pole in a strange place..


A Word About this Release
~~~~~~~~~~~~~~~~~~~~~~~~~
I am releasing this to get a feeling of whether this program is useful to 
other people. I would appreciate hearing back what you think of the
program, what you would like seen done. Being a graduate student with
other responsibilities, I can't guarantee that everything or anything will
work with PeZ, but hopefully this will spawn some more creative thoughts
on the subject.

Getting a hold of me
~~~~~~~~~~~~~~~~~~~~
Please feel to send me mail or look around at some of my other activities.
I can be reached at:

  Craig Ulmer                        email: grimace@ee.gatech.edu
  327667 Georgia Tech Station               ulmer@eedsp.gatech.edu
  Atlanta, GA  30332-1175                   gt7667a@prism.gatech.edu
  
      Web:  http://www.ece.gatech.edu/users/grimace
  
Legal Notes(Important!)
~~~~~~~~~~~~~~~~~~~~~~~
Permission is granted to anyone to make or distribute verbatum copies of
this software package and documentation in any medium, under the following
conditions:

- It is not to be sold or distributed in any other form but this(No Mutations).
- If you want to include PeZ with your own product distribution(ie, include
    it on a CD-Rom with other software), you must get the written permission
    from the author, Craig Ulmer.
- If your school would like to use PeZ as a tool at your school, company,
    university, or institute, you MUST mail the author an extra-large
    T-Shirt or sweatshirt depicting your school! Have a little pride.. :)
    ^^^^^^^    ^^^^^^^^^^ 

Thanks Again To
~~~~~~~~~~~~~~~
Thanks must go to the following, whom without this project would not be 
possible:

 - Dr. Schafer   -- Thanks for the publicity, as well as all of the help
                    and direction in getting this thing done.
 - Dr. McClellan -- Thanks for hammering vectorization into me..Now I can't
                    write anything in C without trying to make it parallel. :)
 - Dr. Yoder     -- Thanks for always thinking of new and better ways to do
                    things and teach others.
 - DR. Jeff Schodorf -- Thanks for getting on my case all of the time!
   ^^               I hope all works at well with you leaving Tech!
 - Amer Abufadel -- Thanks for all the diversions we came up with to avoid
                    getting the work done earlier!
          

Files you should have in this archive:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-------------------------------------------------------------------------------

pez.m          53456 <-- Run this file in Matlab
pez_add.m       5536
pez_bin.m      24716
pez_config.m    8958
pez_del.m       2180
pez_exp.m        723
pez_freq.m       685
pez_hit.m       1056
pez_import.m    1878
pez_move.m      5427
pez_plot.m      5352

print2.m       27227  <---+   New Print options from:
printopt2.m     2373  <---+-- D.L. Hallman  Herrick Labs/Purdue University
uiprint.m      16092  <---+   hallman@helmholtz.ecn.purdue.edu,  THANKS!

smile.mat        228  

readme.txt          -- this file   
-------------------------------------------------------------------------------
-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
Changes in PeZ 3.0 (June 10)
~~~~~~~~~~~~~~~~~~
(Major Changes)


- Pez Configuration Window
  - Set mirroring (At the request of some people that wanted complex
				   filters/uneven Mag plots)
  - Set Precision (ie, how close two objects can be before being merged)
  - Boot Options(Sizes, Plot configs,etc)

- Graphical Panel for Import/Export Options, including:
  - Add by Poly/Root equations
  - Import (extract) from Matlab .MAT data file
  - Import from "filtdemo"
  - Export to Matlab file
  
- Filter Gain control

- First stab at Group Delay function

- Now using Mathwork's "Printer Dialogue Box"-->uiprint (more options)
  ::  Thanks to D.L. Hallman  Herrick Labs/Purdue University for  ::
  ::   allowing me to include this and make a few modifications   ::
  
- Fixed minor real-time drag move with Horizontal mirroring.

- Moved pez_is_hit to pez_hit, for MSW3.1's 8.3 filename(worked
	before, but some people had trouble unarchiving)

- Ditched the Edit Point-2-Point option, no longer needed

- Cleaned up exit routine(Now cleans out all variables used)	


Changes in PeZ 2.8 (Not really given out to anyone)
~~~~~~~~~~~~~~~~~~

- Fixed the all-pass add.  Used to be a mirror across the unit circle,
    now is the more practical   r and 1/r.

- Moved into speed redraws: now uses xors for erasing, therefore can
    greatly speed up moving of objects. Note that for Drag & Draw, this
    fixes the mag/phase plot axis, but in my opinion this is a plus.
    I see it as more useful to see changes made without rescaling the axis.
    
- Can now drag by just clicking on the object. No more "Drag w/ Mouse" 
    button! Much easier, and uses Matlab for object identification
    instead of own calculations. 

- Added Magnitude in dB optionfor plots

- Recoded all of the move functions. More consistent style, tighter
	code, and converted to functions (before it was scripted).

- Made pez_import() function

- Started making things less global


Changes in v2.7
~~~~~~~~~~~~~~~
- First official Release
- Now has some documentation! Written in HTML, should be a little bit
          better than previous one-line-ascii I've had.
- Redefined Edit options - Now they're on a separate menu for easier use
- All help stuff completed
- Better object selection (chooses object closest in area to click)
- Better Real adds (If close to the real axis, assumes no imaginary portion)
- Faster real time moves
- Internalized all plot functions (ie, no calls to freqz(), should Fix
          Dr. Schafer's previous troubles).
- Removed all uicontrol() calls due to instabilities of Matlab (replaced
          with my own drop menus)
- Resized window co-ordinates (ie, made about 100 changes in window variables
          about 3 or 4 different times)
- Added Print to PS,EPS,and GIF due to popular demand
- Split up some of the big functions into little functions for speed
- Figured out how to spell "Zeros"
- And...Lots of other things too tedious to remember

