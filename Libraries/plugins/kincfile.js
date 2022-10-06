let project = new Project('plugins');

project.addExclude('.git/**');
project.addExclude('build/**');
project.addFile('Sources/**');

project.addDefine('WITH_PLUGIN_EMBED');

if (platform === Platform.Windows) {
	project.addLib('Sources/proc_texsynth/win32/texsynth');
}
else if (platform === Platform.Linux) {
	project.addLib('texsynth -L../../Sources/proc_texsynth/linux');
}
else if (platform === Platform.OSX) {
	project.addLib('Sources/proc_texsynth/macos/libtexsynth.a');
}

resolve(project);
