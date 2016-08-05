
/**
 * Contains all the information needed to communicate between Client and Server.
 * Command strings and keys to access command parameters.
 */
public enum Protocol {

	// TODO: Congratulations
	
	// Names of all commands the Client can send
	public enum Client {
		public static let color = "color";
		public static let point = "point";
		public static let line = "line";
		public static let rectangle = "rectangle";
		public static let polygon = "polygon";
		
		public static let clear = "clear"
		public static let repaint = "repaint"
		
		
		public static let world = "world"
		public static let run = "run"
	}

	
	public enum Key {
		// names of all keys
		
		public static let color = "color";
		public static let point = "point";
		public static let line = "line";
		public static let rectangle = "rectangle";
		public static let polygon = "polygon";
		
		public static let always = "always"
		
		
		public static let world = "world"
		
		public static let frameTime = "frameTime"
	}
}
