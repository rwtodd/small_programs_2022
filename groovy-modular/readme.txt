Modular Groovy App
------------------

This just a test of JPMS modules and Groovy.  It has a modular
`modlib` project, with groovy code behind a module-info.java.  It
has a grvapp groovy application that uses the module, and a
javapp java application which uses the module.

It kind-of works, but since you have to `open` all packages to
groovy, you break all the encapsulation that modules provide.  
See for example in grvapp's Cmd.groovy, I can instantiate an object
of the modlib's internal class.  Meanwhile, the equivalent code in
javapp's Cmd.java won't even compile the line, since java respects
the encapsulation of the internal package.

So I can at least say I can make JPMS-modular groovy libraries that
are encapsulated from the Java-side.  It would be better for the
groovy compiler to learn to respect the module exports when possible.


