package rwt.pixelart;

import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.image.BufferedImage;
import java.util.Random;
import javax.swing.*;


// compare to sibling project jfx-pixelart-scale ... and you'll see how relatively easy
// it is to get a pixel-perfect scaled image in swing

// here I compare drawing at actual device resolution vs letting swing scale it for
// me... pressing any key switches between the views

public class Cmd extends JFrame {

	private static final long serialVersionUID = -7835865311308198512L;

	private JComponent pixart;
	
	private final BufferedImage bi;
	private Random rng = new Random();

//	private void drawImage() {
//		int c1 = rng.nextInt() | 0xff_00_00_ff;
//		int c2 = rng.nextInt() | 0xff_00_00_ff;
//
//		// make a checkerboard
//		for(int y=0;y< bi.getHeight();++y)
//			for(int x=0;x<bi.getWidth();++x)
//				bi.setRGB(x, y, (((x+y)&1)==0)? c1 : c2);
//	}

	private int c1 = 0xff_00_00_00;
	private Object col1 =null;
	private int c2 = 0xff_ff_00_00;
	private Object col2 = null;

	private void drawImage() {
		//getDataElements takes an ARGB value and converts it to what the raster wants...
		col1 = bi.getColorModel().getDataElements(c1, col1);
		col2 = bi.getColorModel().getDataElements(c2, col2);
		final var raster = bi.getRaster();

		for(int y = 0; y < bi.getHeight(); ++y)
			for(int x = 0; x < bi.getWidth(); ++x)
				// ... and raster.setDataElements takes the colormodel output and sets the value in the raster
				raster.setDataElements(x,y, ((x+y)&1) == 0 ? col1 : col2);

		c1 += rng.nextInt(8);
		c2 += rng.nextInt(8);
		if(c1 >= 0xff_00_01_00) c1 = 0xff_00_00_00;
		if(c2 >= 0xff_ff_01_00) c2 = 0xff_ff_00_00;
	}

	public Cmd() {
		super("Pixel-Perfect");
		setDefaultCloseOperation(EXIT_ON_CLOSE);

		// we create the ideal image type for our display...
		bi = GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice().getDefaultConfiguration().createCompatibleImage(160,200);
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
		new javax.swing.Timer(1000/60, new ActionListener() {
			@Override public void actionPerformed(ActionEvent e) {
				drawImage();
				repaint();
			}
		}).start();
	}
	
	public static void main(String[] args) {
		SwingUtilities.invokeLater(() -> new Cmd());
	}

}
