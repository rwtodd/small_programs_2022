module modlib_groovy {
  requires org.apache.groovy;
  exports modlib.mod; // but *not* modlib.mod.internal

  // open the packages so groovy can reflect on them
  opens modlib.mod;
  opens modlib.mod.internal;
}
