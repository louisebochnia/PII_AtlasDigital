const fs = require('fs').promises;
const path = require('path');
const { execFile } = require('child_process');
const { promisify } = require('util');
const execFileAsync = promisify(execFile);

class ImagemThumbnail {
  constructor(thumbnailsDir = 'uploads/thumbnails') {
    this.thumbnailsDir = thumbnailsDir;
  }

  async criarAPartirDeMRXS(mrxsPath, outputFilename) {
    try {
      if (!outputFilename) {
        const mrxsName = path.basename(mrxsPath, '.mrxs');
        outputFilename = `${mrxsName}.jpg`;
      }

      const thumbnailPath = path.join(this.thumbnailsDir, outputFilename);

      await fs.mkdir(this.thumbnailsDir, { recursive: true });

      try {
        await this.converterParaJpeg(mrxsPath, thumbnailPath);
        return thumbnailPath;
      } catch (erro) {
        console.error('Erro ao converter MRXS → JPEG:', erro.message);
        return null;
      }
    } catch (erro) {
      console.error('Erro em criarAPartirDeMRXS:', erro);
      throw erro;
    }
  }

  async converterParaJpeg(mrxsPath, outputPath) {
    
    const pythonScriptPath = `python/converter_mrxs.py`

      try {
          const { stdout, stderr } = await execFileAsync(
            'python',
            [pythonScriptPath, path.resolve(mrxsPath), path.resolve(outputPath)],
            {
              timeout: 30000,
              windowsHide: true,
            }
          );

          console.log("Python stdout:", stdout);
          if (stderr) console.error("Python stderr:", stderr);
      } catch (error) {
          console.error("Falha na execução do script Python:");
          if (error.stdout) console.log("stdout:", error.stdout);
          if (error.stderr) console.error("stderr:", error.stderr);
          throw error;
      }
    }
}

module.exports = ImagemThumbnail;