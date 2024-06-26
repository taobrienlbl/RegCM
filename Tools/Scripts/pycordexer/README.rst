####
PyCordexer
####


The *PyCordexer* scripts have been developed to ease the RegCM Model User
in converting variables in RegCM model output files into the netCDF format
respecting the CORDEX experiment conventions.

It has been developed to satisfy the requirements in the 05/03/2014 release
of the CORDEX Specification Document available from the DMI site at:

   http://cordex.dmi.dk/joomla

The *PyCordexer* script have been developed by ICTP staff to post-process
the CREMA experiment output dataset to be contributed to the CORDEX archive,
and have been adapted afterwards to post-process the latest RegCM model output
formats.

Any output file of the RegCM model from version 4.3 onward should be compatible
with the *PyCordexer* scripts.

Requirements
------------

To run the python script, you need a working Python2 interpreter (2.7 is
suggested) and netCDF4 Python library:

   https://unidata.github.io/netcdf4-python

The package requirement list for the library can be found at in the above
site.

Installation
------------

Part of the interpolation and derived variable calculation has been taken
from RegCM Model source code, and you need to compile the fortran source
codes in the *PyCordexer* directory using the f2py program of the Python
numpy package, which is a requirement of the netcdf4-python module.
Just type make in the *PyCordexer* directory to compile the fortran
code to be used by python

.. raw:: latex
    
        \begin{tcolorbox}
         cd pycordexer\\
         make        
        \end{tcolorbox}

Adapt the Makefile in the directory if the numpy python has been compiled
with a different compiler.

The scripts can be run from the *PyCordexer* directory afterwards.

.. raw:: latex

        \newpage

PyCordexer Scripts
------------------

The *PyCordexer* is split into two separate scripts:

1. **pycordexer.py**
   This script extracts variables from RegCM output files and creates a
   new file in the CORDEX netCDF format.
2. **means.py**
   This script computes day and monthly averages of CORDEX files at higher
   temporal resolution saving them in CORDEX netCDF format files.

The pycordexer.py script
--------------------

The **pycordexer.py** script reads a RegCM model output file and extracts
the variable creating a CORDEX file out of the details specified from the 
command line arguments.

The syntax to invoke the program is:

.. raw:: latex
    
        \begin{tcolorbox}
         pycordexer.py [-h] [-m MAIL] [-d DOMAIN] [-g GLOBAL_MODEL] [-e EXPERIMENT] \\
         [-b ENSEMBLE] [-n NOTES] [-o OUTPUT_DIR] [-c] datafile var1,var2,var3,...
        \end{tcolorbox}

The parameter *var1,var2,var3,...* is a list of CORDEX variables.
The *datafile* is a RegCM file which has the variables specified by *var1,var2,var3,...*
inside.
If var1,var2,var3,... is "ALL" (without quotes), the script will try to save all the
values that are saved inside the RegCM file.

Some variables can be extracted from different kind of files: for example, "tas" variable
can be extracted both from SRF and STS files. To allow users to convert all files
generated by RegCM without converting the same varibles multiple times, the ALL flag is
configured to avoid repetitions. Therefore, using ALL on a STS file will not save the
"tas" variable that is instead saved from the SRF files.

If you want to extract the tas variable from a STS file, you must not use the ALL flag and,
instead, submit a complete list of variables. 

List of Implemented Variables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The variable which can be extracted from the RegCM file are:

.. raw:: latex

        \begin{center}

