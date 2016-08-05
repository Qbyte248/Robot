

public class TestCommand {

	/**
	 * searches the class Command for bugs
	 */
	public static func main() throws {
		//random Command with parameters, build
		/*var parameters =  Dictionary<String, String>();
		parameters.put("genia", "1");
		parameters.put("maximilian", "2");
		parameters.put("lukas", "3");
		var myCommand = try Command(Protocol.Client.point ,parameters);
		var command1 = myCommand.convertToString();
		System.out.println(command1);
		// works
		
		
		//random Command without parameters, build
		myCommand = try Command("game_ready");
		var command2 = myCommand.convertToString();
		System.out.println(command2);
		//works
		
		
		//random Command with parameters, parse
		myCommand = try Command(command1);
		System.out.println(myCommand.convertToString());
		//Lost information: no parameters!
			//fixed!
		
		
		//random Command without parameters, parse
		myCommand = try Command(command2);
		System.out.println(myCommand.convertToString());
		//works
		
		
		//provoke no delimiters Exception
		do {
			myCommand = try Command("abc");
			System.out.println(myCommand.convertToString());
		} catch (let e as IllegalArgumentException) {
			System.out.println("Test 1: \(e)");
		}
		//Exception was thrown
		
				
		//forget first delimiter
		do {
			myCommand = try Command("moi§$%&game_ready§$%&second try§$%&");
			System.out.println(myCommand.convertToString());
		} catch (let e as IllegalArgumentException) {
			System.out.println("Test 2: \(e)");
		}
		//Exception was thrown
		
		
		//forget last delimiter
		do {
			myCommand = try Command("§$%&moi§$%&game_ready§$%&second try§$%&1-:-Test Text");
			System.out.println(myCommand.convertToString());
		} catch (let e as IllegalArgumentException) {
			System.out.println("Test 3: \(e)");
		}
		//works
		
		
		//Send chat message, build
		do {
			myCommand = try Command("chat_message");
			myCommand.addParameter("1", "This is my text.");
			command1 = myCommand.convertToString();
			System.out.println(command1);
		} catch (let e as IllegalArgumentException) {
			System.out.println("Test 4: \(e)");
		}
		//works
				
		
		//Send chat message, parse
		do {
			myCommand = try Command(command1);
			System.out.println(myCommand.convertToString());
		} catch (let e as IllegalArgumentException) {
			System.out.println("Test 5: \(e)");
		}
		//works
		
		
		//Send wrong chat message, build
		do {
			myCommand = try Command("chat_message");
			myCommand.addParameter("1", "my text is stupid because it contains §$%& and it shouldn't do that.");
			command2 = myCommand.convertToString();
			System.out.println(command2);
		} catch (let e as IllegalArgumentException) {
			System.out.println("Test 6: \(e)");
			
		}
		//Exception was thrown
		
		
		//Send wrong chat message, parse, self should never appear
		do {
			myCommand = try Command("§$%&moi§$%&chat_message§$%&third try§$%&1-:-my text is stupid because it contains §$%& and it shouldn't do that.§$%&");
			System.out.println(myCommand.convertToString());
		} catch (let e as IllegalArgumentException) {
			System.out.println("Test 7: \(e)");
		}
		//Exception was thrown, no name
		
		
		//Empty Hashmap, self should never appear
		do {
			myCommand = try Command("§$%&moi§$%&game_ready§$%&second try§$%&§$%&");
			System.out.println(myCommand.convertToString());
		} catch (let e as IllegalArgumentException) {
			System.out.println("Test 8: \(e)");
		}
		//Exception was thrown, no name
		
		
		//still needs to be tested: Nullpointer exceptions


*/
	}
}
