const fs = require('fs-extra');
const fsSync = require('fs');
const path = require('path');
const unzipper = require('unzipper');
const { exec } = require('child_process');
const { spawn } = require('child_process');

class Imagem {
    constructor(arquivosDir = 'uploads') {
        this.arquivosDir = arquivosDir;
    }

    async descompactarZip(zipPath, nomeImagem) {
        const nomeLimpo = this.sanitizeNome(nomeImagem);
        const pastaBase = path.join('uploads', 'images', nomeLimpo);
        await fs.ensureDir(pastaBase);

        await fsSync.createReadStream(zipPath)
            .pipe(unzipper.Extract({ path: pastaBase }))
            .promise();

        await fs.unlink(zipPath);

        return pastaBase
    }

    sanitizeNome(nome) {
        return nome.replace(/[^a-zA-Z0-9áéíóúÁÉÍÓÚãõñç\s_-]/g, '').replace(/\s+/g, '_');
    }

    async listarArquivosRecursivamente(diretorio, baseDir = diretorio, arquivoList = []) {
        const itens = await fs.readdir(diretorio);

        for (const item of itens) {
            const caminhoCompleto = path.join(diretorio, item);
            const stat = await fs.stat(caminhoCompleto);

            if (stat.isDirectory()) {
                await this.listarArquivosRecursivamente(caminhoCompleto, baseDir, arquivoList);
            } else {
                const caminhoRelativo = path.relative(baseDir, caminhoCompleto);
                arquivoList.push(caminhoRelativo);
            }
        }

        return arquivoList;
    }

    async prepararPastaMrxs(destino, nomeImagem) {
        const arquivos = await this.listarArquivosRecursivamente(destino, destino);
        
        const mrxsFile = arquivos.find(f => f.endsWith('.mrxs'));
        if (!mrxsFile) {
            throw new Error('Nenhum arquivo .mrxs encontrado no ZIP');
        }
        
        const mrxsPath = path.join(destino, mrxsFile);
        const mrxsDir = path.dirname(mrxsPath);
        const mrxsBaseName = path.basename(mrxsFile, '.mrxs');

        let pastaEncontrada = null;
        if (mrxsDir !== destino) {
            const subpastas = await fs.readdir(mrxsDir, { withFileTypes: true });
            for (const ent of subpastas) {
                if (ent.isDirectory()) {
                    const conteudo = await fs.readdir(path.join(mrxsDir, ent.name));
                    const contemArquivosMRXS = conteudo.some(f =>
                        f.toLowerCase().endsWith('.dat') || f.toLowerCase() === 'slidesdat.ini'
                    );
                    if (contemArquivosMRXS) {
                        pastaEncontrada = ent.name;
                        break;
                    }
                }
            }
        }
        const novaEstrutura = await this.organizarEstruturaMrxs(mrxsDir, mrxsBaseName, pastaEncontrada, nomeImagem);

        return {
            ...novaEstrutura,
            mrxsFile: `${mrxsBaseName}.mrxs`,
            mrxsPath: novaEstrutura.mrxsPath
        };
    }

        async organizarEstruturaMrxs(mrxsDir, mrxsBaseName, pastaEncontrada, nomeImagem) {
        const nomeLimpo = this.sanitizeNome(nomeImagem)
        
        const pastaAtual = path.dirname(mrxsDir);
        const pastaFinal = path.join('uploads', 'images', nomeLimpo);
        await fs.ensureDir(pastaFinal);

        const arquivoMrxsOrigem = path.join(mrxsDir, `${mrxsBaseName}.mrxs`);
        const arquivoMrxsDestino = path.join(pastaFinal, `${mrxsBaseName}.mrxs`);         
        console.log(`Movendo MRXS: ${arquivoMrxsOrigem} -> ${arquivoMrxsDestino}`);
        
        if (await fs.pathExists(arquivoMrxsOrigem)) {
            await fs.move(arquivoMrxsOrigem, arquivoMrxsDestino, { overwrite: true });
        }

        if (pastaEncontrada) {
            const pastaFilesOrigem = path.join(mrxsDir, pastaEncontrada);
            const pastaFilesDestino = path.join(pastaFinal, `${mrxsBaseName}.mrxs.files`); 
            
            console.log(`Movendo pasta files: ${pastaFilesOrigem} -> ${pastaFilesDestino}`);
            
            if (await fs.pathExists(pastaFilesOrigem)) {
                await fs.move(pastaFilesOrigem, pastaFilesDestino, { overwrite: true });
            }
        }

        // Remove o diretório original se for diferente do final
        if (mrxsDir !== pastaFinal && await fs.pathExists(mrxsDir)) {
            await fs.remove(mrxsDir);
        }

        return {
            mrxsPath: arquivoMrxsDestino, // Caminho para o arquivo .mrxs
            mrxsDir: pastaFinal, // Pasta onde está o arquivo
            enderecoPastaMrxs: pastaFinal, // Pasta da imagem
            nomeArquivoMrxs: `${mrxsBaseName}.mrxs` // Nome do arquivo .mrxs
        };
    }

