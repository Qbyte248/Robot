package Robot.Java;

import java.util.ArrayList;
import java.util.HashMap;
import Robot.Java.Helper.ObjectConvertible;
import Robot.Java.Helper.Helper;

// Graphics
import java.awt.Color
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.geom.Line2D;
import java.awt.Graphics2D;

class Position implements ObjectConvertible {
	int x;
	int y;
	
	Position(int x, int y) {
		this.x = x;
		this.y = y;
	}
	
	boolean equals(Position position) {
		return x == position.x && y == position.y;
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
			this.x = Integer.parseInt(list.get(0));
			this.y = Integer.parseInt(list.get(1));
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

class Direction implements ObjectConvertible {
	/// encoded as north, south, west, east
	String direction;

	// --- ObjectConvertible

	public void convertFromObject(Object object) throws IllegalArgumentException {
		String string = Helper.castToString(object);
		// !!! can throw
		Helper.throwIllegalErgumentExceptionIfNull("string is null", string);

		switch (string) {
		case "north":
		case "south":
		case "west":
		case "east": break;
		default:
			throw new IllegalArgumentException("invalid direction");

		}

		this.direction = string;
	}

	public Object convertToObject() {
		return direction;
	}

}

class Texture implements ObjectConvertible {
	ArrayList<DrawableObject> drawables = new ArrayList<>();
	
	void append(DrawableObject drawableObject) {
		drawables.add(drawableObject);
	}
	
	Texture scaled(double scaleFactor) {
		
		Texture scaledTexture = new Texture();
		
		for (DrawableObject drawable : drawables) {
			
			MyColor color = drawable.getColor();
			Line line = drawable.getLine();
			Rectangle rectangle = drawable.getRectangle();
			Polygon polygon = drawable.getPolygon();
			
			if (color != null) {
				scaledTexture.append(color);
			} else if (line != null) {
				scaledTexture.append(new Line(
											  line.start.multiply(scaleFactor),
											  line.end.multiply(scaleFactor)));
			} else if (rectangle != null) {
				scaledTexture.append(new Rectangle(
												   rectangle.origin.x * scaleFactor,
												   rectangle.origin.y * scaleFactor,
												   rectangle.size.width * scaleFactor,
												   rectangle.size.height * scaleFactor));
			} else if (polygon != null) {
				Polygon poly = new Polygon();
				for (Vector point : polygon.points) {
					poly.append(point.multiply(scaleFactor));
				}
				scaledTexture.append(poly);
			} else {
				throw new AssertionError("unexpected condition");
			}
		}
		
		return scaledTexture;
	}
	
	public void drawOnGraphics(Graphics g, Vector offset) {
		for (Drawable drawable : drawables) {
			
			MyColor color = drawable.getColor();
			Line line = drawable.getLine();
			Rectangle rectangle = drawable.getRectangle();
			Polygon polygon = drawable.getPolygon();
			
			if (color != null) {
				g.setColor(color.getAWTColor());
			} else if (line != null) {
				/*g.drawLine(new Line2D(
				 (int)line.start.x, (int)line.start.y,
				 (int)line.end.x, (int)line.end.y);*/
				line = line.moved(offset);
				
				((Graphics2D)g).draw(
									 new Line2D.Double(line.start.x, line.start.y,
													   line.end.x, line.end.y));
			} else if (rectangle != null) {
				rectangle = rectangle.moved(offset);
				
				g.fillRect((int)rectangle.origin.x, (int)rectangle.origin.y,
						   (int)rectangle.size.width, (int)rectangle.size.height);
			} else if (polygon != null) {
				// FIXME: use a polygon with double or float precision
				
				polygon = polygon.moved(offset);
				
				int[] xs = new int[polygon.points.size()];
				int[] ys = new int[polygon.points.size()];
				for (int i = 0; i < polygon.points.size(); i += 1) {
					xs[i] = (int)(polygon.points.get(i).x + 0.5);
					ys[i] = (int)(polygon.points.get(i).y + 0.5);
				}
				g.fillPolygon(xs, ys, polygon.points.size());
			} else {
				throw new AssertionError("unexpected condition");
			}
		}
	}
	
	// --- ObjectConvertible
	
	// Helper
	
	private void appendDrawableObjects(DrawableObject drawableObject, ArrayList<Object> obj) {
		// TODO: use it as helper method
	}
	
	public void convertFromObject(Object object) throws IllegalArgumentException {
		
		ArrayList<Object> list = Helper.castToArrayListOfObjects(object);
		// !!! can throw
		Helper.throwIllegalErgumentExceptionIfNull("list is null", list);
		
		this.drawables = new ArrayList<>();
		
		for (Object element : list) {
			
			HashMap<String, Object> map = Helper.castToHashMapOfObjects(element);
			// !!! can throw
			Helper.throwIllegalErgumentExceptionIfNull("map is null", map);
			
			for (String key : map.keySet()) {
				ArrayList<Object> value = Helper.castToArrayListOfObjects(map.get(key));
				// !!! can throw
				Helper.throwIllegalErgumentExceptionIfNull("value is null", value);
				
				switch (key) {
					case "colors":
						for (Object obj : value) {
							MyColor color = new MyColor(0,0,0,0);
							// !!! can throw
							color.convertFromObject(obj);
							this.drawables.add(color);
						}
						break;
					case "lines":
						for (Object obj : value) {
							Line line = new Line(new Vector(0,0), new Vector(0,0));
							// !!! can throw
							line.convertFromObject(obj);
							this.drawables.add(line);
						}
						break;
					case "rectangles":
						for (Object obj : value) {
							Rectangle rect = new Rectangle(0,0,0,0);
							// !!! can throw
							rect.convertFromObject(obj);
							this.drawables.add(rect);
						}
						break;
					case "polygons":
						for (Object obj : value) {
							Polygon poly = new Polygon();
							// !!! can throw
							poly.convertFromObject(obj);
							this.drawables.add(poly);
						}
						break;
					default:
						throw new IllegalArgumentException("unexpected key: ---" + key + "---");
				}
			}
			
		}
		
	}
	
	// not applicable since it does not preserve order
	// it is not commented out since it is useful for debugging
	public Object convertToObject() {
		ArrayList<Object> colors = new ArrayList<>();
		ArrayList<Object> lines = new ArrayList<>();
		ArrayList<Object> rectangles = new ArrayList<>();
		ArrayList<Object> polygons = new ArrayList<>();
		
		for (DrawableObject drawableObject : drawables) {
			MyColor color = drawableObject.getColor();
			Line line = drawableObject.getLine();
			Rectangle rectangle = drawableObject.getRectangle();
			Polygon polygon = drawableObject.getPolygon();
			
			if (color != null) {
				colors.add(color.convertToObject());
			} else if (line != null) {
				lines.add(line.convertToObject());
			} else if (rectangle != null) {
				rectangles.add(rectangle.convertToObject());
			} else if (polygon != null) {
				polygons.add(polygon.convertToObject());
			}
		}
		
		HashMap<String, ArrayList<Object>> map = new HashMap<>();
		map.put("colors", colors);
		map.put("lines", lines);
		map.put("rectangles", rectangles);
		map.put("polygons", polygons);
		
		return map;
		//return null;
	}
}

class Item implements ObjectConvertible {
	Position position = new Position(0,0);
	Texture texture = new Texture();
	
	void drawOnGraphics(Graphics g, Vector offset) {
		texture.drawOnGraphics(g, offset);
	}
	
	// --- ObjectConvertible
	
	public void convertFromObject(Object object) throws IllegalArgumentException {
		HashMap<String, Object> map = Helper.castToHashMapOfObjects(object);
		// !!! can throw
		Helper.throwIllegalErgumentExceptionIfNull("map is null", map);
		
		// --- Position
		Object positionObj = map.get("position");
		// !!! can throw
		Helper.throwIllegalErgumentExceptionIfNull("positionObj is null", positionObj);
		// !!! can throw
		this.position.convertFromObject(positionObj);
		
		// --- Texture
		Object textureObj = map.get("texture");
		// !!! can throw
		Helper.throwIllegalErgumentExceptionIfNull("textureObj is null", textureObj);
		// !!! can throw
		this.texture.convertFromObject(textureObj);
	}
	
	public Object convertToObject() {
		HashMap<String, Object> map = new HashMap<>();
		map.put("position", position.convertToObject());
		map.put("texture", texture.convertToObject());
		
		return map;
	}
}

class Robot extends Item {
	Direction direction;
	
	// --- ObjectConvertible
	
	@Override public void convertFromObject(Object object) throws IllegalArgumentException {
		// !!! can throw
		super.convertFromObject(object);
		
		HashMap<String, Object> map = Helper.castToHashMapOfObjects(object);
		// !!! can throw
		Helper.throwIllegalErgumentExceptionIfNull("map is null", map);
		
		// --- Direction
		Object directionObj = map.get("direction");
		// !!! can throw
		Helper.throwIllegalErgumentExceptionIfNull("direction is null", directionObj);
		this.direction = new Direction();
		// !!! can throw
		this.direction.convertFromObject(directionObj);
		
		/*
		// --- Name
		Object nameObj = map.get("name");
		// !!! can throw
		Helper.throwIllegalErgumentExceptionIfNull("nameObj is null", nameObj);
		this.name = Helper.castToString(nameObj);
		// !!! can throw
		Helper.throwIllegalErgumentExceptionIfNull("name is null", this.name);
		 */
	}
	
	@Override public Object convertToObject() {
		Object obj = super.convertToObject();
		HashMap<String, Object> map = Helper.castToHashMapOfObjects(obj);
		// !!! can throw but should never!
		Helper.throwIllegalErgumentExceptionIfNull("map is null", map);
		map.put("direction", direction.convertToObject());
		//map.put("name", name);
		return map;
	}
}

class World implements ObjectConvertible {
	
	ArrayList<Robot> robots = new ArrayList<Robot>();
	ArrayList<Item> items = new ArrayList<>();
	
	// x, y, halfBlockHeight
	ArrayList<ArrayList<Integer>> halfBlocks = new ArrayList<>();
	
	int width;
	int depth;
	
	// Draw properties
	double blockSideLength;
	Texture halfBlockTexture = new Texture();
	
	Texture gridTexture = new Texture();
	
	World() {}
	
	int getHeightAt(Position position) {
		return getHeightAt(position.x, position.y);
	}
	int getHeightAt(int x, int y) {
		return halfBlocks.get(x).get(y).intValue();
	}
	void setHeightAt(int x, int y, int newHeight) {
		halfBlocks.get(x).set(y, new Integer(newHeight));
	}
	
	Vector offsetVectorFromCoordinates(int x, int y, int z) {
		double newY = (double)(y) / Math.sqrt(2) / 2;
		return new Vector((x + newY) * blockSideLength, -((double)(z) / 2 + newY) * blockSideLength);
	}
	
	void drawOnGraphics(Graphics g, Vector drawOffset) {
		System.out.println("start drawing world");
		
		// draw grid
		gridTexture.drawOnGraphics(g, drawOffset);
		
		// halfBlock, robots and items
		for (int x = 0; x < width; x++) {
			for (int y = depth - 1; y >= 0; y--) {
				int height = getHeightAt(x, y);
				for (int z = 0; z < height; z++) {
					Vector offset = offsetVectorFromCoordinates(x, y, z).add(drawOffset);
					halfBlockTexture.drawOnGraphics(g, offset);
				}
				drawItemsAt(x, y, g, offsetVectorFromCoordinates(x, y, height).add(drawOffset));
			}
		}
	}
	
	/// including robot
	///
	/// offset should be precomputed
	void drawItemsAt(int x, int y, Graphics g, Vector offset) {
		Position pos = new Position(x, y);
		for (Item item : items) {
			if (item.position.equals(pos)) {
				item.drawOnGraphics(g, offset);
			}
		}
		for (Robot robot : robots) {
			if (robot.position.equals(pos)) {
				robot.drawOnGraphics(g, offset);
			}
		}
	}
	
	// --- ObjectConvertible
	
	class Properties {
		static final String robots = "robots";
		static final String items = "items";
		
		static final String halfBlocks = "halfBlocks";
		
		static final String width = "width";
		static final String depth = "depth";
		
		static final String blockSideLength = "blockSideLength";
		static final String halfBlockTexture = "halfBlockTexture";
	}
	
	
	public void convertFromObject(Object object) throws IllegalArgumentException {
		
		HashMap<String, Object> map = Helper.castToHashMapOfObjects(object);
		// !!! can throw
		Helper.throwIllegalErgumentExceptionIfNull("map is null", map);
		
		ArrayList<Object> robotObjects = Helper.castToArrayListOfObjects(map.get(Properties.robots));
		ArrayList<Object> itemObjects = Helper.castToArrayListOfObjects(map.get(Properties.items));
		
		ArrayList<Object> halfBlockObjects = Helper.castToArrayListOfObjects(map.get(Properties.halfBlocks));
		
		
		String stringWidth = Helper.castToString(map.get(Properties.width));
		String stringDepth = Helper.castToString(map.get(Properties.depth));
		
		String stringBlockSideLength = Helper.castToString(map.get(Properties.blockSideLength));
		Object halfBlockTextureObject = map.get(Properties.halfBlockTexture);
		
		// !!! can throw
		Helper.throwIllegalErgumentExceptionIfNull("something is null",
												   robotObjects, itemObjects, halfBlockObjects, stringWidth, stringDepth, stringBlockSideLength, halfBlockTextureObject);
		// reset some properties
		this.robots = new ArrayList<>();
		this.items = new ArrayList<>();
		
		this.halfBlocks = new ArrayList<ArrayList<Integer>>();
		
		// convert to normal instances
		
		// robots
		for (Object robotObject : robotObjects) {
			Robot robot = new Robot();
			robot.convertFromObject(robotObject);
			robots.add(robot);
		}
		
		// items
		for (Object itemObject : itemObjects) {
			Item item = new Item();
			item.convertFromObject(itemObject);
			items.add(item);
		}
		
		// halfBlocks
		for (Object halfBlockObjects2 : halfBlockObjects) {
			ArrayList<String> list = Helper.castToArrayListOfStrings(halfBlockObjects2);
			ArrayList<Integer> newList = new ArrayList<>();
			for (String integerString : list) {
				try {
					// !!! can throw
					newList.add(new Integer(integerString));
				} catch (Exception e) {
					throw new IllegalArgumentException("string cannot be converted to number");
				}
			}
			halfBlocks.add(newList);
		}
		
		// width, depth
		this.width = Integer.parseInt(stringWidth);
		this.depth = Integer.parseInt(stringDepth);
		
		// blockSideLength
		this.blockSideLength = Double.parseDouble(stringBlockSideLength);
		
		// halfBlockTexture
		this.halfBlockTexture.convertFromObject(halfBlockTextureObject);
		
		
		// scale textures
		this.halfBlockTexture = this.halfBlockTexture.scaled(this.blockSideLength);
		for (Robot robot : robots) {
			robot.texture = robot.texture.scaled(this.blockSideLength);
		}
		for (Item item : items) {
			item.texture = item.texture.scaled(this.blockSideLength);
		}
		
		// make gridTexture
		
		gridTexture = new Texture();
		gridTexture.append(new MyColor(0,0,1,1));
		for (int x = 0; x <= width; x++) {
			gridTexture.append(new Line(
										offsetVectorFromCoordinates(x, 0, 0),
										offsetVectorFromCoordinates(x, depth, 0)));
		}
		for (int y = 0; y <= depth; y++) {
			gridTexture.append(new Line(
										offsetVectorFromCoordinates(0, y, 0),
										offsetVectorFromCoordinates(width, y, 0)));
		}
	}
	
	// Not implemented
	public Object convertToObject() {
		return null;
	}

}
