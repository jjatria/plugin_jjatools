JJATools
========

This is a plugin for [Praat][praat] with some of the scripts that I have written that I find useful to have from time to time.

It includes some scripts for object conversion (eg. `Save as JSON...`, `Save as Audacity label...`) and some general object management scripts (eg. `Save selected objects as text...`, which has proven to be quite popular). There's also a couple of oddball scritps here and there (eg. `View each...`, `Filter and center selected sounds...`).

Some of them are object-specific, and those act only on the selected objects.

Others take a path as their argument and batch process the files in that directory. The latter ones can be identified because their names start with "Batch _verb_".

They all try to follow the usual conventions in `Praat` scripts:

1. Those that take arguments end in an ellipsis...
2. If they create new objects, those are selected at the end
3. If they don't, they don't modify the active selection
4. Temporary objects (and only temporary objects) are removed as they become unnecessary
5. Unless otherwise stated, they do not make any inline changes in the selected objects

These are the bare minimum I commit myself to. I will try to correct offending scripts as soon as I discover them.

Please see `setup.praat` for the full list of scripts made available and how to access them.

Scripts and procedures
----------------------

Files that have self-contained scripts have the `.praat` extension, while those that have procedures to be included into other scripts have the `.proc` extension. Some of these are included as helper scripts (eg. `checkDirectory.proc`), and you are welcome to use them in your own scripts if you want.

To do this you can use the `include` directive in `Praat`, but you'll need to have the full path to the procedure definition, or save the script somewhere where it can reach the definiton using a relative path. If your own scripts are in a plugin, then they should be able to use the procedures by running this line:

    include ../plugin_jjatools/some_procedure_name.proc

I don't recommend using full paths, since then your script will not be portable, and `include` does not allow variables in its argument.

Installation
-----------

If you are using GNU/Linux, and have `git` installed, you can run

    cd ~/.praat-dir
    git clone https://github.com/jjatria/plugin_jjatools.git

and you should be good to go!

If not, then you can use the general instructions below:

1. Download [the contents of the repo][zip] (this readme is not necessary) and extract into a folder called `plugin_jjatools` in your Praat preferences directory. The exact location of this depends on your operating system, so please [check the documentation][preferences].

2. Restart Praat.

[praat]: www.praat.org
[preferences]: http://www.fon.hum.uva.nl/praat/manual/preferences_directory.html
[zip]: https://github.com/jjatria/plugin_jjatools/archive/master.zip

