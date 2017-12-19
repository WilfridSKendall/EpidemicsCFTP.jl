Prerequisites
=============
These progrms are `python3` scripts, so `python3` is required. 

They also use the `Tkinter` and `Image` modules, while `Pandoc` is used to render documentation.
In `Ubuntu` use the following on the command-line:

    sudo apt-get install pandoc python3-tk python3-pil

I belive these are all that is required.
 
Testing FreeEpidemic
====================
Basic documentation
-------------------
Here are simple invocations of the `FreeEpidemic` and `Innovations` classes:

     >>> from pprint import pprint
     >>> from epidemic import Innovations, FreeEpidemic
     
     >>> iv = Innovations(remove=[[1, 1.6], [1.3], [0.5, 2]],
     ...                  infect=[[[0.4, 0.9], [0.6, 1.4]],
     ...                          [[0.2, 1.1, 1.5]]])

Note the form of the `Innovations` structure:

     >>> print(iv)
     Innovations for SIR epidemic on 3 individuals:
     Row               List of proposed potential removals
       3:              1.00 1.60
       2:              1.30
       1:              0.50 2.00
     Target row
          (Origin)     List of proposed potential infections
       3:   (1)        0.40 0.90
            (2)        0.60 1.40
       2:   (1)        0.20 1.10 1.50

     >>> epidemic = FreeEpidemic(innovations=iv)
     >>> print(epidemic(pretty=True))  
     Time    S, I, R
     0.00   (2, 1, 0)
     0.20   (1, 2, 0)
     0.40   (0, 3, 0)
     0.50   (0, 2, 1)
     1.00   (0, 1, 2)
     1.60   (0, 0, 3)

![A graphical illustration of the resulting free SIR epidemic](image/figure1.png "Free epidemic")
