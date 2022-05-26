package arm.node.brush;

import kha.Image;
import iron.RenderPath;
import arm.Enums;

@:keep
class BrushOutputNode extends LogicNode {

	public var id = 0;
	public var texpaint: Image = null;
	public var texpaint_nor: Image = null;
	public var texpaint_pack: Image = null;

	public static var inst: BrushOutputNode = null;

	public function new(tree: LogicTree) {
		super(tree);

		if (inst == null) {

			{
				var t = new RenderTargetRaw();
				t.name = "texpaint";
				t.width = Config.getTextureResX();
				t.height = Config.getTextureResY();
				t.format = "RGBA32";
				texpaint = RenderPath.active.createRenderTarget(t).image;
			}
			{
				var t = new RenderTargetRaw();
				t.name = "texpaint_nor";
				t.width = Config.getTextureResX();
				t.height = Config.getTextureResY();
				t.format = "RGBA32";
				texpaint_nor = RenderPath.active.createRenderTarget(t).image;
			}
			{
				var t = new RenderTargetRaw();
				t.name = "texpaint_pack";
				t.width = Config.getTextureResX();
				t.height = Config.getTextureResY();
				t.format = "RGBA32";
				texpaint_pack = RenderPath.active.createRenderTarget(t).image;
			}
		}
		else {
			texpaint = inst.texpaint;
			texpaint_nor = inst.texpaint_nor;
			texpaint_pack = inst.texpaint_pack;
		}

		inst = this;
	}

	override function get(from: Int): Dynamic {
		return inputs[from].get();
	}
}
