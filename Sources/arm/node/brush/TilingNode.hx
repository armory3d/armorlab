package arm.node.brush;

@:keep
class TilingNode extends LogicNode {

	static var image: kha.Image = null;
	var result: kha.Image = null;

	public function new(tree: LogicTree) {
		super(tree);

		image = kha.Image.createRenderTarget(2048, 2048);
	}

	override function get(from: Int): Dynamic {
		var source = inputs[0].get();
		if (!Std.isOfType(source, kha.Image)) return null;

		image.g2.begin(false);
		image.g2.drawScaledImage(source, 0, 0, 2048, 2048);
		image.g2.end();

		result = InpaintNode.texsynthInpaint(image, true);
		return result;
	}

	override public function getImage(): kha.Image {
		return result;
	}
}
