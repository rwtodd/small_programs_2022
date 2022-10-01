package modlib.mod;

class Greeter {
  void shout(String x) { 
     // use an encapsulated class, and make sure
     // it works from inside the module
     new modlib.mod.internal.SecretGreeter().greet(x)
  }
}

