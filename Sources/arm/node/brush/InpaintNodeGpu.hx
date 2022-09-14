package arm.node.brush;

import arm.Enums;

@:keep
class InpaintNodeGpu extends LogicNode {

	static var image: kha.Image = null;
	public static var result: kha.Image = null;
	static var mask: kha.Image = null;
	static var imagetemp: kha.Image = null;
	static var masktemp: kha.Image = null;

	public function new(tree: LogicTree) {
		super(tree);

		init();
	}

	public static function init() {
		if (image == null) {
			image = kha.Image.createRenderTarget(Config.getTextureResX(), Config.getTextureResY());
			result = kha.Image.createRenderTarget(Config.getTextureResX(), Config.getTextureResY());
		}

		if (mask == null) {
			mask = kha.Image.createRenderTarget(Config.getTextureResX(), Config.getTextureResY(), kha.graphics4.TextureFormat.L8);
			App.notifyOnNextFrame(function() {
				mask.g4.begin();
				mask.g4.clear(kha.Color.fromFloats(1.0, 1.0, 1.0, 1.0));
				mask.g4.end();
			});
		}

		if (imagetemp == null) {
			imagetemp = kha.Image.createRenderTarget(256, 256);
			masktemp = kha.Image.createRenderTarget(256, 256, kha.graphics4.TextureFormat.L8);
		}
	}

	override function get(from: Int): Dynamic {
		var source: kha.Image = inputs[0].get();
		if (!Std.isOfType(source, kha.Image)) return null;

		kha.Assets.loadBlobFromPath("data/models/photo_inpaint.onnx", function(model_blob: kha.Blob) {
			var scale = source.width / Config.getTextureResX();
			for (x in 0...Std.int(Config.getTextureResX() / 256)) {
				for (y in 0...Std.int(Config.getTextureResY() / 256)) {
					imagetemp.g2.begin(false);
					imagetemp.g2.drawScaledSubImage(source, x * 256 * scale, y * 256 * scale, 256 * scale, 256 * scale, 0, 0, 256, 256);
					imagetemp.g2.end();
					masktemp.g2.begin(false);
					masktemp.g2.drawScaledSubImage(mask, x * 256 * scale, y * 256 * scale, 256 * scale, 256 * scale, 0, 0, 256, 256);
					masktemp.g2.end();

					var bytes_imgm = untyped masktemp.getPixels().b.buffer;
					var u8 = new js.lib.Uint8Array(untyped bytes_imgm);
					var f32m = new js.lib.Float32Array(1 * 256 * 256);
					for (i in 0...(256 * 256)) {
						f32m[i] = 1.0 - (u8[i] / 255);
					}

					var bytes_img = untyped imagetemp.getPixels().b.buffer;
					var u8 = new js.lib.Uint8Array(untyped bytes_img);
					var f32 = new js.lib.Float32Array(3 * 256 * 256);
					for (i in 0...(256 * 256)) {
						f32[i                ] = ((u8[i * 4    ] / 255) * 2.0 - 1.0) * (1.0 - f32m[i]);
						f32[i + 256 * 256    ] = ((u8[i * 4 + 1] / 255) * 2.0 - 1.0) * (1.0 - f32m[i]);
						f32[i + 256 * 256 * 2] = ((u8[i * 4 + 2] / 255) * 2.0 - 1.0) * (1.0 - f32m[i]);
					}

					var buf = Krom.mlInference(untyped model_blob.toBytes().b.buffer, [f32.buffer, f32m.buffer], Config.raw.gpu_inference);
					var ar = new js.lib.Float32Array(buf);
					var bytes = haxe.io.Bytes.alloc(4 * 256 * 256);
					for (i in 0...(256 * 256)) {
						var x = i % 256;
						var y = Std.int(i / 256);
						var m = f32m[i];
						var im = 1.0 - m;
						bytes.set(i * 4    , Std.int( ( ( ((ar[y * 256 + x                ] * m) * 1 + 0) + ((f32[y * 256 + x                ] * im) * 1 + 0) ) * 255) * 0.5 + 128 ) );
						bytes.set(i * 4 + 1, Std.int( ( ( ((ar[y * 256 + x + 256 * 256    ] * m) * 1 + 0) + ((f32[y * 256 + x + 256 * 256    ] * im) * 1 + 0) ) * 255) * 0.5 + 128 ) );
						bytes.set(i * 4 + 2, Std.int( ( ( ((ar[y * 256 + x + 256 * 256 * 2] * m) * 1 + 0) + ((f32[y * 256 + x + 256 * 256 * 2] * im) * 1 + 0) ) * 255) * 0.5 + 128 ) );

						bytes.set(i * 4 + 3, 255);
					}

					var temp = kha.Image.fromBytes(bytes, 256, 256);
					result.g2.begin(false);
					result.g2.drawImage(temp,  x * 256, y * 256);
					result.g2.end();
					temp.unload();
				}
			}
		});

		return result;
	}

	override public function getImage(): kha.Image {
		App.notifyOnNextFrame(function() {
			var source = inputs[0].get();
			if (Layers.pipeCopy == null) Layers.makePipe();
			if (iron.data.ConstData.screenAlignedVB == null) iron.data.ConstData.createScreenAlignedData();
			image.g4.begin();
			image.g4.setPipeline(Layers.pipeApplyMask);
			image.g4.setTexture(Layers.tex0Mask, source);
			image.g4.setTexture(Layers.texaMask, mask);
			image.g4.setVertexBuffer(iron.data.ConstData.screenAlignedVB);
			image.g4.setIndexBuffer(iron.data.ConstData.screenAlignedIB);
			image.g4.drawIndexedVertices();
			image.g4.end();
		});
		return image;
	}

	public function getTarget(): kha.Image {
		return mask;
	}
}
