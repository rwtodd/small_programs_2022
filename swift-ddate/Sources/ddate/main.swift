import Foundation

// some constants, up here at the top of our lovely program
let cal = Calendar(identifier: .gregorian)
let xday = DateComponents(calendar: cal, year: 8661, month: 7, day: 5).date!
let todayFmt = "Today is %{%A, the %e day of %B%} in the YOLD %Y%N%nCelebrate %H"
let shortFmt = "%{%A, %B %d%}, %Y YOLD"
let tibsName = "St. Tib's Day"
let shortTibsName = "Tib's"
let seasonNames =  ["Chaos", "Chs", "Discord", "Dsc", "Confusion", "Cfn",
                    "Bureaucracy", "Bcy", "The Aftermath", "Afm"]
let dayNames =  ["Sweetmorn", "SM", "Boomtime", "BT", "Pungenday", "PD",
                 "Prickle-Prickle", "PP", "Setting Orange", "SO"]
let holyDays5 = ["Mungday", "Mojoday", "Syaday", "Zaraday", "Maladay"]
let holyDays50 =  ["Chaoflux", "Discoflux", "Confuflux", "Bureflux", "Afflux"]
let exclamations = ["Hail Eris!", "All Hail Discordia!", "Kallisti!", "Fnord.", "Or not.",
                    "Wibble.", "Pzat!", "P'tang!", "Frink!", "Slack!", "Praise \"Bob\"!",
                    "Or kill me.", "Grudnuk demand sustenance!", "Keep the Lasagna flying!",
                    "You are what you see.", "Or is it?", "This statement is false.",
                    "Lies and slander, sire!", "Hee hee hee!", "Hail Eris, Hack Swift!"]

// now, a couple utility functions before the main logic starts...
func errExit(_ msg: String) -> Never { 
  fputs("""
        Error: \(msg)!
        
        Usage: ddate [fmt] [yyyy mm dd]\n
        """, stderr)
  exit(1)
}

func parseDate(startFrom argno: Int) -> Date {
   let year = Int(CommandLine.arguments[argno]) 
   let month = Int(CommandLine.arguments[argno+1]) 
   let day = Int(CommandLine.arguments[argno+2]) 
   if year == nil || month == nil || day == nil { errExit("Bad date given!") }
   return DateComponents(calendar: cal, year: year, month: month, day: day).date!
}

func ordinal(_ n: Int) -> String {
  var formatted = String(n)
  let digit = (n/10 == 1) ? 4 : n%10 
  switch digit {
    case 1: formatted.append("st")
    case 2: formatted.append("nd")
    case 3: formatted.append("rd")
    default: formatted.append("th")
  }
  return formatted
}

// main logic...
// figure out the day and format from the cmdline options provided
var today : Date // the day we will present to the user
var fmt : String // the format string we will use
switch CommandLine.argc {
case 0: fallthrough
case 1: /* no args   */ fmt = todayFmt;                 today = Date()
case 2: /* fmt       */ fmt = CommandLine.arguments[1]; today = Date()
case 4: /* y m d     */ fmt = shortFmt;                 today = parseDate(startFrom: 1)
case 5: /* fmt y m d */ fmt = CommandLine.arguments[1]; today = parseDate(startFrom: 2)
default: errExit("Wrong number of arguments!")
}
today = cal.startOfDay(for: today)

// Start computing basic properties of the date...
let isLeapYear = cal.range(of: .day, in: .year, for: today)!.count == 366
let dayOfYear = cal.ordinality(of: .day , in: .year, for: today)!
let adjustedDay = dayOfYear - ((isLeapYear && cal.component(.month, from: today) > 2) ? 2 : 1)
let isTibs = isLeapYear && dayOfYear == (31+29)
let season = adjustedDay / 73
let seasonDay = adjustedDay % 73 + 1
let holyDay = (seasonDay == 5) ? holyDays5[season] : ((seasonDay == 50) ? holyDays50[season] : "")

// Loop over 'fmt' and produce the output
var result = ""; result.reserveCapacity(256) // this is where the output will go
var idx = fmt.startIndex
while idx != fmt.endIndex {
  if fmt[idx] != "%" {
    result.append(fmt[idx])
  } else {
    fmt.formIndex(after: &idx)
    // if % was the last character, treat it like %%
    if idx == fmt.endIndex { fmt.formIndex(before: &idx) }

    // parse the formatting char
    switch fmt[idx] {
    case "A": result.append(isTibs ? tibsName : dayNames[2 * (adjustedDay % 5)])
    case "a": result.append(isTibs ? shortTibsName : dayNames[2 * (adjustedDay % 5) + 1])
    case "B": result.append(isTibs ? tibsName : seasonNames[2 * season])
    case "b": result.append(isTibs ? shortTibsName : seasonNames[2 * season + 1])
    case "d": result.append(isTibs ? shortTibsName : String(seasonDay))
    case "e": result.append(isTibs ? "Tibsith" : ordinal(seasonDay))
    case "H": result.append(holyDay)
    case "n": result.append("\n")
    case "N": if holyDay.isEmpty { idx = fmt.index(before: fmt.endIndex) }
    case "t": result.append("\t")
    case "X": let nf = NumberFormatter(); nf.numberStyle = .decimal
              let days = cal.dateComponents([.day],from: today, to: xday).day ?? 0
              result.append(nf.string(from: NSNumber(value: days))!)
    case "Y": result.append(String(cal.component(.year, from: today) + 1166))
    case ".": result.append(exclamations.randomElement()!)
    case "{": if isTibs {
                result.append(tibsName)
                idx = fmt.index(before: fmt.range(of: "%}")?.upperBound ?? fmt.endIndex)
              }
    case "}": break
    default: result.append(fmt[idx])
    }
  }
  fmt.formIndex(after: &idx)
}
print(result)
