#!/usr/bin/perl
#
# [1997-01-06]  create.cal.pl
#               (C) René Scholz  <http://www.thur.de/~Voland/pub/perl/>
#
# Time-stamp: <2005-12-07  17:24:05, rscholz>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# This program was tested under debian 3.0 with:
#   - gcal 3.01
#   - dvips 5.92b
#   - LaTeX, PDFLaTeX:  e-TeX (Web2C 7.4.5) 3.14159-2.1  kpathsea version 3.4.5
#
# See the README for a detailed documentation.
############################################################################

use strict;
use vars qw($NAME $VERSION $USAGE $YEAR $MONTH_NAMES %HOLIDAYS %HNAMES $LANGUAGE
            $opt_y $opt_h $opt_v $opt_b $opt_c $opt_a $opt_q $opt_Q $opt_d
            $opt_w $opt_f $opt_o);
use Getopt::Std;

($NAME = $0) =~ s#.*/##;  # get basename from $0
$VERSION     = "0.6";

$USAGE=<<EOUSAGE;
Usage: $NAME [options]

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

For a list of known bundeslaender see: \$ gcal -h and look for the option -q
The default is to show all holidays from all bundeslaender.

You can add your own holidays (ex. birthdays) with the option -o <file>.
<file> should have lines like this:

Mark's Birthday + 2005-01-01


EOUSAGE
#        -c         Show only holidays which are common in all german bundeslaender [TODO]

&scan_cmdline();
&write_holidays();
&write_YEAR_file();
&scan_holidays("holidays.cal");
&scan_holidays($opt_o) if($opt_o);


# create the $month.tex files:
for my $m (1..12) { &month2tex($m); }

$_ = $opt_q ? "> /dev/null" : "";
system "latex -interaction=nonstopmode calendar $_";
if ($?) { print "An error occured while calling latex, return code: $?\n"; }
print "-" x 76 . "\n" unless ($opt_q);

system "pdflatex -interaction=nonstopmode calendar $_";
if ($?) { print "An error occured while calling pdflatex, return code: $?\n"; }
print "-" x 76 . "\n" unless ($opt_q);

$_ = $opt_q ? "-q" : "";
system "dvips $_ -Pcm -Pcmz -o calendar.ps calendar.dvi $_";
if ($?) { print "An error occured while calling dvips: $?\n"; }
unlink qw(calendar.log calendar.aux calendar.out YEAR.tex holidays.cal);
foreach (1..12) { unlink "$_.tex"; }

print "\n" . "-" x 76 unless ($opt_q);
unless ($opt_Q)
{
    print "\nOK. All done.\n\n";
    print "Used " . (keys %HOLIDAYS) . " Holidays:\n\n";
    foreach (sort hsort keys %HOLIDAYS) { print "    $_. ($HOLIDAYS{$_})\n"; }
    print "\nNow print your new calender 'calendar.pdf' or 'calendar.ps' on a good printer.\n";
}


###################################################################################
#                                 Subroutines                                     #
###################################################################################

