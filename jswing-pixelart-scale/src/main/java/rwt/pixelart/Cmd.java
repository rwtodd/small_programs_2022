package rwt.pixelart;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.util.Random;
import javax.swing.*;


// compare to sibling project jfx-pixelart-scale ... and you'll see how relatively easy
// it is to get a pixel-perfect scaled image in swing

// here I compare drawing at actual device resolution vs letting swing scale it for
// me... pressing any key switches between the views

public class Cmd extends JFrame {

	private static final long serialVersionUID = -7835865311308198512L;

	private JPanel jp;
	
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
	private int c2 = 0xff_ff_00_00;

	private void drawImage() {
		for(int y = 0; y < bi.getHeight(); ++y)
			for(int x = 0; x < bi.getWidth(); ++x)
				bi.setRGB(x,y, (((x+y)&1)==0)? c1 : c2);
		c1 += 4;
		c2 += 4;
		if(c1 >= 0xff_00_00_f1) c1 = 0xff_00_00_00;
		if(c2 >= 0xff_ff_00_f1) c2 = 0xff_ff_00_00;
	}

	public Cmd() {
		super("Pixel-Perfext");
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		
		bi = new BufferedImage(160, 200, BufferedImage.TYPE_INT_ARGB_PRE);
	    drawImage();

		jp = new JPanel() {
			{ setPreferredSize(new Dimension(0160*2*3, 240*3)); }
			
			@Override
			public void paintComponent(Graphics g) {
				super.paintComponent(g);
				Graphics2D g2 = (Graphics2D)g;
				g2.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_NEAREST_NEIGHBOR);
				g2.drawImage(bi, 0, 0, jp.getWidth(),jp.getHeight(), null);
			}
		};
		setContentPane(jp);
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
