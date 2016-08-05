package Robot.Java.Helper;

import java.util.ArrayList;
import java.util.HashMap;

public class ParserTest {

	public static void main(String[] args) {
		if (true) {
		ArrayList<HashMap<String, ArrayList<String>>> list = new ArrayList<HashMap<String, ArrayList<String>>>();
		
		HashMap<String, ArrayList<String>> hashMap = new HashMap<String, ArrayList<String>>();
		
		
		ArrayList<String> smallList1 = new ArrayList<String>();
		smallList1.add("It's");
		smallList1.add("me");
		
		hashMap.put("Hello", smallList1);
		hashMap.put("Hi", smallList1);
		
		ArrayList<String> smallList2 = new ArrayList<String>();
		// this is removed by converting toString and back
		smallList2.add("a");
		smallList2.add("cool");
		
		hashMap.put("There", smallList2);
		
		list.add(hashMap);
		list.add(hashMap);
		
		System.out.println(list);
		
		Parser parser1 = new Parser(list);
		String listString = parser1.convertToString();
		System.out.println(listString);
		
		Parser parser2 = new Parser(listString);
		System.out.println(parser2.object);
		System.out.println(parser2.convertToString());
		
		System.out.println("expect true: " + (list.toString().equals(parser1.object.toString())));
		System.out.println("expect true: " + (parser1.convertToString().equals(parser2.convertToString())));
		System.out.println("expect true: " + (parser2.object.toString().equals(parser1.object.toString())));
		
		System.out.println("expect true: " + (list.equals(parser1.object)));
		System.out.println("expect true: " + (parser1.convertToString().equals(parser2.convertToString())));
		System.out.println("expect true: " + (parser2.toArrayListOfObjects().equals(parser1.toArrayListOfObjects())));
		
		}
		
		ArrayList<Object> list2 = new ArrayList<>();
		list2.add("jj");
		HashMap<String, String> map = new HashMap<>();
		map.put("", "");
		list2.add(map);
		list2.add("jj");
		
		Parser parser = new Parser(list2);
		System.out.println(parser.convertToString());
		System.out.println(new Parser(parser.convertToString()).convertToString());
		
		String str = ";,";
		System.out.println(str.hashCode());
		printStringsWithHashCode(str.hashCode(), "", 2);
		System.out.println("finish");
		
		getStringWithHashCode(str.hashCode(), "", 2);
	}
	static int counter = 0;
	
	private static String getStringWithHashCode(int hashCode, String s,int n) {
		if (n == 0) {
			if (s.hashCode() == hashCode) {
				System.out.println(counter);
				return s;
			}
			counter++;
			return null;
		}
		for (int i = 0; i < 126; i++) {
			String str = getStringWithHashCode(hashCode, (char)(i) + s, n - 1);
			if (str != null) {
				return str;
			}
		}
		return null;
	}
	
	private static void printStringsWithHashCode(int hashCode, String s,int n) {
		if (n == 0) {
			if (s.hashCode() == hashCode) {
				System.out.println(s);
			}
			return;
		}
		for (int i = 0; i < 126; i++) {
			printStringsWithHashCode(hashCode, (char)(i) + s, n-1);
		}
	}

}
