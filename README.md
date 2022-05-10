Nim Notes
=========

This is the respository to generate the wiki pages.

The wiki consists in the compilation of all the code files,
extra markdowns and its commentaries.


Access the wiki
---------------

Go to the [Wiki](//github.com/thadeudepaula/nim-notes/wiki)


How it works?
-------------

* Each folder under `src` folder should comprehend a subject.
* Each subject becomes a page containing the extracted text
  from all markdown files, all source codes and comments
  found under the subject folder.
* The wiki compilation is done by the makewiki.nim in the
  `wiki` folder
* The `wiki` folder is the git submodule for the wiki repository.

To regenerate the Wiki, enter in the root folder of project
and run:

    nim c -r makewiki.nim src wiki

That means that it will find any markdown and code under src 
folder and write de documentation on wiki folder.

