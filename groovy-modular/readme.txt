So, it basically works, but you have to export all packages that have
Groovy code because Groovy appears to generate code into an unnamed
module.  So, you can't use modularity for encapsulation at present.

... unless I have missed something, anyway...

JPMS modularity has proven to be a real pain to work with.  Java
tooling (like gradle, IDEs) is only just now starting to get usable
in 2022.  Good luck with clojure/groovy/scala/etc.!

I can only hope someone will read this file in 2025 and assume
I'm dumb because JPMS works so well with everyone.


