package Robot.Java.Helper;
import java.util.HashMap;

public class TestCommand {

	/**
	 * searches the class Command for bugs
	 */
	public static void main(String[] args) {
		//random Command with parameters, build
		HashMap<String, String> parameters = new HashMap<String, String>();
		parameters.put("genia", "1");
		parameters.put("maximilian", "2");
		parameters.put("lukas", "3");
		Command myCommand = new Command("",Protocol.Server.List.all_users ,parameters);
		String command1 = myCommand.convertToString();
		System.out.println(command1);
		// works
		
		
		//random Command without parameters, build
		myCommand = new Command("moi","game_ready");
		String command2 = myCommand.convertToString();
		System.out.println(command2);
		//works
		
		
		//random Command with parameters, parse
		myCommand = new Command(command1);
		System.out.println(myCommand.convertToString());
		//Lost information: no parameters!
			//fixed!
		
		
		//random Command without parameters, parse
		myCommand = new Command(command2);
		System.out.println(myCommand.convertToString());
		//works
		
		
		//provoke no delimiters Exception
		try {
			myCommand = new Command("abc");
			System.out.println(myCommand.convertToString());
		} catch (IllegalArgumentException e) {
			System.out.println("Test 1: " + e);
		}
		//Exception was thrown
		
				
		//forget first delimiter
		try {
			myCommand = new Command("moi§$%&game_ready§$%&second try§$%&");
			System.out.println(myCommand.convertToString());
		} catch (IllegalArgumentException e) {
			System.out.println("Test 2: " + e);
		}
		//Exception was thrown
		
		
		//forget last delimiter
		try {
			myCommand = new Command("§$%&moi§$%&game_ready§$%&second try§$%&1-:-Test Text");
			System.out.println(myCommand.convertToString());
		} catch (IllegalArgumentException e) {
			System.out.println("Test 3: " + e);
		}
		//works
		
		
		//Send chat message, build
		try {
			myCommand = new Command("moi","chat_message");
			myCommand.addParameter("1", "This is my text.");
			command1 = myCommand.convertToString();
			System.out.println(command1);
		} catch (IllegalArgumentException e) {
			System.out.println("Test 4: " + e);
		}
		//works
				
		
		//Send chat message, parse
		try {
			myCommand = new Command(command1);
			System.out.println(myCommand.convertToString());
		} catch (IllegalArgumentException e) {
			System.out.println("Test 5: " + e);
		}
		//works
		
		
		//Send wrong chat message, build
		try {
			myCommand = new Command("moi","chat_message");
			myCommand.addParameter("1", "my text is stupid because it contains §$%& and it shouldn't do that.");
			command2 = myCommand.convertToString();
			System.out.println(command2);
		} catch (IllegalArgumentException e) {
			System.out.println("Test 6: " + e);
			
		}
		//Exception was thrown
		
		
		//Send wrong chat message, parse, this should never appear
		try {
			myCommand = new Command("§$%&moi§$%&chat_message§$%&third try§$%&1-:-my text is stupid because it contains §$%& and it shouldn't do that.§$%&");
			System.out.println(myCommand.convertToString());
		} catch (IllegalArgumentException e) {
			System.out.println("Test 7: " + e);
		}
		//Exception was thrown, no name
		
		
		//Empty Hashmap, this should never appear
		try {
			myCommand = new Command("§$%&moi§$%&game_ready§$%&second try§$%&§$%&");
			System.out.println(myCommand.convertToString());
		} catch (IllegalArgumentException e) {
			System.out.println("Test 8: " + e);
		}
		//Exception was thrown, no name
		
		
		//still needs to be tested: Nullpointer exceptions
	}
}
