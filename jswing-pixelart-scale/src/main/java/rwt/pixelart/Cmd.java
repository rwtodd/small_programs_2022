package rwt.pixelart;

import java.awt.*;
import java.awt.image.BufferedImage;
import java.util.Random;
import javax.swing.*;


// compare to sibling project jfx-pixelart-scale ... and you'll see how relatively easy
// it is to get a pixel-perfect scaled image in swing

public class Cmd extends JFrame {

	private static final long serialVersionUID = -7835865311308198512L;

	private JComponent pixart;
	
	private final BufferedImage bi;
	private final Object[] palette;
	private int paletteOffs; // offset into the palette

	private static Object[] setUpEGAPalette(BufferedImage im) {

		//colormodel.getDataElements() takes an ARGB value and converts it to what the raster wants...
		// ... and raster.setDataElements takes the colormodel output and sets the value in the raster
		final var cm = im.getColorModel();
		final var palette = new Object[16];
		palette[0] = cm.getDataElements(0xff_00_00_00, null); // null means allocate a fresh one
		palette[1] = cm.getDataElements(0xff_00_00_aa, null);
		palette[2] = cm.getDataElements(0xff_00_aa_00, null);
		palette[3] = cm.getDataElements(0xff_00_aa_aa, null);
		palette[4] = cm.getDataElements(0xff_aa_00_00, null);
		palette[5] = cm.getDataElements(0xff_aa_00_aa, null);
		palette[6] = cm.getDataElements(0xff_aa_55_00, null);
		palette[7] = cm.getDataElements(0xff_aa_aa_aa, null);
		palette[8] = cm.getDataElements(0xff_55_55_55, null);
		palette[9] = cm.getDataElements(0xff_55_55_ff, null);
		palette[10] = cm.getDataElements(0xff_55_ff_55, null);
		palette[11] = cm.getDataElements(0xff_55_ff_ff, null);
		palette[12] = cm.getDataElements(0xff_ff_55_55, null);
		palette[13] = cm.getDataElements(0xff_ff_55_ff, null);
		palette[14] = cm.getDataElements(0xff_ff_ff_55, null);
		palette[15] = cm.getDataElements(0xff_ff_ff_ff, null);
		return palette;
	}

	private void drawImage() {
		final var raster = bi.getRaster();
		int pidx = paletteOffs;

		for(int y = 0; y < bi.getHeight(); ++y) {
			for (int x = 0; x < bi.getWidth(); ++x) {
				// raster.setDataElements takes the colormodel output and sets the value in the raster
				raster.setDataElements(x, y, palette[pidx]);
				if(++pidx == 16) pidx = 0;
			}
			if(++pidx == 16) pidx = 0;
		}

		// change the base offset for the next run
		if(++paletteOffs == 16) { paletteOffs = 0; }
	}

	public Cmd() {
		super("Pixel-Perfect");
		setDefaultCloseOperation(EXIT_ON_CLOSE);

		// we create the ideal image type for our display...
		bi = GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice().getDefaultConfiguration().createCompatibleImage(160,200);
		palette = Cmd.setUpEGAPalette(bi);
	    drawImage();

		pixart = new JComponent() {
			{ setPreferredSize(new Dimension( 160*2*3, 240*3)); }
			
			@Override
			public void paintComponent(Graphics g) {
				super.paintComponent(g);
				// ok paint the largest 4:3 image possible in the space we have...
				final int totalWidth = pixart.getWidth();
				final int totalHeight = pixart.getHeight();

				// use height/width 3:4 instead of width/height 4:3 because 0.75 is nicer to type exactly in base 10.
				final float totalAR = (float)totalHeight/(float)totalWidth;
				int w43, h43;
				if(totalAR >= 0.75) {
					// case 1: totalHeight too tall... totalAR >= 0.75 ...
					w43 = totalWidth;
					h43 = (int)(0.75*totalWidth);
				} else {
					// case 2: totalWidth is too wide... totalAR < 0.75
					w43 = (int)(1.3333333f*totalHeight);
					h43 = totalHeight;
				}

				// we want to center the canvas...
				final int xoffs = (totalWidth - w43)/2;
				final int yoffs = (totalHeight - h43)/2;

				Graphics2D g2 = (Graphics2D)g;
				// paint black borders...
				g.setColor(Color.BLACK);
				if(h43 < totalHeight) {
					g.fillRect(0, 0, totalWidth, yoffs);
					g.fillRect(0, yoffs + h43, totalWidth, totalHeight - yoffs - h43);
				} else if(w43 < totalWidth) {
					g.fillRect(0,0,xoffs,totalHeight);
					g.fillRect(xoffs+w43,0,totalWidth-xoffs-w43, totalHeight);
				}
				// now paint the image...
				g2.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_NEAREST_NEIGHBOR);
				g2.drawImage(bi, xoffs, yoffs, w43, h43, null);
			}
		};
		setContentPane(pixart);
		pack();
		setVisible(true);
		new javax.swing.Timer(1000/20, e -> {
			drawImage();
			repaint();
		}).start();
	}
	
	public static void main(String[] args) {
		SwingUtilities.invokeLater(() -> new Cmd());
	}

}
