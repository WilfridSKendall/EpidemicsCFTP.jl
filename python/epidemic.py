#!/usr/bin/env python3
"""
A python module with logging, doctest to construct a set
of innovation incidents to allow simulation of an SIR epidemic.

Metadata:

  - Author:    W.S.Kendall
  - Copyright: opensource (c) W.S.Kendall 2014, 2018
  - Date:      2014-04-26, revised 2018-01-01
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

from itertools import chain, count


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

     >>> innov = Innovations(remove=[[1, 1.6], [1.3], [0.5, 2]],
     ...                     infect=[[[0.2, 1.1, 1.5]],
     ...                             [[0.4, 0.9], [0.6, 1.4]]
     ...                            ])
     >>> len(innov)
     3

    The innovation list structure is to be interpreted as follows::

     >>> print(innov)
     Innovations for SIR epidemic on 3 individuals:
     Row               List of proposed potential removals
       3:              0.50 2.00
       2:              1.30
       1:              1.00 1.60
     Target row
          (Origin)     List of proposed potential infections
       3:   (2)        0.60 1.40
            (1)        0.40 0.90
       2:   (1)        0.20 1.10 1.50

    Note the data format. An 'Innovations' instance is effectively
    a list of two sub-lists. The first sub-list is the 'remove'
    list, containing 'n' sub-sub-lists, one for each timeline row,
    working from row '1' up to row 'n' as per algorithm described
    in the paper. Each such sub-sub-list is an ordered list of potential
    removal times, the mark for each of these removals being implied by
    the row corresponding to the sub-sub-list.

    The second sub-list is the 'infect' sub-list, containing 'n-1'
    sub-sub-lists. Each of these sub-sub-lists corresponds to a timeline
    row starting at row '2' and working up to row 'n', and contains
    sub-sub-sub-lists of infection times of infections incoming to that
    row, one sub-sub-sub-list corresponding to each row *at* or 
    *below* the timeline row corresponding to the relevant sub-sub-list.
    """
    def __init__(self, remove=None, infect=None):
        self.remove, self.infect = remove, infect
        # self.n = len(remove)

        # Sanity checks. We require:
        #
        # 1. #self.infect# to be made up of one list of lists of potential infections
        #    for each row except for the first row,
        #
        # 2. and each sub-list in #self.infect# to be made up of one list of potential
        #    infections for each sub-list located at or below current sub-list.
        if len(self.infect) != len(self) - 1:
            raise BadDataError("infection and removal data structure lengths do not agree")
        for i, llst in enumerate(self.infect):
            if len(llst) != i + 1:
                raise BadDataError("infection data sub-structure is inconsistent")
    def __repr__(self):
        return "%s\n%s" % (self.remove, self.infect)
    def __str__(self):
        pop = len(self)
        def lstr(lst):
            "Temporary function to convert list of floats into string of space-separated floats"
            return ' '.join('%4.2f' % e for e in lst)
        # Enumerate reversed lists of removals and infections so that printed result looks like graphics.
        rem = enumerate(reversed(self.remove))
        inf = enumerate(reversed(self.infect))
        legend1 = "Innovations for SIR epidemic on %d individuals:" % len(self)
        legend2 = "Row               List of proposed potential removals"
        removals = '\n'.join(" %2d:              %s" % (pop - i, lstr(x)) for i, x in rem)
        legend3 = "Target row"
        infections = '\n'.join([" %2d: %s" % \
           (pop - i,'\n     '.join(reversed(['  (%1d)        %s' % (j + 1, lstr(y)) \
               for j, y in enumerate(x)]))) for i, x in inf])
        legend4 = "     (Origin)     List of proposed potential infections"
        return '\n'.join([legend1, legend2, removals, legend3, legend4, infections])
    def __len__(self):
        return len(self.remove)

class Results(object):
    """
    This class provides a data record structure to capture results from 'FreeEpidemic'.
    Doctests are implied by the 'FreeEpidemic' doctests.
    """
    def __init__(self, trajectory, infection_times, removal_times, latent_infections):
        logging.info('Import trajectory, infection times, removal times, and latent infections')
        self.trajectory = trajectory
        self.infection_times = infection_times
        self.removal_times = removal_times
        self.latent_infections = latent_infections

        self.nofly_zone = []

        self.latent_removals = []
        self.mordor = []

    def __str__(self):
        summary = ["Time    S, I, R"]
        summary.extend(["%4.2f   %s" % (ins, str(ev)) for ins, ev in self.trajectory])
        summary.append("Infections at:\n%s" % str(self.infection_times))
        summary.append("Removals at:\n%s" % str(self.removal_times))
        summary.append("Mordor ends at:\n%s" % str(self.mordor))
        return '\n'.join(summary)


