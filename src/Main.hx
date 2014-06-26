import sys.*;
import sys.db.*;
import sys.io.*;
import haxe.rtti.CType;
using Lambda;
using StringTools;

class Main {
	public var htmlDoc:String;
	public var xmlDoc:String;
	public var name:String;
	public var out:String;
	public var icon:String;

	@:isVar public var id(get, set):String;
	function get_id() return id != null ? id : id = nameToIdent(name);
	function set_id(v) return id = v;

	public function getDocsetPath():String {
		return '${out}/${name}.docset';
	}

	public function new():Void {

	}

	function createDocsetFolder():Void {
		FileSystem.createDirectory('${getDocsetPath()}/Contents/Resources/Documents/');
	}

	function copyHTMLDoc():Void {
		Sys.command("cp", ["-r", htmlDoc + "/*", '${getDocsetPath()}/Contents/Resources/Documents/']);
	}

	function createInfoPlist():Void {
		var content =
'<!DOCTYPE plist SYSTEM "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>CFBundleIdentifier</key>
<string>${id}</string>
<key>CFBundleName</key>
<string>${name}</string>
<key>DocSetPlatformFamily</key>
<string>${name}</string>
<key>isDashDocset</key>
<true/>
<key>dashIndexFilePath</key>
<string>index.html</string>
<key>isJavaScriptEnabled</key>
<true/>
</dict>
</plist>';
		File.saveContent('${getDocsetPath()}/Contents/Info.plist',content);
	}

	function copyIcon():Void {
		Sys.command("cp", [icon, '${getDocsetPath()}/icon.png']);
	}

	function createSQLite():Void {
		var db = Sqlite.open('${getDocsetPath()}/Contents/Resources/docSet.dsidx');
		db.request("CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);");
		db.request("CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);");

		var parser = new haxe.rtti.XmlParser();

		function transformPackage(x:Xml, p1:String, p2:String):Void {
			switch( x.nodeType ) {
				case Xml.Element:
					var p = x.get("path");
					if(p != null && p.startsWith(p1 + "."))
						x.set("path", p2 + "." + p.substr(p1.length+1));
					for(x in x.elements())
						transformPackage(x,p1,p2);
				default:
			}
		}

		function parseFile(path) {
			var name = new haxe.io.Path(path).file;
			Sys.println('Parsing $path');
			var data = File.getContent(path);
			var xml = try Xml.parse(data).firstElement() catch(err:Dynamic) {
				trace('Error while parsing $path');
				throw err;
			};
			if (name == "flash8") transformPackage(xml, "flash", "flash8");
			parser.process(xml, name);
		}
		
		if (FileSystem.isDirectory(xmlDoc)) {
			for (file in FileSystem.readDirectory(xmlDoc)) {
				if (!file.endsWith(".xml")) continue;
				parseFile('${xmlDoc}/${file}');
			}
		} else {
			parseFile(xmlDoc);
		}

		function processTree(t:TypeTree):Void {
			switch (t) {
				case TPackage(name, full, subs):
					var path = fullToPath(full == '' ? 'index' : full + '.index');
					if (FileSystem.exists(htmlDoc + "/" + path)) {
						db.request('INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (${db.quote(full)}, "Package", ${db.quote(path)});');
					}
					subs.iter(processTree);
				case TClassdecl(t):
					var path = fullToPath(t.path);
					var name = nameFromFull(t.path);
					var type = t.isInterface ? "Interface" : "Class";
					if (FileSystem.exists(htmlDoc + "/" + path)) {
						db.request('INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (${db.quote(name)}, "$type", ${db.quote(path)});');
					}
				case TEnumdecl(t):
					var path = fullToPath(t.path);
					var name = nameFromFull(t.path);
					if (FileSystem.exists(htmlDoc + "/" + path)) {
						db.request('INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (${db.quote(name)}, "Enum", ${db.quote(path)});');

						for (c in t.constructors) {
							var name = c.name;
							db.request('INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (${db.quote(name)}, "Constructor", ${db.quote(path)});');
						}
					}
				case TTypedecl(t):
					var path = fullToPath(t.path);
					var name = nameFromFull(t.path);
					if (FileSystem.exists(htmlDoc + "/" + path)) {
						db.request('INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (${db.quote(name)}, "Type", ${db.quote(path)});');
					}
				case TAbstractdecl(t):
					var path = fullToPath(t.path);
					var name = nameFromFull(t.path);
					if (FileSystem.exists(htmlDoc + "/" + path)) {
						db.request('INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (${db.quote(name)}, "Type", ${db.quote(path)});');
					}
			}
		}

		parser.root.iter(processTree);
		//db.request('INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (${db.quote(name)}, ${db.quote(type)}, ${db.quote(path)};');
	}

	function run():Void {
		createDocsetFolder();
		copyHTMLDoc();
		createInfoPlist();
		copyIcon();
		createSQLite();
	}

	function nameToIdent(name:String):String {
		return ~/[^A-Za-z0-9\-_]+/g.replace(name.toLowerCase(), "");
	}

	function fullToPath(full:String):String {
		return full.replace(".", "/").replace("<", "_").replace(">", "_") + '.html';
	}

	function nameFromFull(full:String):String {
		return full.substring(full.lastIndexOf(".") + 1);
	}

	static function main():Void {
		var main = new Main();
		var clean = false;
		var argHandler = hxargs.Args.generate([
			"-name" => function(name:String) {
				main.name = name;
			},
			"-id" => function(id:String) {
				main.id = id;
			},
			"-html-doc" => function(doc:String) {
				main.htmlDoc = doc;
			},
			"-xml-doc" => function(doc:String) {
				main.xmlDoc = doc;
			},
			"-icon" => function(icon:String) {
				main.icon = icon;
			},
			"-out" => function(out:String) {
				main.out = out;
			},
			"-clean" => function() {
				clean = true;
			}
		]);
		argHandler.parse(Sys.args());

		if (clean) {
			if (FileSystem.exists(main.getDocsetPath())) {
				Sys.command("rm", ["-r", main.getDocsetPath()]);
				// FileSystem.deleteDirectory(main.getDocsetPath());
			}
		}

		main.run();
	}
}