+------------+------------+-----------------------------------------------+
| variable   | RegCM file | Description                                   |
+------------+------------+-----------------------------------------------+
| tas        | SRF,STS    | Near-Surface Air Temperature                  |
+------------+------------+-----------------------------------------------+
| pr         | SRF,STS    | Precipitation                                 |
+------------+------------+-----------------------------------------------+
| prc        | SRF        | Convective Precipitation                      |
+------------+------------+-----------------------------------------------+
| huss       | SRF        | Near-Surface Specific Humidity                |
+------------+------------+-----------------------------------------------+
| hurs       | SRF        | Near-Surface Relative Humidity                |
+------------+------------+-----------------------------------------------+
| evspsbl    | SRF        | Evaporation                                   |
+------------+------------+-----------------------------------------------+
| mrros      | SRF        | Surface Runoff                                |
+------------+------------+-----------------------------------------------+
| ps         | SRF        | Surface Air Pressure                          |
+------------+------------+-----------------------------------------------+
| psl        | ATM        | Sea Level Pressure                            |
+------------+------------+-----------------------------------------------+
| tasmax     | STS        | Daily Maximum Near-Surface Air Temperature    |
+------------+------------+-----------------------------------------------+
| tasmin     | STS        | Daily Minimum Near-Surface Air Temperature    |
+------------+------------+-----------------------------------------------+
| sfcWindmax | STS        | Daily Maximum Near-Surface Wind Speed         |
+------------+------------+-----------------------------------------------+
| mrro       | SRF        | Total Runoff                                  |
+------------+------------+-----------------------------------------------+
| sfcWind    | SRF        | Near-Surface Wind Speed                       |
+------------+------------+-----------------------------------------------+
| ua850      | ATM,ATMp   | Eastward Wind (at 850 hPa)                    |
+------------+------------+-----------------------------------------------+
| va850      | ATM,ATMp   | Northward Wind (at 850 hPa)                   |
+------------+------------+-----------------------------------------------+
| ta850      | ATM,ATMp   | Air Temperature (at 850 hPa)                  |
+------------+------------+-----------------------------------------------+
| hus850     | ATM,ATMp   | Specific Humidity (at 850 hPa)                |
+------------+------------+-----------------------------------------------+
| ua500      | ATM,ATMp   | Eastward Wind (at 500 hPa)                    |
+------------+------------+-----------------------------------------------+
| va500      | ATM,ATMp   | Northward Wind (at 500 hPa)                   |
+------------+------------+-----------------------------------------------+
| ta500      | ATM,ATMp   | Air Temperature (at 500 hPa)                  |
+------------+------------+-----------------------------------------------+
| zg500      | ATM,ATMp   | Geopotential Height (at 500 hPa)              |
+------------+------------+-----------------------------------------------+
| ua200      | ATM,ATMp   | Eastward Wind (at 200 hPa)                    |
+------------+------------+-----------------------------------------------+
| va200      | ATM,ATMp   | Northward Wind (at 200 hPa)                   |
+------------+------------+-----------------------------------------------+
| ta200      | ATM,ATMp   | Air Temperature (at 200 hPa)                  |
+------------+------------+-----------------------------------------------+
| zg200      | ATM,ATMp   | Geopotential Height (at 200 hPa)              |
+------------+------------+-----------------------------------------------+

.. raw:: latex

        \end{center}

Using the ALL flag on a particular file type (for example, STS), this script
will extract only the variables that, in the previous table, have that file
type as the first one that appears in the "RegCM file" type.


Arguments
~~~~~~~~~

The first two arguments are required, while the others have basic defaults
which do not comply to CORDEX standard but allow the script to be used as
a generic post-processing tool for RegCM

.. raw:: latex

        \vfill
        \begin{center}
        
+--------------+-------------+-----------------------------------------------+
| Argument     | Default     | Meaning                                       |
+--------------+-------------+-----------------------------------------------+
| mail         | esp@ictp.it | E-Mail of the Person responsible of this run  |
+--------------+-------------+-----------------------------------------------+
| domain       | NONE        | CORDEX domain (EUR-44,AFR-44,etc)             |
+--------------+-------------+-----------------------------------------------+
| global_model | NONE        | CMIP5 driving model (MOHC-HadGEM2-ES,etc)     |
+--------------+-------------+-----------------------------------------------+
| experiment   | none        | CMIP5 experiment (historical,rcp85,etc)       |
+--------------+-------------+-----------------------------------------------+
| ensemble     | NN          | CMIP5 model experiment (r1i1p1,r2i1p1,etc)    |
+--------------+-------------+-----------------------------------------------+
| notes        | none        | Eventual notes to be added in the file        |
+--------------+-------------+-----------------------------------------------+
| corrflag     | True        | Apply a correction time to dates.             |
+--------------+-------------+-----------------------------------------------+

