#!/usr/bin/env python3
"""
A python module with logging

Metadata:

  - Author:    W.S.Kendall
  - Copyright: opensource (c) W.S.Kendall 2014, 2018
  - Date:      2014-04-26, revised 2017-12-12, 2018-01-01
  - URL:       http://www.wilfridkendall.co.uk
  - Generator: '/home/wilfrid/lib/python/generate.py' version 1.27.


Command-line options::

  usage: %prog [options] arguments
    --infect=infect:       infection list of lists;
    --remove=remove:       removal list;
    --seed=SEED:           integer seed for random number generator;
    --alfa=ALFA:           rate of infection;
    --beta=BETA:           rate of removal;
    --initial=INITIAL:     initial number of infectives;
    --n=N:                 number of individuals;
    --T=T:                 plot over time range [0, T];
    --title=title:         title for figure;
    --on=ON:               CSV string of plot elements to be shown (default is all); 
    --height=HEIGHT:       screen height in pixels (default 720);
    --width=WIDTH:         screen width in pixels (default 1024);
    --notext:              do not draw any text;
    --output=output:       produce postscript output and save in this file;
    --forceoutput:         do above without prompting;
    --consistent:          allow consistent extensions over time;
    --logging=LOGGING:     logging verbosity level.

Notes:
 - if seed for random number generator is unset then program will use
 `remove` and `infect` options.
 - values for 'logging' option:
 'DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'
 (decreasing level of verbosity), with 'WARNING' as default.

"""


# \section{Definitions}
# We need the logging module regardless of whether the #logging# option
# is deployed, since #logging.info# calls are scattered through the text.
import logging
import sys
import io
import configparser

from ast import literal_eval

from math import floor
from pprint import pformat # only needed when logging!
from random import expovariate, random, seed

from PIL import Image
from itertools import combinations, count, chain, zip_longest

from path3 import Path

from epidemic import Innovations, FreeEpidemic, INFINITY

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
class BadKeyError(Error):
    """
    Key does not have known prefix.
    """

