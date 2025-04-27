import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import express from 'express';

const app = express();
const PORT = 3000;
const HOST = '192.168.0.101';

// Simulate __dirname in ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Serve static files from the "pdfs" directory
app.use('/files', express.static(join(__dirname, 'pdfs')));

// Serve a ZIP file containing PDFs for a chapter
app.get('/chapter/:chapterName', (req, res) => {
    const chapterName = req.params.chapterName;
    const filePath = join(__dirname, 'pdfs', `${chapterName}.zip`);
    res.sendFile(filePath, (err) => {
        if (err) {
            res.status(404).send('Chapter ZIP not found');
        }
    });
});

app.listen(PORT, HOST, () => {
    console.log(`Server is running on http://${HOST}:${PORT}`);
    console.log(`Static files are served at http://${HOST}:${PORT}/files`);
});
