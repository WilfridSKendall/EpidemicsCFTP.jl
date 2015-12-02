#!/usr/bin/env python3
"""
A python module with logging, doctest to construct a set of innovation 
incidents to allow simulate of an SIR epidemic.

Metadata:

  - Author:    W.S.Kendall
  - Copyright: opensource (c) W.S.Kendall 2014
  - Date:      2014-04-26
  - URL:       http://www.wilfridkendall.co.uk
  - Generator: '/home/wilfrid/lib/python/generate.py' version 1.27.

Command-line options::

  usage: %prog [options] arguments
    --doctest:             perform doctests;
    --logging=LOGGING:     logging verbosity level.

Notes:
 - values for 'logging' option:
 'DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'
 (decreasing level of verbosity), with 'WARNING' as default.

"""

# \section{Definitions}
# We need the logging module regardless of whether the #logging# option
# is deployed, since #logging.info# calls are scattered through the text.
import logging, os, sys

from itertools import chain


#\section{Exceptions}
class Error(Exception):
    """
    Generic exception to be raised by this module.
    """
class BadDataError(Error):
    pass

# \section{Classes}
class Innovation:
    """
    This class captures innovation incidents to permit construction of an
    SIR trajectory and provides a method for generating the epidemic::
    
     >>> from pprint import pprint
     >>> inn = Innovation(remove=[[1, 1.6], [1.3], [0.5, 2]],
     ...                  infect=[[[0.4, 0.9], [0.6, 1.4]],
     ...                          [[0.2, 1.1, 1.5]]])

     >>> print(str(inn))
     [[1, 1.6], [1.3], [0.5, 2]]
     [[[0.4, 0.9], [0.6, 1.4]], [[0.2, 1.1, 1.5]]]

     >>> pprint(inn.epidemic())
     [(0, (2, 1, 0)),
      (0.4, (1, 2, 0)),
      (0.6, (0, 3, 0)),
      (1, (0, 2, 1)),
      (1.3, (0, 1, 2)),
      (2, (0, 0, 3))]

    """
    def __init__(self, remove=[[1], [2]], infect=[[[0.5, 1.2]]]):
        self.remove, self.infect = remove, infect
        self.n = len(remove)
        
        # Sanity checks
        if len(self.infect) != self.n - 1:
            raise BadDataError("infection and removal data structure lengths do not agree")
        for i, ll in enumerate(self.infect):
            if len(ll) != self.n - i - 1:
                raise BadDataError("internal inconsistencies in infection data sub-structure lengths")
        
    def __str__(self):
        return "%s\n%s" % (self.remove, self.infect)

    def _build_time_line(self):
        """
        Constructs indexed sequence of incidents.
        """
        res = [[i]*len(ll) for i, ll in enumerate(self.remove)]
        rem = zip(chain(*self.remove), chain(*res))
        ins = chain(*[chain(*[[(i, i+j+1)]*len(ll) for j, ll in enumerate(lll)]) \
                                           for i, lll, in enumerate(self.infect)])
        in1 = chain(*[chain(*lll) for lll in self.infect])
        inf = map(lambda y: (y[0], y[1][0], y[1][1]), zip(in1, ins))
        return sorted(list(chain(rem, inf)))
        
    def epidemic(self, I=1):
        """
        Returns a sequence of changes of state of an SIR epidemic driven by these innovations.
        """
        S, R = self.n - I, 0
        trajectory = [(0, (S, I, R))]
        for x in self._build_time_line():
            if len(x) == 3:
                t, i, j = x
                if R <= i and i < I + R and I + R <= j:
                    logging.info('[%f]: R=%d, i=%d, I+R=%d, j=%d' % (t, R, i, I+R, j))
                    I += 1
                    S -= 1
                    trajectory.append((t, (S, I, R)))
            if len(x) == 2:
                t,  i = x
                if R <= i and i < I + R:
                    I -= 1
                    R += 1
                    trajectory.append((t, (S, I, R)))
        return trajectory


# \section{Functions}
def main(opt, arguments):
    """
    The action of the module as script should be concentrated here!
    """
    logging.info('Entering main function')
    from pprint import pprint

    logging.info('Default settings:')
    logging.info('    innovation structure')
    inn = Innovation()
    print(str(inn))
    logging.info('    and consequent epidemic')
    pprint(inn.epidemic())


def _doctest():
    """
    Doctests.
    """
    logging.info('Commencing doctests')
    import doctest
    doctest_results = doctest.testmod()[0]
    testfile_results = doctest.testfile(__file__[:-3] + '.txt', False)[0]
    if doctest_results == 0 and testfile_results == 0:
        os.system('touch %s.doctested' % __file__)


# \section{Main script}
if __name__ == '__main__':
    import optionparse3 as optionparse
    option, args = optionparse.parse(__doc__)

    if option.logging is not None:
        logging.basicConfig(level=logging.__dict__[option.logging])
        logging.info('Logging level %s' % option.logging)

    if option.doctest:
        _doctest()


    # The action of the module as script should be concentrated
    # in the following function, to facilitate profiling.
    main(option, args)


    logging.info('Finishing')
    sys.exit(0)


# $ $Id: python.py,v 1.1 2013/07/08 11:19:51 wilfrid Exp wilfrid $ $
