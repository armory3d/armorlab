package arm.node.brush;

@:keep
class TilingNode extends LogicNode {

	static var image: kha.Image = null;
	var result: kha.Image = null;
	static var prompt = "";
	static var strength = 0.5;
	static var auto = true;

	public function new(tree: LogicTree) {
		super(tree);

		init();
	}

	public static function init() {
		if (image == null) {
			image = kha.Image.createRenderTarget(Config.getTextureResX(), Config.getTextureResY());
		}
	}

	public static function buttons(ui: zui.Zui, nodes: zui.Nodes, node: zui.Nodes.TNode) {
		auto = node.buttons[0].default_value;
		if (!auto) {
			strength = ui.slider(zui.Id.handle({value: strength}), tr("strength"), 0, 1, true);
			prompt = zui.Ext.textArea(ui, zui.Id.handle());
			node.buttons[1].height = 1 + prompt.split("\n").length;
		}
		else node.buttons[1].height = 0;
	}

	override function get(from: Int): Dynamic {
		var source = inputs[0].get();
		if (!Std.isOfType(source, kha.Image)) return null;

		image.g2.begin(false);
		image.g2.drawScaledImage(source, 0, 0, Config.getTextureResX(), Config.getTextureResY());
		image.g2.end();

		result = auto ? InpaintNode.texsynthInpaint(image, true) : sdTiling();
		return result;
	}

	override public function getImage(): kha.Image {
		return result;
	}

	function sdTiling(): kha.Image {
		return null;
	}
}
