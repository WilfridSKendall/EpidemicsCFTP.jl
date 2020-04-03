#!/usr/bin/env python3
"""
A 'python3' module with logging, doctest. Constructs innovations for simulating SIR epidemic.

Metadata:

  - Author:    W.S.Kendall
  - Copyright: opensource (c) W.S.Kendall 2014, 2018, 2020
  - Date:      2014-04-26, revised 2020-04-03
  - URL:       http://www.wilfridkendall.co.uk
  - Generator: '/home/wilfrid/lib/python/generate.py' version 1.27.

Command-line options::

  usage: %prog [options] arguments
    --doctest:             perform doctests;
    --logging=LOGGING:     logging verbosity level.
"""

# \section{Definitions}
# Logging module required since #logging.info# calls present in code.
import logging
import os
import sys

from itertools import chain, count, zip_longest

INFINITY = "Infinity"


#\section{Exceptions}
class Error(Exception):
    """
    Generic exception to be raised by this module.
    """
    message = "Generic error raised"
    def __str__(self):
        return self.message
    
class BadInnovationsError(Error):
    """
    Raised when issue with 'Innovations' arises.
    """
    def __init__(self, msg):
        self.message = msg

class BadFreeEpidemicError(Error):
    """
    Raised when issue with 'FreeEpidemic' arises.
    """
    def __init__(self, msg):
        self.message = msg

class PopulationVersusRemovalsError(BadInnovationsError):
    """
    Raised when population (from 'n') is inconsistent with length of 'infect'.
    """
    def __init__(self, n, remove):
        self.message = f"population ({n}) != removal structure length ({len(remove)})"

class PopulationVersusInfectionsError(BadInnovationsError):
    """
    Raised when population (from 'n') is inconsistent with length of 'infect'.
    """
    def __init__(self, n, infect):
        self.message = f"population ({n}) != 1 + infection structure length ({len(infect)})"
    
class InfectionStructureError(BadInnovationsError):
    """
    Raised when population (from 'remove') is inconsistent with structure of 'infect'.
    """
    def __init__(self, llst, rnge):
        self.message = f"infection data sub--list lengths are {llst} not {rnge}"


