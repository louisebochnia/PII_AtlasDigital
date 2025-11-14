const fs = require('fs-extra');
const fsSync = require('fs');
const path = require('path');
const unzipper = require('unzipper');
const { exec } = require('child_process');

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
    const mrxsBaseName = path.basename(mrxsFile);
    const nomeBaseSemExtensao = path.parse(mrxsBaseName).name;

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

    const novaEstrutura = await this.organizarEstruturaMrxs(mrxsDir, nomeBaseSemExtensao, pastaEncontrada, nomeImagem);

    return {
        ...novaEstrutura,
        mrxsFile: mrxsBaseName,
        mrxsPath: novaEstrutura.mrxsPath
    };
}

    async organizarEstruturaMrxs(mrxsDir, mrxsBaseName, pastaEncontrada, nomeImagem) {
        const nomeLimpo = this.sanitizeNome(nomeImagem)
        
        const pastaAtual = path.dirname(mrxsDir);
        const pastaFinal = path.join('uploads', 'images', nomeLimpo);
        await fs.ensureDir(pastaFinal);

        if(pastaAtual === pastaFinal){
            const arquivoMrxsOrigem = path.join(mrxsDir, `${mrxsBaseName}.mrxs`);
            const arquivoMrxsDestino = path.join(pastaFinal, `${nomeLimpo}.mrxs`);
            
            if (await fs.pathExists(arquivoMrxsOrigem)) {
                await fs.move(arquivoMrxsOrigem, arquivoMrxsDestino, { overwrite: true });
            }

            if (pastaEncontrada) {
                const pastaFilesOrigem = path.join(mrxsDir, pastaEncontrada);
                const pastaFilesDestino = path.join(pastaFinal, `${nomeLimpo}.mrxs.files`);
                
                if (await fs.pathExists(pastaFilesOrigem)) {
                    await fs.move(pastaFilesOrigem, pastaFilesDestino, { overwrite: true });
                }
            }

            if (mrxsDir !== pastaFinal) {
                await fs.remove(mrxsDir);
            }

            return {
                mrxsPath: arquivoMrxsDestino,
                mrxsDir: pastaFinal,
                enderecoPastaMrxs: pastaFinal 
            };
        }

        await fs.ensureDir(pastaFinal);

        const arquivoMrxsOrigem = path.join(mrxsDir, `${mrxsBaseName}.mrxs`);
        const arquivoMrxsDestino = path.join(pastaFinal, `${nomeLimpo}.mrxs`);
        
        if (await fs.pathExists(arquivoMrxsOrigem)) {
            await fs.move(arquivoMrxsOrigem, arquivoMrxsDestino, { overwrite: true });
        }

        if (pastaEncontrada) {
            const pastaFilesOrigem = path.join(mrxsDir, pastaEncontrada);
            const pastaFilesDestino = path.join(pastaFinal, `${nomeLimpo}.mrxs.files`);
            
            if (await fs.pathExists(pastaFilesOrigem)) {
                await fs.move(pastaFilesOrigem, pastaFilesDestino, { overwrite: true });
            }
        }

        await fs.remove(mrxsDir);

        return {
            mrxsPath: arquivoMrxsDestino,
            mrxsDir: pastaFinal,
            enderecoPastaMrxs: pastaFinal 
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
}

module.exports = Imagem;