---
---
If you want to contribute a new stack, in the form of a BOM, follow these guidelines:

* It can be tricky to work out when to add a new stack, rather than extend an existing stack. We strongly encourage you to discuss your planned BOM on the [dev list](#{site.base_url}/forums/jdf-dev) before starting.
* Each BOM is a child module of the parent BOM module. Copy an existing module as a template. Remember to give it a unique, and descriptive name. You should follow the conventions defined by the existing BOMs when naming it. All BOMs live in the same repository.
* Most BOMs build on the base Java EE stack, and as such, import it. This is reflected in the name of the BOM "jboss-javaee6-with-XXX".
* The BOM should contain a `README.md` file, explaining:
   * What the stack described by the BOM includes 
   * An example of it's usage
   * Any notes about plugins included in the stack
* The BOM should be formatted using the JBoss AS profiles found at <https://github.com/jboss/ide-configs/tree/master/ide-configs>
* When your BOM is ready for review, send a pull request.

