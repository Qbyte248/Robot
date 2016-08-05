package Robot.Java.Helper;

/**
 * Contains all the information needed to communicate between Client and Server.
 * Command strings and keys to access command parameters.
 */
public final class Protocol {

	// Names of all commands the Client can send
	public final class Client {
		
		public static final String color = "color";
		public static final String point = "point";
		public static final String line = "line";
		public static final String rectangle = "rectangle";
		public static final String polygon = "polygon";
		public static final String image = "image";
		
		public static final String clear = "clear";
		public static final String repaint = "repaint";
		
		
		public static final String world = "world";
		public static final String run = "run";
		
	}

	
	public final class Key {
		// names of all keys
		
		public static final String color = "color";
		public static final String point = "point";
		public static final String line = "line";
		public static final String rectangle = "rectangle";
		public static final String polygon = "polygon";
		
		public static final String always = "always";
		
		
		public static final String world = "world";
		
		public static final String frameTime = "frameTime";
	}
}
