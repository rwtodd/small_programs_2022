package rwt.gmodz;

class GMz {
  def shout(String x) { println("i said... $x!!") }
}

class Cmd {
  static void main(String[] args) {
     new GMz().shout('ice cream')
     System.in.read()
  }
}

