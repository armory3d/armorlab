package arm.util;

import kha.arrays.Uint32Array;
import iron.math.Vec4;

class MeshUtil {

	public static function calcNormals(smooth = false) {
		var va = new Vec4();
		var vb = new Vec4();
		var vc = new Vec4();
		var cb = new Vec4();
		var ab = new Vec4();
		var objects = Project.paintObjects;
		for (o in objects) {
			var g = o.data.geom;
			var l = g.structLength;
			var inda = g.indices[0];
			var vertices = g.vertexBuffer.lock(); // posnortex
			for (i in 0...Std.int(inda.length / 3)) {
				var i1 = inda[i * 3    ];
				var i2 = inda[i * 3 + 1];
				var i3 = inda[i * 3 + 2];
				va.set(vertices.getInt16((i1 * l) * 2), vertices.getInt16((i1 * l + 1) * 2), vertices.getInt16((i1 * l + 2) * 2));
				vb.set(vertices.getInt16((i2 * l) * 2), vertices.getInt16((i2 * l + 1) * 2), vertices.getInt16((i2 * l + 2) * 2));
				vc.set(vertices.getInt16((i3 * l) * 2), vertices.getInt16((i3 * l + 1) * 2), vertices.getInt16((i3 * l + 2) * 2));
				cb.subvecs(vc, vb);
				ab.subvecs(va, vb);
				cb.cross(ab);
				cb.normalize();
				vertices.setInt16((i1 * l + 4) * 2, Std.int(cb.x * 32767));
				vertices.setInt16((i1 * l + 5) * 2, Std.int(cb.y * 32767));
				vertices.setInt16((i1 * l + 3) * 2, Std.int(cb.z * 32767));
				vertices.setInt16((i2 * l + 4) * 2, Std.int(cb.x * 32767));
				vertices.setInt16((i2 * l + 5) * 2, Std.int(cb.y * 32767));
				vertices.setInt16((i2 * l + 3) * 2, Std.int(cb.z * 32767));
				vertices.setInt16((i3 * l + 4) * 2, Std.int(cb.x * 32767));
				vertices.setInt16((i3 * l + 5) * 2, Std.int(cb.y * 32767));
				vertices.setInt16((i3 * l + 3) * 2, Std.int(cb.z * 32767));
			}

			if (smooth) {
				var shared = new Uint32Array(1024);
				var sharedLen = 0;
				var found: Array<Int> = [];
				for (i in 0...(inda.length - 1)) {
					if (found.indexOf(i) >= 0) continue;
					var i1 = inda[i];
					sharedLen = 0;
					shared[sharedLen++] = i1;
					for (j in (i + 1)...inda.length) {
						var i2 = inda[j];
						var i1l = i1 * l;
						var i2l = i2 * l;
						if (vertices.getInt16((i1l    ) * 2) == vertices.getInt16((i2l    ) * 2) &&
							vertices.getInt16((i1l + 1) * 2) == vertices.getInt16((i2l + 1) * 2) &&
							vertices.getInt16((i1l + 2) * 2) == vertices.getInt16((i2l + 2) * 2)) {
							// if (n1.dot(n2) > 0)
							shared[sharedLen++] = i2;
							found.push(j);
							if (sharedLen >= 1024) break;
						}
					}
					if (sharedLen > 1) {
						va.set(0, 0, 0);
						for (j in 0...sharedLen) {
							var i1 = shared[j];
							var i1l = i1 * l;
							va.addf(vertices.getInt16((i1l + 4) * 2), vertices.getInt16((i1l + 5) * 2), vertices.getInt16((i1l + 3) * 2));
						}
						va.mult(1 / sharedLen);
						va.normalize();
						var vax = Std.int(va.x * 32767);
						var vay = Std.int(va.y * 32767);
						var vaz = Std.int(va.z * 32767);
						for (j in 0...sharedLen) {
							var i1 = shared[j];
							var i1l = i1 * l;
							vertices.setInt16((i1l + 4) * 2, vax);
							vertices.setInt16((i1l + 5) * 2, vay);
							vertices.setInt16((i1l + 3) * 2, vaz);
						}
					}
				}
			}
			g.vertexBuffer.unlock();

			var va0 = o.data.raw.vertex_arrays[0].values;
			var va1 = o.data.raw.vertex_arrays[1].values;
			for (i in 0...Std.int(vertices.byteLength / 4 / l)) {
				va1[i * 2    ] = vertices.getInt16((i * l + 4) * 2);
				va1[i * 2 + 1] = vertices.getInt16((i * l + 5) * 2);
				va0[i * 4 + 3] = vertices.getInt16((i * l + 3) * 2);
			}
		}

		#if (kha_direct3d12 || kha_vulkan)
		mergeMesh();
		arm.render.RenderPathRaytrace.ready = false;
		#end
	}

	public static function applyDisplacement() {
		var texpaint_pack = arm.node.brush.BrushOutputNode.inst.texpaint_pack;
		var height = texpaint_pack.getPixels();
		var res = texpaint_pack.width;
		var strength = 0.1;
		var o = Project.paintObjects[0];
		var g = o.data.geom;
		var l = g.structLength;
		var vertices = g.vertexBuffer.lock(); // posnortex
		for (i in 0...Std.int(vertices.byteLength / 2 / l)) {
			var x = Std.int(vertices.getInt16((i * l + 6) * 2) / 32767 * res);
			var y = Std.int(vertices.getInt16((i * l + 7) * 2) / 32767 * res);
			var h = (1.0 - height.get((y * res + x) * 4 + 3) / 255) * strength;
			vertices.setInt16((i * l    ) * 2, vertices.getInt16((i * l    ) * 2) - Std.int(vertices.getInt16((i * l + 4) * 2) * h));
			vertices.setInt16((i * l + 1) * 2, vertices.getInt16((i * l + 1) * 2) - Std.int(vertices.getInt16((i * l + 5) * 2) * h));
			vertices.setInt16((i * l + 2) * 2, vertices.getInt16((i * l + 2) * 2) - Std.int(vertices.getInt16((i * l + 3) * 2) * h));
		}
		g.vertexBuffer.unlock();

		var va0 = o.data.raw.vertex_arrays[0].values;
		var va1 = o.data.raw.vertex_arrays[1].values;
		for (i in 0...Std.int(vertices.byteLength / 4 / l)) {
			va0[i * 4    ] = vertices.getInt16((i * l    ) * 2);
			va0[i * 4 + 1] = vertices.getInt16((i * l + 1) * 2);
			va0[i * 4 + 2] = vertices.getInt16((i * l + 2) * 2);
		}
	}

	public static function mergeMesh() {} ////
}
