-- operate on the selected .pages files 

tell application "Finder" to set selected_items to selection

repeat with this_item in selected_items
	tell application "Pages"
		-- activate
		open this_item
		delay 1.5
		set dn to name of 1st document
	end tell
	
	if dn contains ".pages" then
		set dn to text 1 thru -7 of dn as text
	end if
	
	if (this_item as text) contains ".docx" then -- save as pages if we started with WORD docx
		set pgfile to (POSIX path of (path to home folder) & "/Downloads/b/" & dn & ".pages")
		tell application "Pages" to save the 1st document in POSIX file pgfile
	end if
	
	set outfl to (POSIX path of (path to home folder) & "/Documents/" & dn & ".pdf")
	
	tell application "Pages"
		export document 1 to POSIX file outfl as PDF with properties {image quality:Best, include comments:false, include annotations:false}
		close the 1st document
	end tell
end repeat
