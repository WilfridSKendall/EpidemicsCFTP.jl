#!/usr/bin/env python3
"""
A python module with logging, doctest to construct a set of innovation 
incidents to allow simulation of an SIR epidemic.

Metadata:

  - Author:    W.S.Kendall
  - Copyright: opensource (c) W.S.Kendall 2014
  - Date:      2014-04-26, revised 2017-12-12
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
    This class captures innovation incidents related to 
    construction of an SIR epidemic trajectory, thus providing
    the randomness needed to generate SIR epidemics, At least
    initially, we assume the innovations are provided
    deterministically, so the class requires only sanity
    checks and a printing method::
    
     >>> from pprint import pprint
     >>> inn = Innovation(remove=[[1, 1.6], [1.3], [0.5, 2]],
     ...                  infect=[[[0.4, 0.9], [0.6, 1.4]],
     ...                          [[0.2, 1.1, 1.5]]])

     >>> print(str(inn))
     [[1, 1.6], [1.3], [0.5, 2]]
     [[[0.4, 0.9], [0.6, 1.4]], [[0.2, 1.1, 1.5]]]
    """
    def __init__(self, remove=[[1], [2]], infect=[[[0.5, 1.2]]]):
        self.remove, self.infect = remove, infect
        self.n = len(remove)
        
        # Sanity checks. We require::  
        # 1. #self.infect# to be made up of one list of lists of potential infections
        #    for each row except for the first row,
        # 2. and each sub-list in #self.infect# to be made up of one list of potential
        #    infections for each sub-list located above current sub-list.
        if len(self.infect) != self.n - 1:
            raise BadDataError("infection and removal data structure lengths do not agree")
        for i, ll in enumerate(self.infect):
            if len(ll) != self.n - i - 1:
                raise BadDataError("infection data sub-structure is inconsistent")
        
    def __str__(self):
        return "%s\n%s" % (self.remove, self.infect)

class FreeEpidemic(object):
    """
    This class computes a (free) SIR epidemic, given an #Innovation# instance::
    
     >>> from pprint import pprint
     >>> innov = Innovation(remove=[[1, 1.6], [1.3], [0.5, 2]],
     ...                  infect=[[[0.4, 0.9], [0.6, 1.4]],
     ...                          [[0.2, 1.1, 1.5]]])

     >>> epidemic = FreeEpidemic(innovations=innov)
     >>> pprint(epidemic.compute())
     [(0, (2, 1, 0)),
      (0.4, (1, 2, 0)),
      (0.6, (0, 3, 0)),
      (1, (0, 2, 1)),
      (1.3, (0, 1, 2)),
      (2, (0, 0, 3))]

    """
    def __init__(self, innovations=None):
        if not innovations:
            raise BadDataError("No innovations supplied for FreeEpidemic object")
        self.iv, self.n = innovations, innovations.n
    
    def _build_time_line(self):
        """
        Constructs indexed sequence of incidents.
        """
        # List of lists of row indices, one for each removal time.
        res = [[i]*len(ll) for i, ll in enumerate(self.iv.remove)]
        # List of (removal time, row mark). 
        rem = zip(chain(*self.iv.remove), chain(*res))

        # List of lists of pairs of row indices, one pair for each infection time.
        ins = chain(*[chain(*[[(i, i+j+1)]*len(ll) for j, ll in enumerate(lll)]) \
                                           for i, lll, in enumerate(self.iv.infect)])
        # List of lists of incoming infections for each row.
        in1 = chain(*[chain(*lll) for lll in self.iv.infect])
        # List of (infection time, outgoing row, incoming row)
        inf = map(lambda y: (y[0], y[1][0], y[1][1]), zip(in1, ins))
        
        # Return list of incidents sorted by time.
        return sorted(list(chain(rem, inf)))
        
    def compute(self, I=1):
        """
        Returns a sequence of changes of state of an SIR epidemic driven by 
        #FreeEpidemic# innovations. Note that no conditioning is imposed here!
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
    epidemic = FreeEpidemic(innovations=inn)
    pprint(epidemic.compute())


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
