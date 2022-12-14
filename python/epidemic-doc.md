Testing FreeEpidemic
====================
Basic documentation
-------------------
Here are simple invocations of the `FreeEpidemic` and `Innovations` classes:

     >>> from pprint import pprint
     >>> from epidemic import Innovations, FreeEpidemic
     
     >>> iv = Innovations(remove=[[1, 1.6], [1.3], [0.5, 2]],
     ...                  infect=[[[0.2, 1.1, 1.5]],
     ...                          [[0.4, 0.9], [0.6, 1.4]]
     ...                         ])

Note the form of the `Innovations` structure:

     >>> print(iv)
     Innovations for SIR epidemic on 3 individuals:
     TLine             List of proposed potential removals
       3:              0.50 2.00
       2:              1.30
       1:              1.00 1.60
     Active timeline (infection works if top of infectives)
     TLine  (Mark)     List of proposed potential infections
       2:   (2)        0.60 1.40
            (1)        0.40 0.90
       1:   (1)        0.20 1.10 1.50

Here is the epidemic driven by these 'Innovations':

     >>> epidemic = FreeEpidemic(innovations=iv)
     >>> print(epidemic(pretty=True))  
     Time    S, I, R
     0.00   (2, 1, 0)
     0.20   (1, 2, 0)
     0.40   (0, 3, 0)
     0.50   (0, 2, 1)
     1.30   (0, 1, 2)
     2.00   (0, 0, 3)
     Infections at:
     [0, 0.2, 0.4]
     Removals at:
     [0.5, 1.3, 2]
     Mordor ends at:
     [0, 0, 0]

![A graphical illustration of the resulting free SIR epidemic](image/figure1.png "Free epidemic")


Further examples
----------------
And now we present the results of three further tests.
     
     >>> rem = [[1.1, 2.0], [0.3], [0.2], [0.1], [1.0]]
     >>> ill = [[[1.9]], 
     ...        [[0.9], [1.8]],
     ...        [[], [], []], 
     ...        [[0.5], [0.6], [0.7], [1.2]]
     ...       ]
     >>> iv =Innovations(remove=rem, infect=ill)
     >>> epidemic = FreeEpidemic(innovations=iv)
     >>> print(iv)
     Innovations for SIR epidemic on 5 individuals:
     TLine             List of proposed potential removals
       5:              1.00
       4:              0.10
       3:              0.20
       2:              0.30
       1:              1.10 2.00
     Active timeline (infection works if top of infectives)
     TLine  (Mark)     List of proposed potential infections
       4:   (4)        1.20
            (3)        0.70
            (2)        0.60
            (1)        0.50
       3:   (3)        
            (2)        
            (1)        
       2:   (2)        1.80
            (1)        0.90
       1:   (1)        1.90

     >>> print(epidemic(pretty=True))   
     Time    S, I, R
     0.00   (4, 1, 0)
     1.10   (4, 0, 1)
     Infections at:
     [0]
     Removals at:
     [1.1]
     Mordor ends at:
     [0, 0.3, 0.2, 0.1, 1.0]


![Another example of a free SIR epidemic](image/figure2.png "Free epidemic")

     >>> rem = [[1.1, 2.0], [1.5], [1.3], [1.2], [1.0]]
     >>> ill = [[[0.1]], 
     ...        [[0.9], [1.8]],
     ...        [[], [1.25], []], 
     ...        [[0.5], [0.6], [0.7, 1.15], [1.2]]]
     >>> iv =Innovations(remove=rem, infect=ill)
     >>> epidemic = FreeEpidemic(innovations=iv)
     >>> print(iv)
     Innovations for SIR epidemic on 5 individuals:
     TLine             List of proposed potential removals
       5:              1.00
       4:              1.20
       3:              1.30
       2:              1.50
       1:              1.10 2.00
     Active timeline (infection works if top of infectives)
     TLine  (Mark)     List of proposed potential infections
       4:   (4)        1.20
            (3)        0.70 1.15
            (2)        0.60
            (1)        0.50
       3:   (3)        
            (2)        1.25
            (1)        
       2:   (2)        1.80
            (1)        0.90
       1:   (1)        0.10

     >>> print(epidemic(pretty=True))   
     Time    S, I, R
     0.00   (4, 1, 0)
     0.10   (3, 2, 0)
     0.90   (2, 3, 0)
     1.10   (2, 2, 1)
     1.25   (1, 3, 1)
     1.30   (1, 2, 2)
     Infections at:
     [0, 0.1, 0.9, 1.25]
     Removals at:
     [1.1, 1.3]
     Mordor ends at:
     [0, 0, 0, 1.2, 1.0]

