package rwt.gmodz;

import modlib.mod.Greeter;


public class Cmd {
  public static void main(String[] args) {
     new Cmd().go();
  }

  public void go() { 
     new Greeter().shout("Richard-from-Java");

     // compare this with Cmd.groovy in the grvapp project... 
     // java respects the encapsulation boundary.  This line
     // won't compile
     // new modlib.mod.internal.SecretGreeter().greet("Invader!");
  }
}

