Hacking on the jdf site
=======================

TODO

Staging changes
---------------

1. Contact the project lead, and ask for access to the jdf account on OpenShift. Add your ssh key.
2. Build the site

    awestruct --force -Pstaging
3. Clone the site. Get the latest clone url from the OpenShift console (`site app`), and run.
4. Copy the generated site to the OpenShift `php` directory. For example:

    cp -r _site/* ~/development/jdf-site/php/
5. Deploy

    git add php && git commit -m"deploy" && git push
