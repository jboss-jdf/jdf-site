---
---

* Each sample project should have a unique name, allowing easy identification by users and developers.
* The quickstart should follow these packaging requirements:
  1. The package must be org.jboss.as.quickstarts.<quickstart-name>.
  2. The quickstart project or folder name should match the quickstart name.
  3. The project must follow the structure used by existing quickstarts such as `numberguess`. A good starting point would be to copy the numberguess project.
* A sample project should have a simple build that the user can quickly understand. If using maven it should:
  1. Not inherit from another POM
  2. Import the various BOMs, either directly from a project, or from JBoss BOMs, to determine version numbers. You should aim to have no dependencies declared directly. If you do, work with the jdf team to get them added to a BOM.
  3. Use the JBoss AS Maven Plugin to deploy the example
* The sample project should be importable into JBoss Developer Studio/JBoss Tools and be deployable from there
* The sample project should contain a `README.md` file using the `template/README.md` file as a guideline. It should explain:
   * What the sample project demonstrates
   * How to build and deploy it
   * How to access it, and what the user should expect to see
   * How to to run the tests
   * How to deploy it to OpenShift, if necessary
   * Any special requirements (e.g. different server profile, changes to default server config)
* The sample project should be formatted using the JBoss AS profiles found at <http://github.com/jboss/ide-config/tree/master/>

AsciiDoc
~~~~~~~~

* When writing asciidoc, and using delimited blocks, we recommend making the block 72 characters wide
* Due to a (bad) interaction between the source code highlighter, and callouts, it is necessary to use comments in some types of source (e.g. Java). The comments can be removed by asciidoc when processed, by adding these snippets to the `[macros]` section of your system's `asciidoc.conf`:

    [\\]?// &lt;(?P<index>\d+)&gt;=callout