# \section{Classes}
class Display(tk.Tk):
    """
    Frame for various buttons and Canvas, includes high-level drawing routines
    and printing.
    """
    def __init__(self, T, pop, background='white', \
                 height=720, width=1024, \
                 output=None, forceoutput=False, opt=None):
        tk.Tk.__init__(self)
        self.output = output
        self.notext = opt.notext
        self.line_start = None
        self.canvas = tk.Canvas(self, background='white', height=height, width=width)
        self.canvas.pack()

        # Read styles for plotting.
        self.color = configparser.ConfigParser()
        self.color.read(Path(__file__).dirname()/'static.cfg')

        # Button style.
        bprops = self.color['0-button']        
        # Dictionary to store state of plot elements.
        self.tog = {}
        for key in self.color.sections():
            index, tag = key.split('-',1)
            if index == '0':
                continue
            state = (opt.on is None or tag in opt.on)
            # Set state of tag using "on" option.
            self.tog[tag] = state

        if not forceoutput:
            logging.info('Create overall frame to hold all buttons')
            frm = tk.Frame(self)
            # Create #QUIT# and (if required) #SAVE# buttons.
            tk.Button(frm, text="QUIT", command=self.destroy, fg="red", **bprops).pack(side=tk.RIGHT, fill=tk.Y)
            if self.output is not None:
                tk.Button(frm, text="Save", command=self.save, fg="dark green", **bprops).pack(padx=5, side=tk.RIGHT, fill=tk.Y)
            logging.info('Create frames to hold buttons to control plot elements.')
            frm1 = tk.Frame(frm)
            frm11 = tk.Frame(frm1)
            frm12 = tk.Frame(frm1)
            # Create buttons to toggle raising / lowering of plot elements.
            for key in self.color.sections():
                logging.info('Processing %s' % key)
                index, tag = key.split('-',1)
                if index == '0':
                    continue
                elif index == '11':
                    f = frm11
                elif index == '12':
                    f = frm12
                else:
                    raise BadKeyError(key)
                logging.info('Creating Checkbutton for %s' % key)
                cb = tk.Checkbutton(f, text=tag, indicatoron=False,
                    command=lambda tag=tag: self.toggle(tag=tag), **bprops) 
                # Set state of Checkbutton using "on" option.
                state = (opt.on is None or tag in opt.on)
                # if not state:
                cb.toggle()
                # Display Checkbutton unless the aim is to produce specified output.
                # print(opt.output)
                cb.pack(padx=1, side=tk.LEFT)
            frm11.pack(side=tk.TOP, fill=tk.X)
            frm12.pack(side=tk.TOP, fill=tk.X)
            frm1.pack(side=tk.LEFT, fill=tk.X)
            frm.pack(fill=tk.X)
        self.canvas.pack()

        self.xmax, self.ymax = T, pop - 1
        self.w, self.h = width, height
        self.setup(T, pop)

    def toggle(self, tag=None):
        tog = self.tog[tag] = not self.tog[tag]
        if tog:
            self.canvas.lift(tag)
        else:
            self.canvas.lower(tag)

    def setup(self, T, pop):
        "Set up the basic elements of the canvas"
        logging.info('Display base and frame')
        self.base(0, 0, T, pop, tag='base')
        self.segment(0, 0, T, 0, tag='frame')
        self.segment(0, pop - 1, T, pop - 1, tag='frame')
        self.segment(0, 0, 0, pop - 1, tag='frame')
        self.segment(T, 0, T, pop - 1, tag='frame')

        logging.info('Display time axis')
        yneg, ydel = -0.01 * pop, -0.005 * pop
        self.segment(0, yneg, T, yneg, tag='axis')
        tx = 0
        while tx <= 10 * T:
            tic = 0.1 * tx
            if tx % 5 != 0:
                self.segment(tic, yneg, tic, yneg + ydel, tag='axis')
            elif tx % 10 !=0:
                self.segment(tic, yneg, tic, yneg + 2 * ydel, tag='axis')
            else:
                self.segment(tic, yneg, tic, yneg + 3 * ydel, tag='axis')
                self.insert_text(tic, yneg + 3 * ydel, text=str(tic), tag='xlabel')
            tx += 1
        self.insert_text(0.25 * T, 5 * yneg, text=str("Elapsed time"), tag='xlabel')

        logging.info('Display time-lines')
        xneg = - 0.02 * T
        for i in range(pop):
            self.insert_text(xneg, i, text=str(i + 1), tag='ylabel')
            self.segment(0, i, T, i, tag='timeline')
        self.insert_text(3 * xneg, 0.25 * pop, text=str("Timelines"), angle=90, tag='xlabel')

    def style(self):
        "Format the graphical elements of the canvas and read white options"
        for key in self.color.sections():
            index, tag = key.split('-',1)
            self.canvas.itemconfig(tag, **dict(self.color.items(key)))

    def save(self):
        "Save canvas as PNG file."
        ps = self.canvas.postscript(colormode='color')
        im = Image.open(io.BytesIO(ps.encode('utf-8')))
        im.save(self.output)
        logging.info("output saved to %s", self.output)

    def pixel(self, xcoord, ycoord):
        "Convert coordinate `(xcoord, ycoord)` to pixel reference."
        return self.w * (0.05 + (0.9 * xcoord) / self.xmax), \
                self.h * (0.1 + (0.8 * (self.ymax - ycoord)) / self.ymax)

    def segment(self, x0, y0, x1, y1, tag='null'):
        "Produce line segment."
        self.canvas.create_line(self.pixel(x0, y0), \
                         self.pixel(x1, y1), tag=tag)

    def base(self, x0, y0, x1, y1, tag='null'):
        "Produce graphics base."
        u0, v0 = self.pixel(x0, y0)
        u1, v1 = self.pixel(x1, y1)
        eu = 0.1 * (u1 - u0)
        ev = 0.1 * (v1 - v0)
        self.canvas.create_rectangle(u0 - eu, v0 - ev, \
                                     u1 + eu, v1 + ev, tag=tag)

    def disk(self, x, y, r=1, tag='null'):
        "Produce disk."
        a, b = self.pixel(x, y)
        self.canvas.create_oval(a - r, b - r, a + r, b + r, tag=tag)

    def infection(self, t, i, j, tag='null'):
        "Indicate infection using segment."
        #self.segment(t, i, t, j, tag=tag)
        self.segment(t, i, t, j, tag=tag)

    def removal(self, x, y, tag='null'):
        "Indicate removal using 'error' bitmap."
        self.canvas.create_bitmap(self.pixel(x, y), bitmap='error', tag=tag)

    def insert_text(self, x, y, text='', angle=0, tag='null'):
        "Insert text at specified position unless #notext# attribute is set."
        if self.notext:
            return
        # Need to specify font properly if this is to be printed to a file.
        self.canvas.create_text(self.pixel(x, y), text=text, angle=angle, tag=tag)


