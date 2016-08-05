
/**
 * A simple Wrapper class around any value
 */
public class Wrapper<T> {
	
	private var value: T
	
	public init(_ value: T) {
		self.value = value;
	}
	
	public func getValue() -> T {
		return value;
	}
	public func setValue(_ newValue: T) {
		value = newValue;
	}
}
