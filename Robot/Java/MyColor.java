package Robot.Java;

import java.util.ArrayList;
import Robot.Java.Helper.Helper;

import java.awt.Color;

class MyColor implements DrawableObject {
	double red;
	double green;
	double blue;
	double alpha;
	
	MyColor(double red, double green, double blue, double alpha) {
		this.red = red;
		this.green = green;
		this.blue = blue;
		this.alpha = alpha;
	}
	
	Color getAWTColor() {
		return new Color((float)red, (float)green, (float)blue, (float)alpha);
	}
	
	// --- ObjectConvertible
	
	public void convertFromObject(Object object) throws IllegalArgumentException {
		ArrayList<String> list = Helper.castToArrayListOfStrings(object);
		// !!! can throw
		Helper.throwIllegalErgumentExceptionIfNull("list is null", list);
		
		if (list.size() != 4) {
			throw new IllegalArgumentException("list has not size == 2");
		}
		
		try {
			this.red = Double.parseDouble(list.get(0));
			this.green = Double.parseDouble(list.get(1));
			this.blue = Double.parseDouble(list.get(2));
			this.alpha = Double.parseDouble(list.get(3));
		} catch (NumberFormatException e) {
			throw new IllegalArgumentException("could not parse numbers from String");
		}
	}
	
	public Object convertToObject() {
		ArrayList<String> list = new ArrayList<>();
		list.add(red + "");
		list.add(green + "");
		list.add(blue + "");
		list.add(alpha + "");
		return list;
	}
	
	// - Helper
	
	public static MyColor fromObject(Object obj) throws IllegalArgumentException {
		MyColor color = new MyColor(0,0,0,0);
		// !!! can throw
		color.convertFromObject(obj);
		return color;
	}
	
	// --- Drawable
	
	public MyColor getColor() { return this; }
	public Line getLine() { return null; }
	public Rectangle getRectangle() { return null; }
	public Polygon getPolygon() { return null; }
	public MyImage getImage() { return null; }
}