# \section{Functions}
def poisson(lamda, t0, t1):
    """
    Returns a Poisson pattern of points over the time interval '[t0, t1]'
    using intensity 'lamda'.
    """
    temp, points = t0 + expovariate(lamda), []
    while temp < t1:
        points.append(temp)
        temp += expovariate(lamda)
    return points

def marked_poisson(lamda, t0, t1):
    """
    Returns a marked Poisson pattern of points over the time interval '[t0, t1]'
    using intensity 'lamda'. Marks are independent Uniform'(0,1)'.
    """
    temp, marked_points = t0 + expovariate(lamda), []
    while temp < t1:
        marked_points.append((temp, random()))
        temp += expovariate(lamda)
    return marked_points


def main(opt, arguments):
    """
    The action of the module as script should be concentrated here!
    """
    logging.info('Entering main function')
    if opt.seed is None:
        logging.info('Use hard-coded data from command-line')
        rel = literal_eval(opt.remove)
        ill = literal_eval(opt.infect)
        T = max(max(chain(*rel)), max(chain(*[chain(*x) for x in ill])))
        pop = len(rel)
    else:
        logging.info('Create data using rng seeded by %s', int(opt.seed))
        seed(int(opt.seed))
        pop = int(opt.n)
        T = float(opt.T)
        alfa = float(opt.alfa)
        beta = float(opt.beta)
        if opt.consistent is None:
            # Note that the simulations here do not couple well over varying #T#.
            # This could be arranged if we used a marked point process.
            rel = [poisson(beta * T, 0, T) for i in range(pop)]
            ill = [[poisson(alfa * (pop - i) * T, 0, T) for j in range(i)] for i in range(1, pop)]
        else:
            # WARNING: This code as yet untested.
            logging.info('Create consistent data using rng')
            gam = (pop * (pop - 1) / 2) * alfa + pop * beta
            divide = (pop * (pop - 1) / 2) * alfa / gam
            rel = [[] for dummy in range(pop)]
            ill = [[[] for dummy in range(r)] for r in range(pop - 1, 0, -1)]
            idx = list(combinations(range(pop),2))
            for t, u in marked_poisson(gam, 0, T):
                if u > divide:
                    ix = floor(pop * (u - divide) / (1 - divide))
                    rel[ix].append(t)
                else:
                    a, b = idx[floor((pop * (pop - 1) / 2) * u /divide)]
                    ill[a][b - a - 1].append(t)

    logging.info('Set-up innovations structure')
    innov = Innovations(remove=rel, infect=ill)

    logging.info('Set-up Tk root and canvas')
    app = Display(T, pop, background='white', \
                output=opt.output, forceoutput=opt.forceoutput, \
                width=opt.width, height=opt.height, opt=opt)
    app.title(opt.title)
    logging.info('Display Canvas')
    c = app.canvas

    logging.info('Display putative infections')
    for i, lll in enumerate(innov.infect):
        for j, ll in enumerate(lll):
            for t in ll:
                app.infection(t, j, i + 0.25, tag='pI-lo')

    logging.info('Display putative removals')
    for i, ll in enumerate(innov.remove):
        for t in ll:
            app.removal(t, i, tag='pR')

    logging.info('Compute and display epidemic')
    epidemic = FreeEpidemic(innovations=innov)
    assert(pop == len(epidemic))
    results = epidemic(infe=opt.initial)

    logging.info('Display latent infections')
    for i, ll in enumerate(results.latent_infections):
        for t in ll:
            app.disk(t, i + 1, r=6, tag='lI')
            app.infection(t, i, i + 0.75, tag='lIc')

    logging.info('Display infectious portions of time-lines')
    itl, rtl = results.infection_times, results.removal_times
    for i, (t0, t1) in zip(count(), zip_longest(itl, rtl, fillvalue=INFINITY)):
        try:
            app.segment(t0, i, t1, i, tag='Infectious')
            app.removal(t1, i, tag='R') 
        except TypeError:
            app.segment(t0, i, T, i, tag='Infectious')
    logging.info('Also display activated infections')
    for i, t in zip(count(), itl[1:]):
        app.infection(t, i, i + 0.75, tag='aI')

    logging.info('Display epidemic trajectory')
    told, iold = 0, 0
    for t, sir in results.trajectory:
        i = sir[1] + sir[2] - 1
        app.segment(told, iold, t, iold, tag='Epidemic')
        app.segment(t, iold, t, i, tag='Epidemic')
        told, iold = t, i
    if sir[1] != 0:
        app.segment(t, i, T, i, tag='Epidemic')

    logging.info('Display Mordor')
    for i, t0 in enumerate(results.mordor):
        if t0 > 0:
            app.segment(0, i, t0, i, tag='Mordor')

    logging.info('Display no-fly zone')
    for i, nfy in enumerate(results.nofly_zone):
        mdr = results.mordor[i]
        if nfy > mdr:
            app.segment(mdr, i, nfy, i, tag='nofly')

    logging.info('Display West')
    for i, (t0, t1) in enumerate(results.West):
        if t0 != INFINITY:
            if t1 != INFINITY:
                app.segment(t0, i, t1, i, tag='West')
                app.disk(t1, i, r=6, tag='West')
            else:
                app.segment(t0, i, T, i, tag='West')

    logging.info('Display last viable infections')
    # print(list(enumerate(results.last_viable)))
    for i, t in enumerate(results.last_viable):
        if t != INFINITY:
            app.segment(t, i, t, i + 0.75, tag='lvI')

    logging.info('Format the graphical elements according to "on" option')
    app.style()
    for tag in app.tog.keys():
        if not app.tog[tag]:
            app.canvas.lower(tag)
            logging.info("Hide %s" % tag)
        else:
            logging.info("Retain %s" % tag)

    logging.info('Tkinter main loop')
    app.update_idletasks()
    if opt.forceoutput:
        app.save()
        app.destroy()
    else:
        app.mainloop()