.. raw:: latex

        \end{center}
        
Usage
~~~~~

Example usage is the following. Suppose you have in a directory RegCM model
output file, and want to extract in CORDEX format the variable tas from SRF
file for the AFR-44 domain run on ECMWF ERA15 dataset:

.. raw:: latex
    
        \begin{tcolorbox}
          pycordexer.py /data/output/path/Africa\_SRF.2002030100.nc tas -m me@here\\
           -d AFR-44 -g ECMWF-ERAINT -e evaluation -b r1i1p1 -n 'Some text'
        \end{tcolorbox}

This will create in the current directory the file:

.. raw:: latex
    
        \begin{tcolorbox}
         tas\_AFR-44\_ECMWF-ERAINT\_evaluation\_r1i1p1\_ICTP-RegCM4-3\_v4\_3hr\_200203010300-200204010000.nc
        \end{tcolorbox}

with all the mandatory attributes and naming conventions required by CORDEX
experiment convention document.
 
If just the name of the file and the variable name are specified, the output
file name will be:

.. raw:: latex
    
        \begin{tcolorbox}
         tas\_NONE\_NONE\_none\_NN\_ICTP-RegCM4-3\_v4\_3hr\_200203010300-200204010000.nc
        \end{tcolorbox}


The means.py script
-------------------

The **means.py** script reads a CORDEX file created by the **cordex.py**
script and computes day or monthly average of the variable in the file as
instructed by command line argument, saving the result in a CORDEX
conforming netCDF file.

The syntax to invoke the program is:

.. raw:: latex
    
        \begin{tcolorbox}
          means.py datafile [mon/day]
        \end{tcolorbox}

The *datafile* is a file produced by cordex.py, the secund argument if not
specified defaults to *mon*, i.e. creates a monthly average file.

Usage
~~~~~

Example usage is the following. Suppose you have in a directory the file

.. raw:: latex
    
        \begin{tcolorbox}
         tas\_NONE\_NONE\_none\_NN\_ICTP-RegCM4-3\_v4\_3hr\_200203010300-200204010000.nc
        \end{tcolorbox}
        

and want to compute daily averages in a CORDEX conforming netCDF file.

.. raw:: latex
    
        \begin{tcolorbox}
          means.py tas\_NONE\_NONE\_none\_NN\_ICTP-RegCM4-3\_v4\_3hr\_200203010300-200204010000.nc day
        \end{tcolorbox}


This will create in the current directory the file:

.. raw:: latex
    
        \begin{tcolorbox}
         tas\_NONE\_NONE\_none\_NN\_ICTP-RegCM4-3\_v4\_day\_2002030112-2002033112.nc
        \end{tcolorbox}


which contains daily mean values with all the mandatory attributes and naming
conventions required by CORDEX experiment convention document.
 
If you want to compute monthly average, you can issue:

.. raw:: latex
    
        \begin{tcolorbox}
          means.py tas\_NONE\_NONE\_none\_NN\_ICTP-RegCM4-3\_v4\_day\_2002030112-2002033112.nc mon
        \end{tcolorbox}


and obtain:

.. raw:: latex
    
        \begin{tcolorbox}
         tas\_NONE\_NONE\_none\_NN\_ICTP-RegCM4-3\_v4\_mon\_20020301-20020331.nc
        \end{tcolorbox}
        

Contacts
--------

The *pycordexer* scripts are now kept in the *Scripts/Tools* directory
of the RegCM model code package, and are maintained by ICTP as part
of the RegCM codebase. Please address any problem/suggestion to the RegCNET
mailing list:

    https://lists.ictp.it/mailman/listinfo.cgi/regcnet
