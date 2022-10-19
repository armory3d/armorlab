package arm.node.brush;

@:keep
class MathNode extends LogicNode {

	public var operation: String;
	public var use_clamp: Bool;

	public function new(tree: LogicTree) {
		super(tree);
	}

	override function get(from: Int, done: Dynamic->Void) {

		inputs[0].get(function(v1: Float) {
			inputs[1].get(function(v2: Float) {

				var f = 0.0;
				switch (operation) {
					case "Add":
						f = v1 + v2;
					case "Multiply":
						f = v1 * v2;
					case "Sine":
						f = Math.sin(v1);
					case "Cosine":
						f = Math.cos(v1);
					case "Max":
						f = Math.max(v1, v2);
					case "Min":
						f = Math.min(v1, v2);
					case "Absolute":
						f = Math.abs(v1);
					case "Subtract":
						f = v1 - v2;
					case "Divide":
						f = v1 / (v2 == 0.0 ? 0.000001 : v2);
					case "Tangent":
						f = Math.tan(v1);
					case "Arcsine":
						f = Math.asin(v1);
					case "Arccosine":
						f = Math.acos(v1);
					case "Arctangent":
						f = Math.atan(v1);
					case "Arctan2":
					    f = Math.atan2(v2, v1);
					case "Power":
						f = Math.pow(v1, v2);
					case "Logarithm":
						f = Math.log(v1);
					case "Round":
						f = Math.round(v1);
					case "Floor":
					    f = Math.floor(v1);
					case "Ceil":
					    f = Math.ceil(v1);
					case "Truncate":
						f = Math.ffloor(v1);
					case "Fraction":
					    f = v1 - Math.floor(v1);
					case "Less Than":
						f = v1 < v2 ? 1.0 : 0.0;
					case "Greater Than":
						f = v1 > v2 ? 1.0 : 0.0;
					case "Modulo":
						f = v1 % v2;
					case "Snap":
						f = Math.floor(v1 / v2) * v2;
					case "Square Root":
					    f = Math.sqrt(v1);
					case "Inverse Square Root":
						f = 1.0 / Math.sqrt(v1);
					case "Exponent":
						f = Math.exp(v1);
					case "Sign":
						f = v1 > 0 ? 1.0 : (v1 < 0 ? -1.0 : 0);
					case "Ping-Pong":
					    f = (v2 != 0.0) ? v2 - Math.abs((Math.abs(v1) % (2 * v2)) - v2) : 0.0;
					case "Hyperbolic Sine":
						f = (Math.exp(v1) - Math.exp(-v1)) / 2.0;
					case "Hyperbolic Cosine":
						f = (Math.exp(v1) + Math.exp(-v1)) / 2.0;
					case "Hyperbolic Tangent":
						f = 1.0 - (2.0 / (Math.exp(2 * v1) + 1));
					case "To Radians":
						f = v1 / 180.0 * Math.PI;
					case "To Degrees":
						f = v1 / Math.PI * 180.0;
				}

				if (use_clamp) f = f < 0.0 ? 0.0 : (f > 1.0 ? 1.0 : f);

				done(f);
			});
		});
	}
}
