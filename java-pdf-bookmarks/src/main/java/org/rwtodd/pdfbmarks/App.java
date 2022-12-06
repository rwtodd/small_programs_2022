/*
 * This Java source file was generated by the Gradle 'init' task.
 */
package org.rwtodd.pdfbmarks;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.io.PrintWriter;
import java.io.Reader;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.rwtodd.pdfbmarks.PageLabelParser.PageLabel;

abstract class PageLabelParser {

	private static final Pattern nameDecl = Pattern.compile("\\s*name\\s*(\\d+)\\s*:\\s*(.*)", Pattern.CASE_INSENSITIVE);
	private static final Pattern numDecl = Pattern.compile("\\s*page\\s*(\\d+)\\s*=\\s*book\\s*(\\d+)([rR]?)",
			Pattern.CASE_INSENSITIVE);

	static PageLabel parseLine(String line) {
		Matcher m = nameDecl.matcher(line);
		if (m.lookingAt()) {
			return new NamedPage(Integer.valueOf(m.group(1)), m.group(2));
		}
		m = numDecl.matcher(line);
		if (m.lookingAt()) {
			var style = switch (m.group(3)) {
			case "r" -> "LowercaseRomanNumerals";
			case "R" -> "UppercaseRomanNumerals";
			default -> "DecimalArabicNumerals";
			};
			return new NumberedPage(Integer.valueOf(m.group(1)), Integer.valueOf(m.group(2)), style);
		}
		return null;
	}

	interface PageLabel {
		void output(PrintWriter pw) throws IOException;
		int bookToPdfOffset();
	}

	record NamedPage(int pdfPage, String name) implements PageLabel {
		@Override
		public void output(PrintWriter pw) throws IOException {
			pw.printf("PageLabelBegin\nPageLabelNewIndex: %d\nPageLabelStart: 1\nPageLabelPrefix: %s\nPageLabelNumStyle: NoNumber\n",
					pdfPage, name);
		}

		@Override
		public int bookToPdfOffset() {
			return 0;
		}

	}

	record NumberedPage(int pdfPage, int bookPage, String numericStyle) implements PageLabel {
		@Override
		public void output(PrintWriter pw) throws IOException {
			pw.printf("PageLabelBegin\nPageLabelNewIndex: %d\nPageLabelStart: %d\nPageLabelNumStyle: %s\n",
					pdfPage, bookPage, numericStyle);
		}

		@Override
		public int bookToPdfOffset() {
			return pdfPage - bookPage;
		}
	}

}

public class App {
	static final Pattern bm = Pattern.compile("\\s*(\\d+)\\s*(.*)");
	
	static String removeComments(String l) {
		final int hashChar = l.indexOf('#');
		if(hashChar >= 0)
			l = l.substring(0, hashChar);
		return l.isBlank() ? null : l.stripTrailing();
	}
	
	static void runInput(Reader input, PrintWriter output) throws IOException {
		final var lines = new LineNumberReader(input);
		final var labels = new java.util.ArrayList<PageLabel>();
		var offset = 0;
		for(var line = lines.readLine(); line != null; line = lines.readLine()) {
			line = removeComments(line);
			if(line == null) continue; // it must have been blank or a comment!
			
			final var label = PageLabelParser.parseLine(line);
			if(label != null) {
				labels.add(label);
				offset = label.bookToPdfOffset();
				continue;
			} 
			
			// it wasn't a label, so it better be a bookmark
			final var m = bm.matcher(line);
			if(m.lookingAt()) {
				output.printf("BookmarkBegin\nBookmarkTitle: %s\nBookmarkLevel: %d\nBookmarkPageNumber: %d\n", 
						m.group(2), m.start(1)+1, Integer.valueOf(m.group(1))+offset);
				continue;
			}
							
			// uh oh...
			throw new IOException(String.format("Bad input on line %d!", lines.getLineNumber()));
		}
		for(var l: labels) { l.output(output); }
	}
	
	public static void main(String[] args) {
		try {
			final var conIn = new InputStreamReader(System.in);
			final var conOut = new PrintWriter(System.out);
			runInput(conIn,conOut);
			conOut.flush();
		} catch (IOException e) {
			System.err.println(e.getMessage());
			System.exit(1);
		}
	}
}