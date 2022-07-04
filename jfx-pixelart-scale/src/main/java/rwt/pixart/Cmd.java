package rwt.pixart;

import java.nio.IntBuffer;
import java.util.Arrays;

import javafx.application.Application;
import javafx.application.Platform;
import javafx.scene.Scene;
import javafx.scene.canvas.Canvas;
import javafx.scene.layout.*;
import javafx.stage.Stage;
import javafx.scene.control.*;
import javafx.scene.image.Image;
import javafx.scene.image.PixelBuffer;
import javafx.scene.image.PixelFormat;
import javafx.scene.image.WritableImage;

public class Cmd extends Application {

	public static void main(String[] args) {
		launch(args);
		;
	}

	final static int[] colors = new int[] { 0xff_ff_00_00, 0xff_00_ff_00 };

	Image createImage() {
		final int WD = 160, HT = 200;
		final var buff = IntBuffer.allocate(WD * HT);
		final var pb = new PixelBuffer<>(WD, HT, buff, PixelFormat.getIntArgbPreInstance());
		final var im = new WritableImage(pb);

		// now create a diagonal green line
		pb.updateBuffer(b -> {
			var arr = buff.array();
			Arrays.fill(arr, colors[0]);
			int y = 0;
			for(int x = 0; x < WD; ++x)
				arr[y++*WD+x] = colors[1];
			return null;			
		});

		return im;
	}

	// let the canvas scale the image... this unfortunately fails to avoid smoothing
	public void drawImage_one(Canvas cv, Image im) {
		var gc = cv.getGraphicsContext2D();
		gc.setImageSmoothing(false);
		gc.drawImage(im, 0, 0, cv.getWidth(), cv.getHeight());
	}

	// draw nearest-neighbor interpolation ourselves...
	public void drawImage_two(Canvas cv, Image im) {
		System.err.println("Hi!");
		var gc = cv.getGraphicsContext2D();
		gc.setImageSmoothing(false);
		var pw = gc.getPixelWriter();
		var pr = im.getPixelReader();
		final double sx = im.getWidth() / cv.getWidth();
		final double sy = im.getHeight() / cv.getHeight();

		for (int y = 0; y < cv.getHeight(); y++) {
			final int scaleY = (int) Math.floor(y * sy);
			for (int x = 0; x < cv.getWidth(); x++) {
				final int scaleX = (int) Math.floor(x * sx);
				final int c = pr.getArgb(scaleX, scaleY);
				// double-check for our sanity that the input colors are what we expect
				if (c != colors[0] && c != colors[1]) {
					System.err.printf("ERROR color %d not in colors!\n", c);
				}
				pw.setArgb(x, y, c);
			}
		}
	}

	// see if the canvas has colors other than the ones we set
	public void checkCanvas(Canvas cv) {
		var cpr = cv.snapshot(null, null).getPixelReader();
		for (int y = 0; y < cv.getHeight(); y++)
			for (int x = 0; x < cv.getWidth(); x++) {
				final int c = cpr.getArgb(x, y);
				if (c != colors[0] && c != colors[1]) {
					System.err.printf("ERROR snapshot color %08x not in colors!\n", c);
				}
			}
		System.err.println("Done Checking Canvas!");
	}

	@Override
	public void start(Stage primaryStage) throws Exception {
		final var cv = new Canvas(160 * 2 * 3, 240 * 3);
		final var sp = new StackPane(cv);
		final var im = createImage();
		//drawImage_one(cv, im);
		drawImage_two(cv, im);
		final var sc = new Scene(sp);
		primaryStage.setScene(sc);
		
		// see if the canvas has strange colors in it...
		Platform.runLater(() -> {
			checkCanvas(cv);
		});
		primaryStage.show();
	}
}
