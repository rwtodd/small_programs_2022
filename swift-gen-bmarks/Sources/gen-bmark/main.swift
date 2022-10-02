import Foundation

let markRx = #/^ *(?<page>\d+)(?<ptype>p?) +(?<name>.*?) *$/#
let namedRx = #/(?i)^ *name (?<page>\d+): *(?<name>.*)$/#
let numberedRx = #/(?i)^ *page *(?<pdf>\d+) *= *book *(?<book>\d+)(?<style>[r]?) *$/#

var labels = ""  // write labels to this buffer to save until the end
var bookToPdfOffset = 0    // track the current offset from book pages to PDF
var lineNumber = 0  // track the current line number

while var ln = readLine() {
   lineNumber += 1

   // First, trim out any #-comments
   if let pound = ln.firstIndex(of: "#") {
     ln = String(ln.prefix(upTo: pound))
   }

   if let match = ln.firstMatch(of: namedRx) {
     // NAMED PAGES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     bookToPdfOffset = 0
     print("""
           PageLabelBegin
           PageLabelNewIndex: \(match.page)
           PageLabelStart: 1
           PageLabelPrefix: \(match.name)
           PageLabelNumStyle: NoNumber
           """, to: &labels)
   } else if let match = ln.firstMatch(of: numberedRx) {
       // NUMBERED PAGES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
       let pdfPage = Int(match.pdf)!
       let bookPage = Int(match.book)!
       var style : String
       switch(match.style) {
          case "r": style="LowercaseRomanNumerals"
          case "R": style="UppercaseRomanNumerals"
          default: style="DecimalArabicNumerals"
       }
       bookToPdfOffset = pdfPage - bookPage
       print("""
             PageLabelBegin
             PageLabelNewIndex: \(pdfPage)
             PageLabelStart: \(bookPage)
             PageLabelNumStyle: \(style)
             """, to: &labels)
   } else if let match = ln.firstMatch(of: markRx) {
       // BOOKMARKED PAGES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
       let ptype = match.ptype.count
       let pdfpage = Int(match.page)! + (1 - ptype)*bookToPdfOffset
       let indent = 1 + match.page.startIndex.utf16Offset(in: ln)
       print("""
             BookmarkBegin
             BookmarkTitle: \(match.name)
             BookmarkLevel: \(indent)
             BookmarkPageNumber: \(pdfpage)
             """)
   } else if !ln.allSatisfy({ $0.isWhitespace }) {
       // IF IT'S NOT BLANK, IT'S AN ERROR ~~~~~~~~~~~~~~~~~~~~~~~
       fputs("Bad input on line \(lineNumber)!\n", stderr)
       exit(1)
   }
}
print(labels)

