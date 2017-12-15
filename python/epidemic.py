#!/usr/bin/env python3
"""
A python module with logging, doctest to construct a set
of innovation incidents to allow simulation of an SIR epidemic.

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
import logging
import os
import sys

from itertools import chain


#\section{Exceptions}
class Error(Exception):
    """
    Generic exception to be raised by this module.
    """
class BadDataError(Error):
    """
    Raised when bad data is supplied.
    """

# \section{Classes}
class Innovations(object):
    """
    This class captures innovation incidents related to
    construction of an SIR epidemic trajectory, thus providing
    the randomness needed to generate SIR epidemics. At least
    initially, we assume the innovations are provided
    deterministically, so the class requires only sanity
    checks and a printing method::

     >>> from pprint import pprint
     >>> innov = Innovations(remove=[[1, 1.6], [1.3], [0.5, 2]],
     ...                  infect=[[[0.4, 0.9], [0.6, 1.4]],
     ...                          [[0.2, 1.1, 1.5]]])
     >>> len(innov)
     3
     >>> print(innov)
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

    Note the data format. An #Innovations# instance is effectively
    a list of two sub-lists. The first sub-list is the #remove#
    list, containing `n` sub-sub-lists, one for each timeline row,
    working from row `n` down to row #1# as per algorithm described
    in the paper. Each such sub-sub-list is a list of potential removal
    times, the mark for each of these removals being implied by the row
    corresponding to the sub-sub-list.

    The second sub-list is the `infect` sub-list, containing `n-1`
    sub-sub-lists. Each of these sub-sub-lists corresponds to a timeline
    row starting at row `n` and working downwards to row `2`, and contains
    sub-sub-sub-lists of potential infection times, one sub-sub-sub-list
    corresponding to each row _below_ the timeline row corresponding to
    the relevant sub-sub-list.
    """
    def __init__(self, remove=None, infect=None):
        self.remove, self.infect = remove, infect
        # self.n = len(remove)

        # Sanity checks. We require:
        #
        # 1. `self.infect` to be made up of one list of lists of potential infections
        #    for each row except for the first row,
        # 2. and each sub-list in `self.infect` to be made up of one list of potential
        #    infections for each sub-list located above current sub-list.
        if len(self.infect) != len(self) - 1:
            raise BadDataError("infection and removal data structure lengths do not agree")
        for i, llst in enumerate(self.infect):
            if len(llst) != len(self) - i - 1:
                raise BadDataError("infection data sub-structure is inconsistent")
    def __repr__(self):
        return "%s\n%s" % (self.remove, self.infect)
    def __str__(self):
        pop = len(self)
        def lstr(lst):
            "Temporary function to convert list of floats into string of space-separated floats"
            return ' '.join('%4.2f' % e for e in lst)
        legend1 = "Innovations for SIR epidemic on %d individuals:" % len(self)
        legend2 = "Row               List of proposed potential removals"
        #removals = "%s" % self.remove
        removals = '\n'.join(" %2d:              %s" % (pop - i, lstr(x)) for i, x in enumerate(self.remove))
        legend3 = "Target row"
        infections = "%s" % self.infect
        infections = '\n'.join([" %2d: %s" % \
           (pop - i,'\n     '.join(['  (%1d)        %s' % (j + 1, lstr(y)) \
               for j, y in enumerate(x)])) for i, x in enumerate(self.infect)])
        legend4 = "     (Origin)     List of proposed potential infections"
        return '\n'.join([legend1, legend2, removals, legend3, legend4, infections])
    def __len__(self):
        return len(self.remove)

class FreeEpidemic(object):
    """
    This class computes a (free) SIR epidemic, given an `Innovation` instance::

     >>> from pprint import pprint
     >>> innov = Innovations(remove=[[1, 1.6], [1.3], [0.5, 2]],
     ...                  infect=[[[0.4, 0.9], [0.6, 1.4]],
     ...                          [[0.2, 1.1, 1.5]]])

     >>> epidemic = FreeEpidemic(innovations=innov)
     >>> len(epidemic)
     3
     >>> epidemic._build_time_line()[:4] # First 4 incidents.
     [(0.2, 2, 1), (0.4, 3, 1), (0.5, 1), (0.6, 3, 2)]
     >>> pprint(epidemic())
     [(0, (2, 1, 0)),
      (0.2, (1, 2, 0)),
      (0.4, (0, 3, 0)),
      (0.5, (0, 2, 1)),
      (1, (0, 1, 2)),
      (1.6, (0, 0, 3))]

    """
    def __init__(self, innovations=None):
        if innovations is None:
            raise BadDataError("No innovations supplied for FreeEpidemic object")
        self.innov = innovations

    def __len__(self):
        return len(self.innov)

    def _build_time_line(self):
        """
        Constructs indexed sequence of incidents.
        """
        # Compute and store number of rows, and removals list, infections list.
        nnn = len(self)
        remove = self.innov.remove
        infect = self.innov.infect
        # List of lists of row indices, one for each removal time.
        res = [[nnn - i]*len(x) for i, x in enumerate(remove)]
        # List of (removal time, row mark).
        rem = zip(chain(*remove), chain(*res))

        # List of lists of pairs of row indices, one pair for each infection time.
        ins = chain(*[chain(*[[(nnn - i, j + 1)]*len(y) for j, y in enumerate(x)]) \
                                           for i, x, in enumerate(infect)])
        # List of lists of incoming infections for each row.
        in1 = chain(*[chain(*x) for x in infect])
        # List of (infection time, outgoing row, incoming row)
        inf = [(x, y[0], y[1]) for x, y in  zip(in1, ins)]

        # Return list of incidents sorted by time.
        return sorted(list(chain(rem, inf)))

    def __call__(self, infe=1):
        """
        Returns a sequence of changes of state of an SIR epidemic driven by
        `FreeEpidemic` innovations. Note that no conditioning is imposed here!
        """
        ttt, susc, remo = 0, len(self) - infe, 0
        trajectory = [(0, (susc, infe, remo))]
        legend = '[%f]: R=%d, i=%d, I+R=%d, j=%d'
        logging.info('[%f]: R=%d, i= , I+R=%d, j= ', ttt, remo, infe+remo)
        for incident in self._build_time_line():
            if len(incident) == 3:
                # The incident is a potential infection.
                ttt, i, j = incident
                # The infection terminates at row `i` and starts at row `j`.
                if i == infe + remo +1 and remo < j and j <= infe + remo:
                    # Row `i` is lowest susceptible, while row `j`
                    # is infected.
                    logging.info(legend, ttt, remo, i, infe+remo, j)
                    infe += 1
                    susc -= 1
                    trajectory.append((ttt, (susc, infe, remo)))
            if len(incident) == 2:
                # The incident is a potential removal.
                ttt, i = incident
                # The removal occupies row `i`.
                if remo < i and i <= infe + remo:
                    # Row `i` is infected.
                    logging.info(legend, ttt, remo, i, infe+remo, j)
                    infe -= 1
                    remo += 1
                    trajectory.append((ttt, (susc, infe, remo)))
        return trajectory


# \section{Functions}
def main(opt, arguments):
    """
    The action of the module as script should be concentrated here!
    No action is included for this demonstration script.
    """
    logging.info('No main actions')
    return


def _doctest():
    """
    Doctests.
    """
    logging.info('Commencing doctests')
    import doctest
    doctest_results = doctest.testmod()[0]
    testfile_results = doctest.testfile('DOCS/' + __file__[:-3] + '.txt', False)[0]
    if doctest_results == 0 and testfile_results == 0:
        os.system('touch DOCS/%s.doctested' % __file__)


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
