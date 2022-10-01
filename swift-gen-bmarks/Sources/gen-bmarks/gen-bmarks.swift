import Foundation

protocol PageLabel {
    var bookToPdfPage: Int { get }
    func controlText() -> String
}

struct page_label_parser {

  private struct NamedLabel : PageLabel {
    let pdfPage: Int
    let pageName: String
    let bookToPdfPage = 0
    func controlText() -> String { 
      "PageLabelBegin\nPageLabelNewIndex: \(pdfPage)\nPageLabelStart: 1\nPageLabelPrefix: \(pageName)\nPageLabelNumStyle: NoNumber"
    }
  }

  private struct NumberedLabel : PageLabel {
    let pdfPage: Int
    let bookPage: Int
    let numStyle: String
    var bookToPdfPage : Int { pdfPage - bookPage }
    func controlText() -> String {
      "PageLabelBegin\nPageLabelNewIndex: \(pdfPage)\nPageLabelStart: \(bookPage)\nPageLabelNumStyle: \(numStyle)"
    }
  }

  //private static let named = try! Regex(#"(?i)^ *name (\d+): *(.*)$"#)
  private static let named = #/(?i)^ *name (?<page>\d+): *(?<name>.*)$/#
  private static let numbered = #/(?i)^ *page *(?<pdf>\d+) *= *book *(?<book>\d+)(?<style>[r]?) *$/#

  static func parse(_ s: String) -> PageLabel? {
     if let match = s.firstMatch(of: named) {
         return NamedLabel(pdfPage: Int(match.page)!, pageName: String(match.name))
     }
     if let match = s.firstMatch(of: numbered) {
         var style : String
         switch(match.style) {
          case "r": style="LowercaseRomanNumerals"
          case "R": style="UppercaseRomanNumerals"
          default: style="DecimalArabicNumerals"
         }
         return NumberedLabel(pdfPage: Int(match.pdf)!, bookPage: Int(match.book)!, numStyle: style)
     } 
     return nil 
  }
}

@main
public struct hw {
    public static func main() {
        let mark = #/^ *(?<page>\d+)(?<ptype>p?) +(?<name>.*?) *$/#
        var labels : [PageLabel] = []
        var offset = 0
        var line_number = 0
        while let ln = readLine() {
          line_number += 1
          if let label = page_label_parser.parse(ln) {
             labels.append(label)
             offset = label.bookToPdfPage
          } else if let match = ln.firstMatch(of: mark) {
             let indent = 1 + match.page.startIndex.utf16Offset(in: ln)
             let ptype = match.ptype.count
             let pdfpage = Int(match.page)! + (1 - ptype)*offset
             print("BookmarkBegin\nBookmarkTitle: \(match.name)\nBookmarkLevel: \(indent)\nBookmarkPageNumber: \(pdfpage)")
          } else {
             fputs("Bad input on line \(line_number)!\n", stderr)
             exit(1)
          }
        }
        labels.forEach { print($0.controlText()) }
    }
}
