package rwt.pixelart;

import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import javax.swing.*;


// compare to sibling project jfx-pixelart-scale ... and you'll see how relatively easy
// it is to get a pixel-perfect scaled image in swing

public class Cmd extends JFrame {

	private static final long serialVersionUID = -7835865311308198512L;

	private JPanel jp;
	
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
			{ setSize(160*2*3, 240*3); }
			
			@Override
			public void paint(Graphics g) {
				super.paint(g);
				Graphics2D g2 = (Graphics2D)g;
				g2.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_NEAREST_NEIGHBOR);
				g.drawImage(bi, 0,0, 160*2*3, 240*3, null);
			}
		};
		setContentPane(jp);
		pack();
		setVisible(true);
	}
	
	public static void main(String[] args) {
		SwingUtilities.invokeLater(() -> new Cmd());
	}

}
