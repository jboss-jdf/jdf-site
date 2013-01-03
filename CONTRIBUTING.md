Hacking on the JDF site
=======================

The JDF site is built using [awestruct](http://awestruct.org/), and requires a number of gems and eggs, as well as AsciiDoc (8.6.x).

To setup the environment you need to follow these steps. *Certify to use the correct versions*.

Setup your environment
----------------------

1. Install Ruby *1.9.X*

    For RHEL you can use this [spec](https://github.com/lnxchk/ruby-1.9.3-rpm)

2. Install Ruby GEMs

        gem install awestruct hpricot nokogiri json git vpim rest-client pygments.rb 

3. Install a Javascript GEM Runtime. 

    - A list of available Runtimes can be found here: <https://github.com/sstephenson/execjs>

            gem install *a-javascript-runtime*

4. Install ASCIIDOC *8.6.x*

    - Version `8.6.x` can be found [here](http://www.methods.co.nz/asciidoc/INSTALL.html)

5. Install Python Eggs

    - pygments
    - For Linux:

            sudo yum install python-pygments

6. JDF site uses Github API to obtain some data. Due to Github Rate Limiting, it's required that you create a file `$HOME/.github-auth` containing `username:password` on one line.

Running the site locally
------------------------

Having got your environment correctly set up, on jdf-site root, run:

      awestruct -d

to run awestruct in development mode, and serve the site at <http://localhost:4242>.

Running the site on Sandbox
---------------------------

1. Contact the project lead, and ask for access to the jdf account on OpenShift. Add your ssh key.

2. Run `./publish.sh -d`

3. The site will be available at <http://site-jdf.rhcloud.com>, which we use as sandbox, for developing new features and sections for the site.


Staging changes
---------------

1. Contact the project lead, and ask for access to `filemgmt.jboss.org`. 

2. Run `./publish.sh -s`

3. The site will be available at <http://jboss.org/jdf/stage>, which use for staging changes to the site. Stage is normally reserved for verifying minor updates to the site, or for final verification before a major update. 


Publishing on Production
------------------------

1. Make sure you have `Sendmail` installed and running. Sendmail will be used to send mail notifications.

 On Linux you can install sendmail running: `sudo yum install sendmail`.

2. Contact the project lead, and ask for access to `filemgmt.jboss.org`.

3. Update the site version on `_config/site.yml' - 

4. Run `./publish.sh -p`

5. The site will be available at <http://jboss.org/jdf>, the production site.

_NOTE_: You can also run: 

    ./release.sh -s <old snapshot version> -r <release version>

This will update the version number (step 3), commit and tag and publish the site to <http://jboss.org/jdf> (step 4). Then it will reset the version number back to the snapshot version number.
