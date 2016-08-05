package Robot.Java.Helper;

/**
 * A simple Wrapper class around any value
 */
public class Wrapper<T> {
	
	private T value;
	
	public Wrapper(T value) {
		this.value = value;
	}
	
	public T getValue() {
		return value;
	}
	public void setValue(T newValue) {
		value = newValue;
	}
}
