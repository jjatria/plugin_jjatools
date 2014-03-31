JJATools
========

This is a plugin for [Praat][1] with some of the scripts that I have written that I find useful to have from time to time.

It includes some scripts for object conversion (eg. `TextGrid to JSON`, `TextGrid to Audacity labels`) and some general object management scripts (eg. `Save selected objects...`, which has proven to be quite popular), as well as the oddball here and there (`View each...`).

Some of them apply to the selected objects, and some take a path as an argument and work on the files in the directory. The ones that take a path as their argument are placed in the `JJATools` submenu on the `Praat` menu. The rest are in their respective context-sensitive menus.

Please see `setup.praat` for the full list of available scripts and how to access them.

Instalation
-----------

1. Download the contents of the repo (this readme is not necessary) and extract into a folder called `plugin_jjatools` in your Praat preferences directory. The exact location of this depends on your operating system, so please [check the documentation][2].

2. Restart Praat.

[1]: www.praat.org
[2]: http://www.fon.hum.uva.nl/praat/manual/preferences_directory.html