class FreeEpidemic(object):
    """
    This class computes a (free) SIR epidemic, given an 
    'Innovation' instance::

     >>> innov = Innovations(remove=[[1, 1.6], [1.3], [0.5, 2]],
     ...                     infect=[[[0.2, 1.1, 1.5]],
     ...                             [[0.4, 0.9], [0.6, 1.4]]
     ...                            ])

     >>> epidemic = FreeEpidemic(innovations=innov)
     >>> len(epidemic)
     3
     >>> epidemic._build_time_line()[:4] # First 4 incidents.
     [(0.2, 2, 1), (0.4, 3, 1), (0.5, 3), (0.6, 3, 2)]

    Now we calculate the epidemic evolution as a list of changes, each change
    summarised by time of change, and then a tuple giving numbers of Susceptibles,
    Infectives, and Removals::

     >>> print(epidemic())
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
        remove = enumerate(self.innov.remove)
        infect = enumerate(self.innov.infect)
        # List of lists of row levels, one for each removal time.
        res = [[i + 1] * len(x) for i, x in remove]
        # List of (removal time, row mark).
        rem = zip(chain(*self.innov.remove), chain(*res))

        # List of lists of pairs of row levels, one pair for each infection time.
        ins = [[[(i + 2, j + 1)]*len(y) for j, y in enumerate(x)] for i, x, in infect]
        # List of lists of incoming infections for each row.
        in1 = [x for ll in self.innov.infect for y in ll for x in y]
        in2 = [x for ll in ins for y in ll for x in y]
        logging.info(in1)
        logging.info(in2)
        # List of (infection time, outgoing row, incoming row)
        inf = [(x, y[0], y[1]) for x, y in  zip(in1, in2)]

        # Return list of incidents sorted by time.
        return sorted(list(chain(inf, rem)))

    def _infectious_periods(self, trajectory):
        """
        Returns two lists of start-times and (if known) end-times of infectious periods.
        """
        logging.info("Compute initial number of infectives in trajectory")
        I = trajectory[0][1][1]
        infections, removals = [0] * I, []
        for t, x in trajectory[1:]:
            infections.extend([t] * (x[1] - I))
            removals.extend([t] * (I - x[1]))
            I = x[1]
        return infections, removals

    def __call__(self, infe=1, pretty=False):
        """
        Returns a sequence of changes of state of an SIR epidemic driven by
        `FreeEpidemic` innovations. Note that no conditioning is imposed here!
        """
        ttt, susc, remo = 0, len(self) - infe, 0
        trajectory = [(0, (susc, infe, remo))]
        legend1 = '[%f]: R=%d, i=%d, I+R=%d, j=%d'
        legend2 = '[%f]: R=%d, i=%d, I+R=%d'
        logging.info('[%f]: R=%d, i= , I+R=%d, j= ', ttt, remo, infe+remo)
        for incident in self._build_time_line():
            if len(incident) == 3:
                # The incident is a potential infection.
                ttt, i, j = incident
                # The infection terminates at row 'i'
                # and starts at row 'j'.
                if i == infe + remo + 1 and remo < j and j <= infe + remo:
                    # Row 'i' is lowest susceptible, 
                    # while row 'j' is infected.
                    logging.info(legend1, ttt, remo, i, infe+remo, j)
                    infe += 1
                    susc -= 1
                    trajectory.append((ttt, (susc, infe, remo)))
            if len(incident) == 2:
                # The incident is a potential removal.
                ttt, i = incident
                # The potential removal occupies row `i`.
                if remo < i and i <= infe + remo:
                    # Row `i` is removed.
                    logging.info(legend2, ttt, remo, i, infe+remo)
                    infe -= 1
                    remo += 1
                    trajectory.append((ttt, (susc, infe, remo)))
        
        itl, rtl = self._infectious_periods(trajectory)

        logging.info('Compute latent infections, namely those infections initiated before removal.')
        latent_infections = []
        for i, lll in enumerate(self.innov.infect):
            temp = [t for j, ll in enumerate(lll) \
                for t in ll if j >= len(rtl) or t <= rtl[j]]
            latent_infections.append(temp)

        self.results = Results(trajectory, itl, rtl, latent_infections)

        logging.info('Compute Mordor')
        mtl = self.results.mordor
        for i, t1 in zip(count(), itl):
            rmvl = self.innov.remove[i]
            try:
                t0 = max([t for t in rmvl if t < t1])
                mtl.append(t0)
            except ValueError:
                mtl.append(0)
        for i in range(len(itl), len(self)):
            rmvl = self.innov.remove[i]
            try:
                t0 = max([t for t in rmvl])
                mtl.append(t0)
            except ValueError:
                mtl.append(0)
        
        logging.info('Compute no-fly zone, working down from top.')
        self.results.nofly_zone = [0] * len(self)
        nofly = mtl[len(self) - 1]
        for i, ill in reversed(list(enumerate(latent_infections))):
            try:
                nofly = max([t for t in ill if t < nofly])
            except ValueError:
                nofly = 0
            nofly = max(nofly, mtl[i])
            self.results.nofly_zone[i] = nofly

        logging.info("Return results as data record object")
        return self.results


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
    testfile_results = doctest.testfile(__file__[:-3] + '-doc.md', False)[0]
    if doctest_results == 0 and testfile_results == 0:
        os.system('touch DOC/%s.doctested' % __file__)


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
