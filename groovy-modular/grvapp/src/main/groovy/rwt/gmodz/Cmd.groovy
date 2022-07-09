package rwt.gmodz;

import modlib.mod.Greeter;


class Cmd {
  static void main(String[] args) {
     new Cmd().go();
  }

  def go() { 
     new Greeter().shout("Richard");

     // I expected this to compile, since groovyc doesn't understand
     // module restrictions.  But, I also expected that the JVM would
     // give some kind of security error at runtime.  But, since even
     // the encapsulated packages must be "opened", it looks like
     // groovy can reach right in and run whatever it wants.
     new modlib.mod.internal.SecretGreeter().greet("Invader!")
  }
}

