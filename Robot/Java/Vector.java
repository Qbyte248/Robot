package Robot.Java;

import java.util.ArrayList;
import Robot.Java.Helper.ObjectConvertible;
import Robot.Java.Helper.Helper;

class Vector implements ObjectConvertible {
	double x;
	double y;
	
	Vector(double x, double y) {
		this.x = x;
		this.y = y;
	}
	
	Vector copy() {
		return new Vector(x, y);
	}
	
	Vector add(Vector vector) {
		return new Vector(this.x + vector.x, this.y + vector.y);
	}
	Vector subtract(Vector vector) {
		return new Vector(this.x - vector.x, this.y - vector.y);
	}
	Vector multiply(double scalar) {
		return new Vector(x * scalar, y * scalar);
	}
	void addInPlace(Vector vector) {
		x += vector.x;
		y += vector.y;
	}
	void subtractInPlace(Vector vector) {
		x -= vector.x;
		y -= vector.y;
	}
	
	// --- ObjectConvertible
	
	public void convertFromObject(Object object) throws IllegalArgumentException {
		ArrayList<String> list = Helper.castToArrayListOfStrings(object);
		// !!! can throw
		Helper.throwIllegalErgumentExceptionIfNull("list is null", list);
		
		if (list.size() != 2) {
			throw new IllegalArgumentException("list has not size == 2");
		}
		
		try {
			this.x = Double.parseDouble(list.get(0));
			this.y = Double.parseDouble(list.get(1));
		} catch (NumberFormatException e) {
			throw new IllegalArgumentException("could not parse numbers from String");
		}
	}
	
	public Object convertToObject() {
		ArrayList<String> list = new ArrayList<>();
		list.add(x + "");
		list.add(y + "");
		return list;
	}
	
}
