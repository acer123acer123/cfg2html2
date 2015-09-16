This is a fork (so to speak) of the original cfg2html tool that most people are aware of.
You can find their site at http://www.cfg2html.com

<h2>Background</h2>
cfg2html is a script that collects information about a server and presents produces an HTML page as output. Collection commands (like df, lslv, etc) are all run inline in the script and so the script becomes very OS dependent. Also, modification of the collection commands requires modification of the main script. In a production environment I like to keep these types of changes to a minimum. Also in a production environment, I like to keep my scripts consistent across all like servers. Realization of these goals is hard with this script.

<h2>My version</h2>
Several years ago I created a new, modified script and called it cfg2html2. It takes a completely different approach to the collection of information on UXIX servers. The core of the script lends itself heavily from the original one but instead of running the collection commands inline, the main script calls “plugin scripts.” These scripts are stored in subdirectories with the os as the name. This allows the exact same script to run on all different flavors of UNIX.

When the script executes, it determines what OS it is running on based on the output of the uname command. It then traverses into the $OS directory and runs all of those scripts. An admin simply has to add an additional script to the directory to expand the information that cfg2html2 collects.

Another script collects all of these HTML files from all of the different hosts and stores them in a central location where they can be viewed from a web browser.
