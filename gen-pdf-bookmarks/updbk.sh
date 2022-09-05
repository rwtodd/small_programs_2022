if ! [ -f "$1" ] ; then
  echo "Usage: updbk.sh pdf-file" 1>&2 
  echo "  (have a file called 'bm' with the bookmarks in it)" 1>&2 
  exit 1
fi

java.exe -jar ../pdftk-all.jar $1 dump_data output report.txt
( sed -e '/^NumberOfPages/q' report.txt ; gen-bmark < bm ) > report2.txt
java.exe -jar ../pdftk-all.jar $1 update_info report2.txt output out.pdf compress
