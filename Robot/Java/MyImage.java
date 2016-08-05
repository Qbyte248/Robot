package Robot.Java;

import java.util.ArrayList;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import javax.imageio.ImageIO;

import Robot.Java.Helper.ObjectConvertible;
import Robot.Java.Helper.Helper;

// Currently no support in Swift
class MyImage implements DrawableObject {
	BufferedImage image;
	
	MyImage() {}
	
	// --- ObjectConvertible
	
	public void convertFromObject(Object object) throws IllegalArgumentException {
		String imageString = Helper.castToString(object);
		// !!! can throw
		Helper.throwIllegalErgumentExceptionIfNull("imageString is null", imageString);
		
		
		try {
			image = ImageIO.read(new ByteArrayInputStream(imageString.getBytes()));
		} catch (Exception e) {
			throw new IllegalArgumentException("could not convert string to image");
		}
		
		//byte[] imageBytes = Base64.decodeBase64(imageString);
		//image = ImageIO.read(new ByteArrayInputStream(imageBytes));
	}
	
	public Object convertToObject() {
		return null;
	}
	
	// - Helper
	
	public static MyImage fromObject(Object obj) throws IllegalArgumentException {
		MyImage image = new MyImage();
		// !!! can throw
		image.convertFromObject(obj);
		return image;
	}
	
	// --- Drawable
	
	public MyColor getColor() { return null; }
	public Line getLine() { return null; }
	public Rectangle getRectangle() { return null; }
	public Polygon getPolygon() { return null; }
	public MyImage getImage() { return this; }
}
