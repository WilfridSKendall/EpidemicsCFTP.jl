#! /usr/bin/env python
# -*- coding: UTF-8 -*-
"""    Author: -- M. Simionato
    Revised by: -- W.S. Kendall
    Date: -- April 2004, September 2005

Use 'optionparse' as follows.  Write a module level docstring
like this::

  '''usage: %prog files [options]
       -d, --delete: delete all files
       -e, --erase = ERASE: erase the given file'''

The main program is driven by the various 'option' flags.
Here is an example::

  # sketch of a script to delete files
  if __name__=='__main__':
      import optionparse
      option,args=optionparse.parse(__doc__)
      if not args and not option: optionparse.exit()
      elif option.delete: print "Delete all files"
      elif option.erase: print "Delete the given file %s" % option.erase

Notice that 'optionparse' parses the docstring by looking at the
characters ",", ":", "=", "\\n", so be careful in using
them. Incorrectly formatted docstrings yield 'SyntaxError' or, worse
still, the script will not work as expected.
"""
__RCSID__ = '$Id: optionparse.py,v 2.8 2006/07/30 18:29:49 Wilfrid Development Wilfrid $'
__Revision__ = '$Revision: 2.8 $'[1:-1].replace('Revision: ','').strip()
__State__ = '$State: Development $'[1:-1].replace('State: ','').strip()

import optparse, re, sys

DOCFLAG = '--docstring'
USAGE = re.compile(r'(?s)\s*usage: (.*?)(\n[ \t]*\n|$)')

def nonzero(self):
    # This will become the nonzero method of #optparse.Values#.
    "True if options were given"
    for value in self.__dict__.itervalues():
        if value is not None:
            return True
    return False

optparse.Values.__nonzero__ = nonzero # \ Fix #optparse.Values# dynamically.

class ParsingError(Exception):
    pass

optionstring = ""

def exit(msg=""):
    """
    Redefining exit (probably should alter this!)
    """
    raise SystemExit(msg or optionstring.replace("%prog", sys.argv[0]))

def parse(docstring, arglist=None, version=""):
    """
    Parse module-level docstring.
    """
    global optionstring
    optionstring = docstring
    match = USAGE.search(optionstring)
    if not match:
        raise ParsingError("Cannot find the option string")
    optlines = match.group(1).splitlines()
    try:
        parser = optparse.OptionParser(optlines[0], version=version)
        docflag = True
        for line in optlines[1:]:
            opt, help = line.split(':')[:2]
            # shorter, longer = opt.split(',')[:2]
            optlist = [o.split('=')[0].strip() for o in opt.split(',')]
            if '=' in opt:
                action = 'store'
                # longer = longer.split('=')[0]
            else:
                action = 'store_true'
            parser.add_option(action = action, help = help.strip(), *optlist)
            docflag &= DOCFLAG not in optlist
        if docflag:
            parser.add_option(DOCFLAG, action='callback', \
                              callback=print_docstring, \
                              callback_args=(docstring,),\
                              help='print docstring')
    except (IndexError, ValueError):
        raise ParsingError("Cannot parse the option string correctly")
    return parser.parse_args(arglist)

def print_docstring(option, opt_str, value, parser, args):
    print(args)
    raise SystemExit


# Here is a non-functional example!
if __name__ == '__main__':
    import optionparse
    option, args = optionparse.parse(__doc__, version=__RCSID__)
    if not args and not option:
        optionparse.exit()
    elif option.delete:
        print("Delete all files")
    elif option.erase:
        print("Delete the given file %s" % option.erase)

    print(option.__dict__)

    raise SystemExit
