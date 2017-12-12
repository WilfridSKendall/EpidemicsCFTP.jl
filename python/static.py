#!/usr/bin/env python3
"""
A python module with logging

Metadata:

  - Author:    W.S.Kendall
  - Copyright: opensource (c) W.S.Kendall 2014
  - Date:      2014-04-26
  - URL:       http://www.wilfridkendall.co.uk
  - Generator: '/home/wilfrid/lib/python/generate.py' version 1.27.


Command-line options::

  usage: %prog [options] arguments
    --seed=SEED:           integer seed for random number generator;
    --alfa=ALFA:           rate of infection;
    --beta=BETA:           rate of removal;
    --n=N:                 number of individuals;
    --T=T:                 plot over time range [0, T];
    --consistent:          allow consistent extensions over time;
    --logging=LOGGING:     logging verbosity level.

Notes:
 - if seed for random number generator is unset then program will use
 fixed hard-coded data.
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

from itertools import combinations, count
from math import floor
from pprint import pformat # only needed when logging!
from random import expovariate, random, seed

from epidemic import Innovations, FreeEpidemic

# Under python3 in Ubuntu it is necessary to install python3-tk!
try:
    import tkinter as tk
except ImportError:
    import Tkinter as tk

#\section{Exceptions}
class Error(Exception):
    """
    Generic exception to be raised by this module.
    """


# \section{Classes}
class Display(tk.Canvas):
    """
    Paint and display an image.
    """
    def __init__(self, root, xmax, ymax, **kwargs):
        tk.Canvas.__init__(self, **kwargs)
        self.xmax, self.ymax = xmax, ymax - 1
        self.w, self.h = kwargs['width'], kwargs['height']

    def xpxl(self, x):
        "Convert #x# coordinate to pixel 'x' reference."
        return self.w * (0.05 + (0.9 * x) / self.xmax)

    def ypxl(self, y):
        "Convert #y# coordinate to pixel 'y' reference."
        return self.h * (0.05 + (0.9 * (self.ymax - y)) / self.ymax)

    def segment(self, x0, y0, x1, y1, tag='null'):
        "Produce line segment."
        self.create_line(self.xpxl(x0), self.ypxl(y0), \
                         self.xpxl(x1), self.ypxl(y1), tag=tag)

    def disk(self, x, y, r=1, tag='null'):
        "Produce disk."
        a, b = self.xpxl(x), self.ypxl(y)
        self.create_oval(a - r, b - r, a + r, b + r, tag=tag)

    def removal(self, x, y, tag='null'):
        "Indicate removal using 'error' bitmap."
        self.create_bitmap(self.xpxl(x), self.ypxl(y), bitmap='error', tag=tag)

    def infection(self, t, i, j, tag='null'):
        "Indicate infection using segment."
        self.segment(t, i, t, j, tag=tag)

    def insert_text(self, x, y, text='', tag='null'):
        "Insert text at specified position."
        self.create_text(self.xpxl(x), self.ypxl(y), text=text, tag=tag)



# \section{Functions}
def poisson(lamda, t0, t1):
    """
    Returns a Poisson pattern of points over the time interval '[t0, t1]'
    using intensity 'lamda'.
    """
    t, points = t0 + expovariate(lamda), []
    while t < t1:
        points.append(t)
        t += expovariate(lamda)
    return points

def marked_poisson(lamda, t0, t1):
    """
    Returns a marked Poisson pattern of points over the time interval '[t0, t1]'
    using intensity 'lamda'. Marks are independent Uniform'(0,1)'.
    """
    t, marked_points = t0 + expovariate(lamda), []
    while t < t1:
        marked_points.append((t, random()))
        t += expovariate(lamda)
    return marked_points

def main(opt, arguments):
    """
    The action of the module as script should be concentrated here!
    """
    logging.info('Entering main function')
    if opt.seed is None:
        logging.info('Use hard-coded data')
        T = 2
        rel = [[1, 1.6], [1.3], [0.5, 2]]
        ill = [[[0.4, 0.9], [0.6, 1.4]], [[0.2, 1.1, 1.5]]]
    else:
        logging.info('Create data using rng')
        seed(int(opt.seed))
        n = int(opt.n)
        T = float(opt.T)
        alfa = float(opt.alfa)
        beta = float(opt.beta)
        if opt.consistent is None:
            # Note that the simulations here do not couple well over varying #T#.
            # This could be arranged if we used a marked point process.
            rel = [poisson(beta * T, 0, T) for i in range(n)]
            ill= [[poisson(alfa * T, 0, T) for j in range(i+1, n)] for i in range(n-1)]
        else:
            logging.info('Create consistent data using rng')
            gam = (n * (n - 1) / 2) * alfa + n * beta
            divide = (n * (n - 1) / 2) * alfa / gam
            rel = [[] for dummy in range(n)]
            ill = [[[] for dummy in range(r)] for r in range(n - 1, 0, -1)]
            idx = list(combinations(range(n),2))
            for t, u in marked_poisson(gam, 0, T):
                if u > divide:
                    ix = floor(n * (u - divide) / (1 - divide))
                    rel[ix].append(t)
                else:
                    a, b = idx[floor((n * (n - 1) / 2) * u /divide)]
                    ill[a][b - a - 1].append(t)
            #print(pformat(rel))
            #print(pformat(ill))
 
    logging.info('Set-up innovations structure')
    iv = Innovations(remove=rel, infect=ill)
    logging.info('r: %s' % pformat(iv.remove))
    logging.info('i: %s' % pformat(iv.infect))

    logging.info('Compute epidemic')
    epidemic = FreeEpidemic(innovations=iv)
    traj = epidemic()
    logging.info('t: %s' % str(traj))

    logging.info('Set-up Tk root')    
    root = tk.Tk()
    root.title('SIR Epidemics (I)')

    logging.info('Display Canvas')  
    max_y = epidemic.n
    c = Display(root, T, max_y, background='white', height=720, width=1024)
    c.pack()

    logging.info('Display frame')    
    c.segment(0, 0, T, 0, tag='frame')
    c.segment(0, epidemic.n - 1, T, epidemic.n - 1, tag='frame')
    c.segment(0, 0, 0, epidemic.n - 1, tag='frame')
    c.segment(T, 0, T, epidemic.n - 1, tag='frame')

    logging.info('Display time axis')
    yneg, ydel = -0.01 * max_y, -0.005 * max_y
    c.segment(0, yneg, T, yneg, tag='axis')
    tx = 0
    while tx <= 10 * T:
        tic = 0.1 * tx
        if tx % 5 != 0:
            c.segment(tic, yneg, tic, yneg + ydel, tag='axis')
        elif tx % 10 !=0:
            c.segment(tic, yneg, tic, yneg + 2 * ydel, tag='axis')
        else:
            c.segment(tic, yneg, tic, yneg + 3 * ydel, tag='axis')
            c.insert_text(tic, yneg + 3 * ydel, text=str(tic), tag='text')
        tx += 1

    logging.info('Display time-lines')    
    for i in range(epidemic.n):
        c.segment(0, i, T, i, tag='timeline')

    logging.info('Display potential removals')    
    for i, ll in enumerate(iv.remove):
        for t in ll:
            c.removal(t, i, tag='potential_removal')

    logging.info('Display potential infections')  
    for i, lll in enumerate(iv.infect):
        for j, ll in enumerate(lll):
            for t in ll:
                c.disk(t, i, r=4, tag='infection_incident')
                c.infection(t, i, i + j + 1, tag='potential_infection')

    logging.info('Compute infectious portions of time-lines')    
    I = traj[0][1][1]
    infection, removal = [0] * I, []
    for t, x in traj[1:]:
        infection.extend([t] * (x[1] - I))
        removal.extend([t] * (I - x[1]))
        I = x[1]
    if len(removal) < len(infection):
        removal.extend([T] * (len(infection) - len(removal)))
    for i, t0, t1 in zip(count(), infection, removal):
        logging.info((i, t0, t1))
        c.segment(t0, i, t1, i, tag='infectious')

    logging.info('Compute epidemic trajectory')    
    told, iold = 0, 0
    for t, sir in traj:
        i = sir[1] + sir[2] - 1
        c.segment(told, iold, t, iold, tag='epidemic')
        c.segment(t, iold, t, i, tag='epidemic')
        told, iold = t, i

    logging.info('Format the graphical alements')    
    c.itemconfig('text', anchor=tk.N)
    c.itemconfig('timeline', width=2, fill='purple')
    c.itemconfig('frame', fill='grey50')
    c.itemconfig('potential_removal', foreground='red')
    c.itemconfig('potential_infection', width=6, fill='palegreen', arrow=tk.LAST)
    c.itemconfig('infection_incident', outline='red', width=2)
    c.itemconfig('infectious', width=6, fill='yellow', arrow=tk.LAST)
    c.itemconfig('epidemic', width=2, fill='red')

    logging.info('Tkinter main loop')    
    root.mainloop()



# \section{Main script}
if __name__ == '__main__':
    import optionparse3 as optionparse
    option, args = optionparse.parse(__doc__)

    if option.logging is not None:
        logging.basicConfig(level=logging.__dict__[option.logging])
        logging.info('Logging level %s' % option.logging)

    if option.alfa is None:
        option.alfa = 0.1

    if option.beta is None:
        option.beta = 0.1

    if option.n is None:
        option.n = 5

    if option.T is None:
        option.T = 10


    # The action of the module as script should be concentrated
    # in the following function, to facilitate profiling.
    main(option, args)


    logging.info('Finishing')
    sys.exit(0)


