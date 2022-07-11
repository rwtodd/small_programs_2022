Getting gradle tasks written so that I can easily create a groovy shell with a
classpath for my project.  It seems to work, so far.

Note that, since I use powershell, the quoting on the classpath argument has to
be doubled-up in a specific way: 

    -cp '"path1;path2"'  

... or it doesn't work.

