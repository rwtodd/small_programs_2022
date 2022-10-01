import Foundation
import _StringProcessing

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

  private static let named = try! Regex(#"(?i)^ *name (\d+): *(.*)$"#)
  private static let numbered = try! Regex(#"(?i)^ *page *(\d+) *= *book *(\d+)([r]?) *$"#)

  static func parse(_ s: String) -> PageLabel? {
     if let match = s.firstMatch(of: named) {
         return NamedLabel(
           pdfPage: Int(match[1].substring!)!,
           pageName: String(match[2].substring!))
     }
     if let match = s.firstMatch(of: numbered) {
         var style : String
         switch(match[3].substring!) {
          case "r": style="LowercaseRomanNumerals"
          case "R": style="UppercaseRomanNumerals"
          default: style="DecimalArabicNumerals"
         }
         return NumberedLabel(
           pdfPage: Int(match[1].substring!)!,
           bookPage: Int(match[2].substring!)!,
           numStyle: style)
     } 
     return nil 
  }
}

@main
public struct hw {
    public static func main() {
        let mark = try! Regex(#"^ *(\d+)(p?) +(.*)$"#)
        var labels : [PageLabel] = []
        var offset = 0
        var line_number = 0
        while let ln = readLine() {
          line_number += 1
          if let label = page_label_parser.parse(ln) {
             labels.append(label)
             offset = label.bookToPdfPage
          } else if let match = ln.firstMatch(of: mark) {
             let m1 = match[1].substring!
             let indent = 1 + m1.startIndex.utf16Offset(in: ln)
             let ptype = match[2].substring!.count
             let pdfpage = Int(m1)! + (1 - ptype)*offset
             let name = match[3].substring!
             print("BookmarkBegin\nBookmarkTitle: \(name)\nBookmarkLevel: \(indent)\nBookmarkPageNumber: \(pdfpage)")
          } else {
             fputs("Bad input on line \(line_number)!\n", stderr)
             exit(1)
          }
        }
        labels.forEach { print($0.controlText()) }
    }
}
