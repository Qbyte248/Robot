package Robot.Java;

import java.util.ArrayList;

import Robot.Java.Helper.ObjectConvertible;
import Robot.Java.Helper.Helper;

class Polygon implements DrawableObject {
	ArrayList<Vector> points = new ArrayList<Vector>();
	
	Polygon() {}
	
	void append(Vector point) {
		points.add(point);
	}
	void move(Vector dv) {
		for (Vector point : points) {
			point.addInPlace(dv);
		}
	}
	void moveToPoint(Vector point) {
		if (points.isEmpty()) {
			return;
		}
		this.move(point.subtract(points.get(0)));
	}
	
	Polygon moved(Vector dv) {
		Polygon poly = new Polygon();
		for (Vector point : points) {
			poly.append(point.add(dv));
		}
		return poly;
	}
	
	ArrayList<Line> getLines() {
		ArrayList<Line> lines = new ArrayList<Line>();
		if (points.isEmpty()) {
			return lines;
		}
		if (points.size() == 1) {
			Vector point = points.get(0);
			lines.add(new Line(point.copy(), point.copy()));
			return lines;
		}
		if (points.size() == 2) {
			lines.add(new Line(points.get(0).copy(), points.get(1).copy()));
			return lines;
		}
		
		Vector currentPoint = points.get(0).copy();
		for (int i = 1; i < points.size(); i += 1) {
			Vector newPoint = points.get(i).copy();
			lines.add(new Line(currentPoint, newPoint));
			currentPoint = newPoint.copy();
		}
		lines.add(new Line(points.get(points.size() - 1).copy(), points.get(0).copy()));
		return lines;
	}
	
	// --- ObjectConvertible
	
	public void convertFromObject(Object object) throws IllegalArgumentException {
		ArrayList<Object> list = Helper.castToArrayListOfObjects(object);
		// !!! can throw
		Helper.throwIllegalErgumentExceptionIfNull("list is null", list);
		
		this.points = new ArrayList<Vector>();
		for (Object obj : list) {
			Vector point = new Vector(0,0);
			// !!! can throw
			point.convertFromObject(obj);
			this.points.add(point);
		}
	}
	
	public Object convertToObject() {
		ArrayList<Object> list = new ArrayList<>();
		for (Vector point : points) {
			list.add(point.convertToObject());
		}
		return list;
	}
	
	// - Helper
	
	public static Polygon fromObject(Object obj) throws IllegalArgumentException {
		Polygon poly = new Polygon();
		// !!! can throw
		poly.convertFromObject(obj);
		return poly;
	}

	// --- Drawable
	
	public MyColor getColor() { return null; }
	public Line getLine() { return null; }
	public Rectangle getRectangle() { return null; }
	public Polygon getPolygon() { return this; }
	public MyImage getImage() { return null; }
}
