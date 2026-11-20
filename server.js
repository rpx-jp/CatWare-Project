const http = require("http");
const fs = require("fs");
const path = require("path");

const HOST = "127.0.0.1";
const PORT = 3000;
const ROOT = path.resolve(__dirname);
const SRC_DIR = path.join(ROOT, "src") + path.sep;

const MIME = {
	".lua": "text/plain; charset=utf-8",
	".luau": "text/plain; charset=utf-8",
	".json": "application/json; charset=utf-8",
	".png": "image/png",
	".jpg": "image/jpeg",
	".txt": "text/plain; charset=utf-8",
};

const server = http.createServer((req, res) => {
	const cleanUrl = decodeURIComponent((req.url || "/").split("?")[0]);

	if (cleanUrl === "/ping") {
		res.writeHead(200, { "Content-Type": "text/plain" });
		return res.end("CatWare Server OK");
	}

	const relPath = cleanUrl.replace(/^\/+/, "");
	const filePath = path.resolve(ROOT, relPath);

	// srcフォルダ外へのアクセスをブロック
	if (!filePath.startsWith(SRC_DIR)) {
		res.writeHead(403, { "Content-Type": "text/plain" });
		console.log(`[403] ${cleanUrl}`);
		return res.end("Forbidden");
	}

	fs.readFile(filePath, (err, data) => {
		if (err) {
			res.writeHead(404, { "Content-Type": "text/plain" });
			console.log(`[404] ${cleanUrl}`);
			return res.end("Not Found");
		}

		const ext = path.extname(filePath).toLowerCase();
		res.writeHead(200, {
			"Content-Type": MIME[ext] || "application/octet-stream",
			"Cache-Control": "no-store, no-cache, must-revalidate",
		});
		console.log(`[200] ${cleanUrl}`);
		res.end(data);
	});
});

server.listen(PORT, HOST, () => {
	console.log(`[CatWare Server] 起動しました！`);
	console.log(`URL: http://${HOST}:${PORT}/src/loader.lua`);
});