    async preGerarTilesPrincipais(mrxsFile, mrxsPath) {
        const tilesDir = path.join("uploads", "tiles", path.parse(mrxsFile).name);
        await fs.mkdir(tilesDir, { recursive: true });

        const python = `python python/gerar_tiles.py pre "${mrxsPath}" "${tilesDir}"`;

        await new Promise((resolve, reject) => {
            exec(python, (err, stdout, stderr) => {
                if (err) return reject(stderr);
                resolve();
            });
        });

        return tilesDir;
    }

   async gerarTile(mrxsPath, tilesDir, level, x, cleanY){
        console.log('Iniciando geracao de tile:');
        console.log('   MRXS: ' + mrxsPath);
        console.log('   Tiles Dir: ' + tilesDir);
        console.log('   Level: ' + level + ', X: ' + x + ', Y: ' + cleanY);
        
        if (!fs.existsSync(mrxsPath)) {
            console.log('MRXS nao existe: ' + mrxsPath);
            throw new Error('Arquivo MRXS nao encontrado: ' + mrxsPath);
        }

        return new Promise((resolve, reject) => {
            const pythonProcess = spawn('python', [
                'python/gerar_tiles.py',
                'tile',
                mrxsPath,
                tilesDir,
                level.toString(),
                x.toString(),
                cleanY.toString()
            ], {
                cwd: process.cwd()
            });
            
            let stdout = '';
            let stderr = '';

            pythonProcess.stdout.on('data', (data) => {
                const output = data.toString();
                stdout += output;
                console.log('Python STDOUT: ' + output.trim());
            });
            
            pythonProcess.stderr.on('data', (data) => {
                const error = data.toString();
                stderr += error;
                console.log('Python STDERR: ' + error.trim());
            });
            
            pythonProcess.on('close', (code) => {
                console.log('Processo Python finalizado - Codigo: ' + code);
                console.log('STDOUT completo: ' + stdout);
                console.log('STDERR completo: ' + stderr);
                
                if (code !== 0) {
                    reject(new Error('Python falhou com codigo ' + code + '. STDERR: ' + stderr));
                    return;
                }

                if (stdout.includes('TILE_PATH:')) {
                    const generatedPath = stdout.split('TILE_PATH:')[1].trim();
                    console.log('Tile path extraido: ' + generatedPath);
                    
                    // ✅ CORREÇÃO: Converte caminho absoluto para relativo
                    const baseDir = process.cwd();
                    let relativePath = generatedPath;
                    
                    if (generatedPath.startsWith(baseDir)) {
                        relativePath = path.relative(baseDir, generatedPath);
                        console.log('Caminho convertido para relativo: ' + relativePath);
                    }
                    
                    // ✅ CORREÇÃO: Usa caminhos com / em vez de \
                    relativePath = relativePath.replace(/\\/g, '/');
                    console.log('Caminho final: ' + relativePath);
                    
                    resolve(relativePath);
                } else {
                    reject(new Error('Saida nao contem TILE_PATH. STDOUT: ' + stdout));
                }
            });
            
            pythonProcess.on('error', (error) => {
                console.log('Erro no processo: ' + error);
                reject(new Error('Falha ao executar Python: ' + error.message));
            });
        });
    }
}

module.exports = Imagem;