# \needspace{.5\textheight}
# \section{Classes}
class Innovations(object):
    """
    This class implements innovations related to
    construction of an SIR epidemic trajectory, thus providing
    reproducible generation of SIR epidemics. 
    The innovations are defined on initialization *via* keyword arguments.
    Here we create such an instance, print it, and check number of individuals::

     >>> innov = Innovations(remove=[[1, 1.6], [1.3], [0.5, 2], [1.9]],
     ...                     infect=[[[0.2, 1.1, 1.5]],
     ...                             [[0.4, 0.9], [0.6, 1.4]],
     ...                             [[0.03], [0.55, 0.7, 1.1], [1.35]]
     ...                            ])
     >>> print(innov)
     Innovations for SIR epidemic on 4 individuals:
     TLine             List of proposed potential removals
       4:              1.90
       3:              0.50 2.00
       2:              1.30
       1:              1.00 1.60
     Active timeline (infection works if top of infectives)
     TLine  (Mark)     List of proposed potential infections
       3:   (3)        1.35
            (2)        0.55 0.70 1.10
            (1)        0.03
       2:   (2)        0.60 1.40
            (1)        0.40 0.90
       1:   (1)        0.20 1.10 1.50
     >>> innov.n
     4

    An 'Innovations' instance is effectively
    a list composed of two sub-lists, one for potential removals and
    one for potential infections. Let the total number
    of individuals (equivalently, timelines) be 'n'. 
    Here 'n=3'.
    The first sub-list is the 'remove'
    list, containing 'n' sub-sub-lists, one for each timeline,
    working from timeline '1' up to timeline 'n' according to the
    algorithm description
    in the paper. Each such sub-sub-list is an ordered list of potential
    removal times, the mark for each of these removals being implied by
    the timeline corresponding to the sub-sub-list.

    The second sub-list is the 'infect' sub-list, containing 'n-1'
    sub-sub-lists. Each of these sub-sub-lists corresponds to a timeline 'A'
    starting at timeline '1' and working up to timeline 'n-1', and contains
    sub-sub-sub-lists of potential infection times of infections acting on the
    timeline immediately above 'A'. The sub-sub-sub-lists correspond 
    to timelines 'B' which are *at* or *below* the timeline 'A'.
    An potential infection is not effective unless timelines 'A' and 'B' 
    are infective at the relevant time, and the timeline immediately
    above timeline 'A' is susceptible.
    
    The class runs sanity checks on initialization, and provides a printing method
    as well as accessor methods 'removal_str' and 'infection_str'.
    """

    _outstr = '\n'.join(["Innovations for SIR epidemic on {} individuals:",
     "{}", "{}"])
    _remstr1 = "TLine             List of proposed potential removals"
    _remstr2 = " %2d:              %s"
    _infstr1 = "Active timeline (infection works if top of infectives)" \
             "\nTLine  (Mark)     List of proposed potential infections"
    _infstr2 = "\n     "
    _infstr3 = "  (%1d)        %s"

    def __init__(self, remove=None, infect=None):
        self.remove, self.infect = remove, infect
        self.n = len(self.remove)
        self.sanity_check()
        
    def __repr__(self):
        return "%s\n%s" % (self.remove, self.infect)
    
    def __str__(self):
        return self._outstr.format(self.n, self.removal_str(), self.infection_str())
    
    def removal_str(self):
        """
        Structure reversed list of removals.
        """
        rem = enumerate(reversed(self.remove))
        return '\n'.join([self._remstr1,
            '\n'.join(self._remstr2 % (self.n - i, lstr(x)) for i, x in rem)])
    
    def infection_str(self):
        """
        Structure reversed list of infections.
        """
        inf = enumerate(reversed(self.infect))
        return '\n'.join([self._infstr1,
            '\n'.join([" %2d: %s" % \
                (self.n - i - 1,
                 self._infstr2.join(reversed([self._infstr3 % (j + 1, lstr(y)) \
                     for j, y in enumerate(x)]))) for i, x in inf])])
    
    def sanity_check(self):
        """'remove' to be a list of length given by population 'n';  

        'infect' to be made up of one list of sub-lists of potential infections
            for each timeline except for the first timeline, hence 'n-1' sub-lists 
            (first timeline is *begins* as infected);  

        and each sub-list in 'infect' to be made up of sub-sub-lists of potential
            infections of lengths rising from '1' to index of sub-list.
        """
        if not self.n == len(self.remove):
            raise PopulationVersusRemovalsError(self.n, self.remove)
        if self.n - len(self.infect) != 1:
            raise PopulationVersusInfectionsError(self.n, self.infect)
        llst, rnge = list(map(len, self.infect)), list(range(1, self.n))
        if llst != rnge:
            raise InfectionStructureError(llst, rnge)

