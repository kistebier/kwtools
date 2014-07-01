
                tex-cal: a TeX-Calendar made with Perl and gcal, Version: 0.6


Copyright (C) 1997-2005  René Scholz

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.


You can contact me by email:   Voland@Jena.Thur.de

or have a look at my webpage:  http://www.thur.de/~Voland/

----------------------------------------------------------------------------

This is a calendar creator build with perl, gcal and latex.
Running the perl script "create.cal.pl" outputs a printable calendar in
A4 size with a picture at the top of each page and a monthly calendar
below the picture.
The output format is PostScript and PDF.

tex-cal consists of the perl script "create.cal.pl" and the LaTeX file
"calendar.tex".

To use:

- copy the files "create.cal.pl" and "calendar.tex" to an empty directory

- get the pictures for the calendar

You need 12 pictures (one for every month) named "1" to "12" and one picture for
a titelpage named "0".
This pictures must be copied to the subdir "pics". For LaTeX they must be
converted to EPS files first, You can use the included script
"call-jpeg2ps.sh" for that (copy it to "pics" and call it from there).
This script calls the programm "jpeg2ps" which must be installed first.
Otherwise You must convert your picture files to eps by hand (for example with
convert from ImageMagick or xv etc.).

For pdflatex the files can be PNG or JPG files, which are directly useable
by pdflatex.

So in "pics/" there must be the files:

   0.eps  10.eps  11.eps  12.eps  1.eps  2.eps  3.eps  4.eps  5.eps  6.eps  7.eps  8.eps  9.eps
   0.jpg  10.jpg  11.jpg  12.jpg  1.jpg  2.jpg  3.jpg  4.jpg  5.jpg  6.jpg  7.jpg  8.jpg  9.jpg

(when using jpeg pictures for pdflatex).

If You have got all pictures, You should have a look at "calendar.tex" and
"create.cal.pl" and modify the files to your needs (for example change fonts, colors, text etc.).


- to create a new calendar for the current year, just run "./create.cal.pl".


You can get help with "./create.cal.pl -h":

Usage: create.cal.pl [options]

Options: -h         Show this help.
         -y <year>  Generate calendar for the year <year> with german holidays
         -b <BL>    Show only holidays from a specific bundesland <BL> (Example: -b DE_TR)
         -a         Show all (memorial days too)
	 -o <file>  Use additional custom holidays from <file>
         -d         Print a description of the holidays under the table
         -f         Print a frame around the description
         -q         Quiet (show no latex output etc.)
         -Q         Really Quiet (show no output at all except errors)
         -w         b/w text (use no text colors)
         -v         Show version


If gcal was compiled with the german language, all output is in german,
otherwise in english.

For an example output look at "demo.pdf", this is the page for december 2003.

- to add your own holidays/birthdays etc. use the option -o <file>.

First create a file with your new holidays named for example "my_holidays" and
insert the holidays like this:

Mark's Birthday + 2005-05-20

Then use -o my_holidays to add this holidays to the days calculated with gcal.
The file "sample.holidays" is an example holidays file.

----------------------------------------------------------------------------
Requirements:
  - perl
  - latex
  - pdflatex
  - dvips
  - gcal
  - 12+1 pictures, in eps and jpg/png formats


Any contributions and improvements are welcome ;)


have fun,
rené