# takes the output from "gcal -i -H no $month $YEAR" and creates $month.tex from it.
# sundays and holidays are printed bold.
# Holidays get an other color and an asterix.
sub month2tex
{
    my ($month) = @_;
    my (@m, $i, $d, $lm, $hnames);

    open (G, "gcal -i -H no $month $YEAR|") or die "Can't execute gcal: $!\n";
    while (<G>)
    {
        #if($month == 12) { print; }
        next if (/^\s*$|[a-z]+/);
        chomp();
        s/^\s+|\s+$//g;
        s/\s+/ /g;
        push (@m, $_);
    }
    close (G);

    open(MONTH_TEX_FILE, "> $month.tex") or die "Cannot write file $month.tex: $!\n";

    foreach $lm (0..$#m) # for each week
    {
        if ($lm eq $#m)  # last week of the month?
        {
            @_ = split(" ", $m[$lm]);

            $i = @_ eq 7  ?  6 : @_;
            foreach (1..$i)
            {
                $d = format_day(shift(@_), $month);
                print MONTH_TEX_FILE "$d &\t";
            }
            if (@_ ge 1) # if week is full (has sunday)
            {
                $d = format_day(shift(@_), $month);
                print MONTH_TEX_FILE "{\\bfseries $d}";
            }
            print MONTH_TEX_FILE "   \\\\\\hline\n";
            last;
        }

        # in the first week there may be less than 7 days:
        @_ = split(" ", $m[$lm]);
        $i = 7 - @_;
        foreach (1..$i) { print MONTH_TEX_FILE "&\t"; }

        $i = 6 - $i;
        foreach (1..$i)
        {
            $d = format_day(shift(@_), $month);
            print MONTH_TEX_FILE "$d &\t";
        }

        # now output the Sunday:
        $d = format_day(shift(@_), $month);
        print MONTH_TEX_FILE "{\\bfseries $d}\t\\\\\\hline\n";
    }

    if ($opt_d ) # print desciption of holidays in this month below the table
    {
        if (($HNAMES{$month}))
        {
            $_ = $opt_f ? "|l|" : "l"; # print with frame?
            print MONTH_TEX_FILE "  \\multicolumn{7}{$_}{";
            $_ = "{\\scriptsize\\sffamily $HNAMES{$month}\\hspace{1.55em}}\n";
            print MONTH_TEX_FILE "$_}\\\\";
            print MONTH_TEX_FILE "\\hline" if($opt_f);
            print MONTH_TEX_FILE "\n";
        }
        else
        {
            print MONTH_TEX_FILE "  \\multicolumn{7}{l}{";
            $_ = "{\\scriptsize\\sffamily\\phantom{AbMXxg}}}\\\\\n";
            print MONTH_TEX_FILE;
        }
    }
    
    print MONTH_TEX_FILE "  \\end{tabular}\n\\end{center}\n\n";

    close (MONTH_TEX_FILE);
}


# creates the LaTeX-code for printing a holiday
sub format_day
{
    my ($day, $month, $key) = @_;
    
    $key =  $day   < 10 ? "0$day."  : "$day.";
    $key .= $month < 10 ? "0$month" : "$month";

    if ($HOLIDAYS{$key})
    {
        $HNAMES{$month} .= "\$\\ast\$ $HOLIDAYS{$key} ($day.) \\hspace{.5em}";
        $day = "{\\phantom{\$^*\$}\\textcolor{holiday}{\\bfseries $day}\$^*\$}";
    }

    return $day;
}


# read the holidays from gcal-created file and saves them to $HOLIDAYS
sub scan_holidays
{
    my ($file) = @_;
    open(H, $file) or die "Cannot open file $file: $!\n";

    while (<H>)
    {
        next if (/^\s*$|\#/);
        /^(.+) +\+.+-(\d+)-(\d+)/;
        my ($desc, $month, $day) = ($1, $2, $3);
        $desc =~ s/\s*$//;
        $HOLIDAYS{"$day.$month"} = $desc;
    }
    close (H);
}


# sorts the array %HOLIDAYS as expected
sub hsort
{
    my($ad, $am) = split(/\./, $a);
    my($bd, $bm) = split(/\./, $b);

    return("$am-$ad" cmp "$bm-$bd");
}


sub write_holidays
{
    my $gcal_opts = $opt_a ? "-n" : "-N";

    # list of bundeslaender for getting holidays from gcal:
    @_ = qw(BB BL BR BW HA HS MV NS NW RP SA SH SL SN TR);
    $_ = $opt_b || "DE_" . join("+DE_", @_);

    $gcal_opts .= " -G -X -u -H no -q $_ --date-format=\"[%>04*Y-%<02*M-%1%>02*D%2]\" $YEAR";
    my $gcal_cmd = "gcal $gcal_opts | cut -d= -f1 | sed -e 's/(.*)//;s/ [-*#] / + /' | uniq";

    # call gcal and look if german or english version
    $_ = `gcal -V`;
    die "\nProgram 'gcal' not found on your system.\n" if (/^$/);

    $LANGUAGE = /Kompilations-Optionen/ ? "deutsch" : "english";

    open (HOLIDAYS, ">holidays.cal") or die "Cannot write holidays.cal: $!\n";
    print HOLIDAYS "# Holidays for the year $YEAR (for language: $LANGUAGE)\n#\n";
    print HOLIDAYS "# created with: $gcal_cmd >> holidays.cal \n#\n";
    close (HOLIDAYS);
    system "$gcal_cmd >> holidays.cal";
}


sub scan_cmdline()
{
    if (!@ARGV)
    {
        $YEAR = 1900 + (gmtime(time()))[5];
        print "\nNo year given. Assume the current year is: $YEAR\n\n";
        print "Is this correct ? (Otherwise use $NAME -y <year>)\n";
        print "\n(press return for OK or cancel now with ^C ...)\n";
        $_ = <>;
    }
    else
    {
        getopts('hy:b:cavqQdwfo:');
        die "Version: $VERSION\n"  if ($opt_v);
        die "$USAGE"               if ($opt_h || $opt_y eq "");
        
        if ($YEAR = $opt_y)
        {
            if ($YEAR < 0) { die "Year was < 0 !$USAGE"; }
        }
        else { die "$USAGE"; }
    }

    $opt_q = 1 if ($opt_Q);
}


sub write_YEAR_file()
{
    # remember year, day names and month names for calendar.tex:
    open (YEARFILE, ">YEAR.tex") or die "Cannot write YEAR.tex: $!\n";
    print YEARFILE "\\newcommand{\\YEAR}{$YEAR}\n%\n";

    if ($LANGUAGE eq "deutsch")
    {
        print YEARFILE <<EEE;
\\newcommand{\\MONDAY}    {Montag}
\\newcommand{\\TUESDAY}   {Dienstag}
\\newcommand{\\WEDNESDAY} {Mittwoch}
\\newcommand{\\THURSDAY}  {Donnerstag}
\\newcommand{\\FRIDAY}    {Freitag}
\\newcommand{\\SATURDAY}  {Sonnabend}
\\newcommand{\\SUNDAY}    {Sonntag}
%
\\newcommand{\\JAN}       {Januar}
\\newcommand{\\FEB}       {Februar}
\\newcommand{\\MAR}       {März}
\\newcommand{\\APR}       {April}
\\newcommand{\\MAY}       {Mai}
\\newcommand{\\JUN}       {Juni}
\\newcommand{\\JUL}       {Juli}
\\newcommand{\\AUG}       {August}
\\newcommand{\\SEP}       {September}
\\newcommand{\\OCT}       {Oktober}
\\newcommand{\\NOV}       {November}
\\newcommand{\\DEC}       {Dezember}
EEE
    }
    else
    {
        print YEARFILE <<EEE;
\\newcommand{\\MONDAY}    {Monday}
\\newcommand{\\TUESDAY}   {Tuesday}
\\newcommand{\\WEDNESDAY} {Wednesday}
\\newcommand{\\THURSDAY}  {Thursday}
\\newcommand{\\FRIDAY}    {Friday}
\\newcommand{\\SATURDAY}  {Saturday}
\\newcommand{\\SUNDAY}    {Sunday}
%
\\newcommand{\\JAN}       {January}
\\newcommand{\\FEB}       {February}
\\newcommand{\\MAR}       {March}
\\newcommand{\\APR}       {April}
\\newcommand{\\MAY}       {May}
\\newcommand{\\JUN}       {June}
\\newcommand{\\JUL}       {July}
\\newcommand{\\AUG}       {August}
\\newcommand{\\SEP}       {September}
\\newcommand{\\OCT}       {October}
\\newcommand{\\NOV}       {November}
\\newcommand{\\DEC}       {December}
EEE
    }

    # set the used colornames for LaTeX:
    print YEARFILE "%\n% define some colors.\n";
    print YEARFILE "\\definecolor{Black}       {rgb}{0,0,0}\n";
    if ($opt_w)
    {
        print YEARFILE <<EEE;
\\definecolor{ForestGreen} {rgb}{0,0,0}
\\definecolor{monthcolor}  {rgb}{0,0,0}
\\definecolor{holiday}     {rgb}{0,0,0}
\\definecolor{titelColor}  {rgb}{0,0,0}
\\definecolor{YEAR}        {rgb}{0,0,0}
EEE
    }
    else # default: use colors
    {
        print YEARFILE <<EEE;
% To calculate the rgb-values from X11 color names,
% use this script:  http://www.thur.de/~Voland/pub/perl/rgb2hex+tex.pl
%
%% \\definecolor{darkblue} {rgb}{0.15294117647058823529, 0.25098039215686274509, 0.54509803921568627450}
\\definecolor{ForestGreen} {rgb}{0.133333333333333, 0.545098039215686, 0.133333333333333}
\\definecolor{monthcolor}  {rgb}{0.54509803921568627450, 0.13725490196078431372, 0.13725490196078431372}
\\definecolor{holiday}     {rgb}{1, 0.2, 0.3}
\\definecolor{titelColor}  {rgb}{0, 0.54509803921568627450, 0.54509803921568627450}
\\definecolor{YEAR}        {rgb}{0.15294117647058823529, 0.25098039215686274509,0.54509803921568627450}
EEE
    }

    close (YEARFILE);
}