# \needspace{.2\textheight}        
class FreeEpidemic(object):
    """
    This class computes a (free) SIR epidemic, given an 
    'Innovation' instance. It is call-able, and returnCompute and ss
    a list of changes, each change summarized by time of change, 
    and then a tuple giving numbers of Susceptibles,
    Infectives, and Removals::

     >>> innov = Innovations(remove=[[1, 1.6], [1.3], [0.5, 2]],
     ...                     infect=[[[0.2, 1.1, 1.5]],
     ...                             [[0.4, 0.9], [0.6, 1.4]]
     ...                            ])

     >>> epidemic = FreeEpidemic(innovations=innov)
     >>> epidemic.n
     3
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
            raise BadFreeEpidemicError("FreeEpidemic object without Innovations")
        self.innov = innovations
        self.n = self.innov.n

    def _build_time_line(self):
        """
        Constructs time-ordered sequence of incidents. The evolution of the epidemic
        can be determined entirely, and with great ease, from this list.
        """
        logging.info("Store enumerations of removals list, infections list")
        remove, infect = enumerate(self.innov.remove), enumerate(self.innov.infect)
        logging.info("Create list of lists of row levels, one for each removal time")
        res = [[i + 1] * len(x) for i, x in remove]
        logging.info("Create list of (removal time, row mark) using zip and chain")
        rem = zip(chain(*self.innov.remove), chain(*res))

        logging.info("Create list of lists of (in, out) pairs for each potential infection")
        ins = [[[(i + 2, j + 1)]*len(y) for j, y in enumerate(x)] for i, x, in infect]
        logging.info("Create parallel lists of (in, out) and of times per potential infection")
        in1 = [x for ll in self.innov.infect for y in ll for x in y]
        in2 = [x for ll in ins for y in ll for x in y]
        logging.info(in1)
        logging.info(in2)
        logging.info("Create list of (infection time, outgoing row, incoming row)")
        inf = [(x, y[0], y[1]) for x, y in  zip(in1, in2)]

        logging.info("Create list of incidents sorted by time")
        result = sorted(list(chain(inf, rem)))
        logging.info(result)
        return result


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
        ttt, susc, remo = 0, self.n - infe, 0
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
                    # Note we will need to use the final value of 
                    # #remo# when computing #West# below!
        
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
        # for i, t1 in zip(count(), itl):
        for i, t1 in enumerate(itl):
            rmvl = self.innov.remove[i]
            try:
                t0 = max([t for t in rmvl if t < t1])
                mtl.append(t0)
            except ValueError:
                mtl.append(0)
        for i in range(len(itl), self.n):
            rmvl = self.innov.remove[i]
            try:
                t0 = max([t for t in rmvl])
                mtl.append(t0)
            except ValueError:
                mtl.append(0)
        
        logging.info('Compute no-fly zone, working down from top.')
        self.results.nofly_zone = [0] * self.n
        nofly = mtl[self.n - 1]
        for i, ill in reversed(list(enumerate(latent_infections))):
            try:
                nofly = max([t for t in ill if t < nofly])
            except ValueError:
                nofly = 0
            nofly = max(nofly, mtl[i])
            self.results.nofly_zone[i] = nofly
        # Now adjust to ensure #nofly_zone# is non-decreasing.
        nofly = self.results.nofly_zone[0]
        for i in range(len(self.results.nofly_zone)):
            nofly = max(nofly, self.results.nofly_zone[i])
            self.results.nofly_zone[i] = nofly

        logging.info('Compute West')
        wtl = self.results.West
        eventl = list(zip_longest(itl, rtl, fillvalue=INFINITY))
        for i, (t0, t1) in enumerate(eventl):
            rmvl = self.innov.remove[i]
            if t0 == INFINITY:
                t = INFINITY
            elif t1 == INFINITY:
                # I think removals should follow infections!
                try:
                    t = min([u for u in rmvl if t0 <= u])
                except ValueError:
                    t = t0
            else:
                # I think removals should follow infections!
                try:
                    t = min([u for u in rmvl if t0 <= u and u <= t1])
                except ValueError:
                    t = t0
            wtl.append((t, t1))

        logging.info('Compute last viable infections')
        wtl = self.results.West
        lil = self.results.latent_infections
        liv = self.results.last_viable = []

        li = INFINITY
        for i, (t0, t1) in reversed(list(enumerate(wtl))):
            if li == INFINITY:
                li = t0
            elif t0 != INFINITY:
                li = min(t0, li)
            # No need to do anything if #t0 == INFINITY#.
            if i > 0 and t0 != INFINITY:
                preinfect = self.results.infection_times[i]
                if li == INFINITY:
                    lil1 = lil[i - 1]
                else:
                    lil1 = [s for s in lil[i - 1] if preinfect <= s and s < li]

                if self.results.infection_times[i] == 0:
                    li = self.results.infection_times[i]
                elif lil1:
                    li = max(lil1)
                else:
                    li = self.results.infection_times[i]
                
                liv.append(li)
        liv.reverse()

        logging.info("Return results as data record object")
        return self.results

# \needspace{.2\textheight}        
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
        self.West = []
        self.viable = []

    def __str__(self):
        summary = ["Time    S, I, R"]
        summary.extend(["%4.2f   %s" % (ins, str(ev)) for ins, ev in self.trajectory])
        summary.append("Infections at:\n%s" % str(self.infection_times))
        summary.append("Removals at:\n%s" % str(self.removal_times))
        summary.append("Mordor ends at:\n%s" % str(self.mordor))
        return '\n'.join(summary)


# \needspace{.2\textheight}        
# \section{Functions}
def lstr(lst):
    """
    Utility function to convert list of floats into string of space-separated floats.
    """
    return ' '.join('%4.2f' % e for e in lst)

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