# \section{Main script}
if __name__ == '__main__':
    import optionparse3 as optionparse
    option, args = optionparse.parse(__doc__)

    if option.logging is not None:
        logging.basicConfig(level=logging.__dict__[option.logging])
        logging.info('Logging level %s' % option.logging)

    if option.width is None:
        option.width = 1024
    else:
        option.width = int(option.width)

    if option.height is None:
        option.height = 720
    else:
        option.height = int(option.height)

    if option.alfa is None:
        option.alfa = 0.1
    else:
        option.alfa = float(option.alfa)

    if option.beta is None:
        option.beta = 0.1
    else:
        option.beta = float(option.beta)

    if option.n is None:
        option.n = 5
    else:
        option.n = int(option.n)

    if option.initial is None:
        option.initial = 1
    else:
        option.initial = int(option.initial)

    if option.T is None:
        option.T = 10
    else:
        option.T = float(option.T)

    if option.on is not None:
        option.on = option.on.split(',')
        logging.info('Display %s', option.on)

    if option.title is None:
        option.title = "Free SIR Epidemics: Figure"

    option.forceoutput = (option.forceoutput is not None)

    # The action of the module as script should be concentrated
    # in the following function, to facilitate profiling.
    main(option, args)


    logging.info('Finishing')
    sys.exit(0)
