
// Imported by armorcore/kincfile.js
module.exports = {
	set_flags: function(flags, platform, graphics) {
		flags.name = 'ArmorLab';
		flags.package = 'org.armorlab';
		flags.with_d3dcompiler = true;
		flags.with_nfd = true;
		flags.with_tinydir = true;
		flags.with_zlib = true;
		flags.with_stb_image_write = true;
		flags.with_krafix = graphics === 'vulkan'; // glsl to spirv for vulkan
		flags.with_plugin_embed = platform === 'ios';
		flags.with_texsynth = true;
		flags.with_onnx = true;
	}
};
