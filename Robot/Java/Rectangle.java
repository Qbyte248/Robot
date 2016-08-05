package Robot.Java;

import java.util.ArrayList;
import Robot.Java.Helper.ObjectConvertible;
import Robot.Java.Helper.Helper;

class Size implements ObjectConvertible {
	double width;
	double height;
	
	Size(double width, double height) {
		this.width = width;
		this.height = height;
	}
	
	Size copy() {
		return new Size(width, height);
	}
	
	// --- ObjectConvertible
	
	public void convertFromObject(Object object) throws IllegalArgumentException {
		Vector v = new Vector(0,0);
		// !!! can throw
		v.convertFromObject(object);
		width = v.x;
		height = v.y;
	}
	
	public Object convertToObject() {
		return new Vector(width, height).convertToObject();
	}
}

class Rectangle implements DrawableObject {
	Vector origin;
	Size size;
	
	Rectangle(Vector origin, Size size) {
		this.origin = origin;
		this.size = size;
	}
	
	Rectangle(double x, double y, double width, double height) {
		origin = new Vector(x, y);
		size = new Size(width, height);
	}
	
	Rectangle moved(Vector dv) {
		return new Rectangle(origin.add(dv), size.copy());
	}
	
	// --- ObjectConvertible
	
	public void convertFromObject(Object object) throws IllegalArgumentException {
		ArrayList<Object> list = Helper.castToArrayListOfObjects(object);
		// !!! can throw
		Helper.throwIllegalErgumentExceptionIfNull("list is null", list);
		
		if (list.size() != 2) {
			throw new IllegalArgumentException("list has not size == 2");
		}
		
		// !!! can throw
		this.origin.convertFromObject(list.get(0));
		// !!! can throw
		this.size.convertFromObject(list.get(1));
	}
	
	public Object convertToObject() {
		ArrayList<Object> list = new ArrayList<>();
		list.add(origin.convertToObject());
		list.add(size.convertToObject());
		return list;
	}
	
	// - Helper
	
	public static Rectangle fromObject(Object obj) throws IllegalArgumentException {
		Rectangle rect = new Rectangle(0,0,0,0);
		// !!! can throw
		rect.convertFromObject(obj);
		return rect;
	}
	
	// --- Drawable
	
	public MyColor getColor() { return null; }
	public Line getLine() { return null; }
	public Rectangle getRectangle() { return this; }
	public Polygon getPolygon() { return null; }
	public MyImage getImage() { return null; }
	
}
