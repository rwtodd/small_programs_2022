package rwt.pixelart;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import javax.swing.*;


// compare to sibling project jfx-pixelart-scale ... and you'll see how relatively easy
// it is to get a pixel-perfect scaled image in swing

// here I compare drawing at actual device resolution vs letting swing scale it for
// me... pressing any key switches between the views

public class Cmd extends JFrame {

	private static final long serialVersionUID = -7835865311308198512L;

	private JPanel jp, jp2;
	
	private final BufferedImage bi;
	
	private void drawImage() {
		// make the image
		for(int y=0;y< bi.getHeight();++y)
			for(int x=0;x<bi.getWidth();++x)
				bi.setRGB(x, y, 0xff_ff_00_00);

		// make a checkerboard
		for(int y=0;y< bi.getHeight();++y)
			for(int x=0;x<bi.getWidth();++x)
				bi.setRGB(x, y, (((x+y)&1)==0)? 0xff_ff_00_00: 0xff_00_ff_00);
		
		// draw a diagonal line
//		int y =0;
//		for(int x=0;x<bi.getWidth();++x)
//			bi.setRGB(x, y++, 0xff_00_ff_00);
	}
	
	public Cmd() {
		super("Pixel-Perfext");
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		
		bi = new BufferedImage(160, 200, BufferedImage.TYPE_INT_ARGB_PRE);
	    drawImage();
	    
		jp = new JPanel() {
			{ setPreferredSize(new Dimension(160*2*3, 240*3)); }
			
			@Override
			public void paint(Graphics g) {
				super.paint(g);
				Graphics2D g2 = (Graphics2D)g;
				var saveTransform = g2.getTransform();
				AffineTransform nt = (AffineTransform)saveTransform.clone();
				nt.setToIdentity();
				g2.setTransform(nt);
				g2.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_NEAREST_NEIGHBOR);
				g2.drawImage(bi, 0, 0, (int)(jp.getWidth()*saveTransform.getScaleX()), (int)(jp.getHeight()*saveTransform.getScaleY()), null);
				g2.setColor(Color.BLACK);
				g2.drawOval((int)(10*saveTransform.getScaleX()), (int)(10*saveTransform.getScaleY()),(int)(50*saveTransform.getScaleX()),(int)(50*saveTransform.getScaleY()));
				g2.setTransform(saveTransform);
			}
		};
		jp2 = new JPanel() {
			{ setPreferredSize(new Dimension(160*2*3, 240*3)); }
			
			@Override
			public void paint(Graphics g) {
				super.paint(g);
				Graphics2D g2 = (Graphics2D)g;
				g2.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_NEAREST_NEIGHBOR);
				g2.drawImage(bi, 0, 0, jp.getWidth(),jp.getHeight(), null);
				g2.setColor(Color.BLUE);
				g2.drawOval(10, 10,50,50);
				g2.drawOval(100, 100,50,50);
			}
		};
		setContentPane(jp);
		addKeyListener(new KeyListener() {

			@Override
			public void keyTyped(KeyEvent e) {
				// TODO Auto-generated method stub
				e.consume();
			}

			@Override
			public void keyPressed(KeyEvent e) {
				e.consume();
				setContentPane(getContentPane()==jp?jp2:jp);
				pack();
				repaint(10);
			}

			@Override
			public void keyReleased(KeyEvent e) {
				// TODO Auto-generated method stub
				e.consume();
			}});
		pack();
		setVisible(true);
	}
	
	public static void main(String[] args) {
		SwingUtilities.invokeLater(() -> new Cmd());
	}

}
