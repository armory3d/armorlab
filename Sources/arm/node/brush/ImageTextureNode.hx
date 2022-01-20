package arm.node.brush;

@:keep
class ImageTextureNode extends LogicNode {

	public var file: String;
	public var color_space: String;

	public function new(tree: LogicTree) {
		super(tree);
	}

	override function get(from: Int): Dynamic {
		var index = Project.assetNames.indexOf(file);
		var asset = Project.assets[index];
		return Project.getImage(asset);
	}

	override public function getImage(): kha.Image {
		return get(0);
	}
}
