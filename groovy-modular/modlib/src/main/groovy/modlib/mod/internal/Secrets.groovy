package modlib.mod.internal;

// this package is not exported, only open... so hopefully
// we can't get to it from another module...
class SecretGreeter {
   void greet(String x) { println "Well hello there, $x!" }
}