![Yet another example of a free SIR epidemic](image/figure3.png "Free epidemic")



![Larger free SIR epidemic generated at random](image/randomfigure1.png "Larger free epidemic generated at random")
from

![Larger free SIR epidemic generated at random with three initial infectives](image/randomfigure2.png "Larger free epidemic generated at random with three initial infectives") 


Accessor methods
----------------
Testing 'removal_str' and infection_str' methods for an 'Innovations' instance.

     >>> print(iv)
     Innovations for SIR epidemic on 5 individuals:
     TLine             List of proposed potential removals
       5:              1.00
       4:              1.20
       3:              1.30
       2:              1.50
       1:              1.10 2.00
     Active timeline (infection works if top of infectives)
     TLine  (Mark)     List of proposed potential infections
       4:   (4)        1.20
            (3)        0.70 1.15
            (2)        0.60
            (1)        0.50
       3:   (3)        
            (2)        1.25
            (1)        
       2:   (2)        1.80
            (1)        0.90
       1:   (1)        0.10

     >>> print(iv.removal_str())
     TLine             List of proposed potential removals
       5:              1.00
       4:              1.20
       3:              1.30
       2:              1.50
       1:              1.10 2.00

     >>> print(iv.infection_str())
     Active timeline (infection works if top of infectives)
     TLine  (Mark)     List of proposed potential infections
       4:   (4)        1.20
            (3)        0.70 1.15
            (2)        0.60
            (1)        0.50
       3:   (3)        
            (2)        1.25
            (1)        
       2:   (2)        1.80
            (1)        0.90
       1:   (1)        0.10

Exceptions
----------
Tests of exceptions raised by `sanity_check` method.

     >>> rem = [[1.1, 2.0], [1.5], [1.3], [1.2]]
     >>> ill = [[[0.1]], 
     ...        [[0.9], [1.8]],
     ...        [[], [1.25], []], 
     ...        [[0.5], [0.6], [0.7, 1.15], [1.2]]]
     >>> iv =Innovations(remove=rem, infect=ill)
     Traceback (most recent call last):
     ...
     epidemic.PopulationVersusInfectionsError: population (4) != 1 + infection structure length (4)

     >>> rem = [[1.1, 2.0], [0.3], [0.2], [0.1], [1.0]]
     >>> ill = [
     ...        [[0.9], [1.8]],
     ...        [[], [], []], 
     ...        [[0.5], [0.6], [0.7], [1.2]]
     ...       ]
     >>> iv =Innovations(remove=rem, infect=ill)
     Traceback (most recent call last):
     ...
     epidemic.PopulationVersusInfectionsError: population (5) != 1 + infection structure length (3)

     
     >>> rem = [[1.1, 2.0], [0.3], [0.2], [0.1], [1.0]]
     >>> ill = [[[1.9]], 
     ...        [[0.9],      ],
     ...        [[], [], []], 
     ...        [[0.5], [0.6], [0.7], [1.2]]
     ...       ]
     >>> iv =Innovations(remove=rem, infect=ill)
     Traceback (most recent call last):
     ...
     epidemic.InfectionStructureError: infection data sub--list lengths are [1, 1, 3, 4] not [1, 2, 3, 4]

     >>> iv.remove = [[1.1, 2.0], [], [0.2], [0.1], [1.0]]
     >>> iv.sanity_check()

     >>> iv.remove = [[1.1, 2.0], [0.3], [0.2]]
     >>> iv.sanity_check()
     Traceback (most recent call last):
     ...
     epidemic.PopulationVersusRemovalsError: population (5) != removal structure length (3)

Test of exceptions connected to the 'FreeEpidemic' class.

     >>> epidemic = FreeEpidemic()
     Traceback (most recent call last):
     ...
     epidemic.BadFreeEpidemicError: FreeEpidemic object without Innovations
