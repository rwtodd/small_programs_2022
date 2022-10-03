import Foundation

// some constants, up here at the top of our lovely program
let cal = Calendar(identifier: .gregorian)
let xday = DateComponents(calendar: cal, year: 8661, month: 7, day: 5).date!
let todayFmt = "Today is %{%A, the %e day of %B%} in the YOLD %Y%N%nCelebrate %H"
let shortFmt = "%{%A, %B %d%}, %Y YOLD"
let tibs = "St. Tib's Day"
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
func errExit(_ msg: String) -> Never { fputs("Error: \(msg)!\n", stderr); exit(1) }

func parseDate(startFrom argno: Int) -> Date {
   let year = Int(CommandLine.arguments[argno]) 
   let month = Int(CommandLine.arguments[argno+1]) 
   let day = Int(CommandLine.arguments[argno+2]) 
   if year == nil || month == nil || day == nil { errExit("Bad date given!") }
   return DateComponents(calendar: cal, year: year, month: month, day: day).date!
}

// main logic...
// figure out the day and format from the cmdline options provided
var today : Date // the day we will present to the user
var fmt : String // the format string we will use
switch CommandLine.argc {
case 0: fallthrough
case 1: /* no args */   fmt = todayFmt;                 today = Date()
case 2: /* fmt */       fmt = CommandLine.arguments[1]; today = Date()
case 4: /* y m d */     fmt = shortFmt;                 today = parseDate(startFrom: 1)
case 5: /* fmt y m d */ fmt = CommandLine.arguments[1]; today = parseDate(startFrom: 2)
default: errExit("Wrong number of arguments!")
}
today = cal.startOfDay(for: today)

// Start computing basic properties of the date...
let isLeapYear = cal.range(of: .day, in: .year, for: today)!.count == 366
let dayOfYear = cal.ordinality(of: .day , in: .year, for: today)!
let adjustedDay = dayOfYear - ((isLeapYear && cal.component(.month, from: today) > 2) ? 2 : 1)
let isTibs = isLeapYear && dayOfYear == (31+29)

// lazily determine when X-Day is, and format it nicely
var daysTilXDay : String {
  let nf = NumberFormatter(); nf.numberStyle = .decimal
  let days = cal.dateComponents([.day],from: today, to: xday).day ?? 0
  return nf.string(from: NSNumber(value: days))!
}

// TODO... print according to the actual format instead of this testing mess...
print("\(today) is the day!")
if(isLeapYear) { print("it's a leap year!") }
if(isTibs) { print("It's TIBS!") }
print("Season is \(seasonNames[2*(adjustedDay / 73)])") // TODO account for tibs
print("Day of season is \(adjustedDay % 73 + 1)") // TODO account for tibs
print("Day is \(dayNames[2*(adjustedDay % 5)])") // TODO account for tibs
print("\(daysTilXDay) days until X-Day! F'nord!")
print("YOLD is \(cal.component(.year, from: today) + 1166)")

