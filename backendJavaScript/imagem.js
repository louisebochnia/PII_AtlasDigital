
const fs = require('fs-extra');
const fsSync = require('fs');
const path = require('path');
const unzipper = require('unzipper');
const { spawn } = require('child_process');

class Imagem {
    constructor(arquivosDir = 'uploads') {
        this.arquivosDir = arquivosDir;
    }

    // =====================================================
    // DESCOMPACTAÇÃO DO ZIP
    // =====================================================

    async descompactarZip(zipPath, nomeImagem) {
        const nomeLimpo = this.sanitizeNome(nomeImagem);

        const pastaBase = path.join(
            'uploads',
            'images',
            nomeLimpo
        );

        await fs.ensureDir(pastaBase);

        await fsSync.createReadStream(zipPath)
            .pipe(unzipper.Extract({ path: pastaBase }))
            .promise();

        await fs.unlink(zipPath);

        return pastaBase;
    }

    // =====================================================
    // SANITIZAÇÃO DO NOME
    // =====================================================

    sanitizeNome(nome) {
        return nome
            .replace(
                /[^a-zA-Z0-9áéíóúÁÉÍÓÚãõñç\s_-]/g,
                ''
            )
            .replace(/\s+/g, '_');
    }

    // =====================================================
    // LISTAGEM RECURSIVA DOS ARQUIVOS
    // =====================================================

    async listarArquivosRecursivamente(
        diretorio,
        baseDir = diretorio,
        arquivoList = []
    ) {
        const itens = await fs.readdir(diretorio);

        for (const item of itens) {
            const caminhoCompleto = path.join(
                diretorio,
                item
            );

            const stat = await fs.stat(caminhoCompleto);

            if (stat.isDirectory()) {
                await this.listarArquivosRecursivamente(
                    caminhoCompleto,
                    baseDir,
                    arquivoList
                );
            } else {
                const caminhoRelativo = path.relative(
                    baseDir,
                    caminhoCompleto
                );

                arquivoList.push(caminhoRelativo);
            }
        }

        return arquivoList;
    }

    // =====================================================
    // PREPARAÇÃO DA ESTRUTURA MRXS
    // =====================================================

    async prepararPastaMrxs(destino, nomeImagem) {
        const arquivos = await this.listarArquivosRecursivamente(
            destino,
            destino
        );

        const mrxsFile = arquivos.find(
            f => f.toLowerCase().endsWith('.mrxs')
        );

        if (!mrxsFile) {
            throw new Error(
                'Nenhum arquivo .mrxs encontrado no ZIP'
            );
        }

        const mrxsPath = path.join(
            destino,
            mrxsFile
        );

        const mrxsDir = path.dirname(mrxsPath);

        const mrxsBaseName = path.basename(
            mrxsFile,
            path.extname(mrxsFile)
        );

        let pastaEncontrada = null;

        // Procura a pasta de arquivos complementares.
        const subpastas = await fs.readdir(
            mrxsDir,
            { withFileTypes: true }
        );

        for (const ent of subpastas) {
            if (!ent.isDirectory()) {
                continue;
            }

            const caminhoPasta = path.join(
                mrxsDir,
                ent.name
            );

            const arquivosPasta =
                await this.listarArquivosRecursivamente(
                    caminhoPasta,
                    caminhoPasta
                );

            const contemArquivosMRXS = arquivosPasta.some(
                arquivo => {
                    const nome = path.basename(
                        arquivo
                    ).toLowerCase();

                    return (
                        nome.endsWith('.dat') ||
                        nome === 'slidedat.ini' ||
                        nome === 'index.dat'
                    );
                }
            );

            if (contemArquivosMRXS) {
                pastaEncontrada = ent.name;
                break;
            }
        }

        const novaEstrutura =
            await this.organizarEstruturaMrxs(
                mrxsDir,
                mrxsBaseName,
                pastaEncontrada,
                nomeImagem
            );

        return {
            ...novaEstrutura,
            mrxsFile: `${mrxsBaseName}.mrxs`,
            mrxsPath: novaEstrutura.mrxsPath
        };
    }

    async organizarEstruturaMrxs(
        mrxsDir,
        mrxsBaseName,
        pastaEncontrada,
        nomeImagem
    ) {
        const nomeLimpo = this.sanitizeNome(nomeImagem);

        const pastaFinal = path.join(
            'uploads',
            'images',
            nomeLimpo
        );

        await fs.ensureDir(pastaFinal);

        const arquivoMrxsOrigem = path.join(
            mrxsDir,
            `${mrxsBaseName}.mrxs`
        );

        const arquivoMrxsDestino = path.join(
            pastaFinal,
            `${mrxsBaseName}.mrxs`
        );

        console.log(
            `Movendo MRXS: ${arquivoMrxsOrigem} -> ${arquivoMrxsDestino}`
        );

        if (await fs.pathExists(arquivoMrxsOrigem)) {
            await fs.move(
                arquivoMrxsOrigem,
                arquivoMrxsDestino,
                { overwrite: true }
            );
        } else {
            throw new Error(
                `Arquivo MRXS não encontrado: ${arquivoMrxsOrigem}`
            );
        }

        // Move a pasta complementar sem alterar
        // sua estrutura interna.
        if (pastaEncontrada) {
            const pastaFilesOrigem = path.join(
                mrxsDir,
                pastaEncontrada
            );

            const pastaFilesDestino = path.join(
                pastaFinal,
                mrxsBaseName
            );

            console.log(
                `Movendo pasta complementar: ${pastaFilesOrigem} -> ${pastaFilesDestino}`
            );

            if (await fs.pathExists(pastaFilesOrigem)) {
                await fs.move(
                    pastaFilesOrigem,
                    pastaFilesDestino,
                    { overwrite: true }
                );
            }
        }

        // Remove a pasta temporária somente se ela
        // estiver vazia, evitando apagar arquivos não movidos.
        if (
            path.resolve(mrxsDir) !== path.resolve(pastaFinal) &&
            await fs.pathExists(mrxsDir)
        ) {
            const restantes = await fs.readdir(mrxsDir);

            if (restantes.length === 0) {
                await fs.remove(mrxsDir);
            }
        }

        return {
            mrxsPath: arquivoMrxsDestino,
            mrxsDir: pastaFinal,
            enderecoPastaMrxs: pastaFinal,
            nomeArquivoMrxs: `${mrxsBaseName}.mrxs`
        };
    }

    executarPython(argumentos) {
        return new Promise((resolve, reject) => {
            const pythonProcess = spawn(
                'py',
                [
                    'python/gerar_tiles.py',
                    ...argumentos.map(String)
                ],
                {
                    cwd: process.cwd()
                }
            );

            let stdout = '';
            let stderr = '';

            pythonProcess.stdout.on('data', data => {
                const output = data.toString();

                stdout += output;

                console.log(
                    'Python STDOUT:',
                    output.trim()
                );
            });

            pythonProcess.stderr.on('data', data => {
                const error = data.toString();

                stderr += error;

                console.error(
                    'Python STDERR:',
                    error.trim()
                );
            });

            pythonProcess.on('error', error => {
                reject(
                    new Error(
                        `Falha ao executar Python: ${error.message}`
                    )
                );
            });

            pythonProcess.on('close', codigo => {
                console.log(
                    `Processo Python finalizado - Código: ${codigo}`
                );

                if (codigo !== 0) {
                    reject(
                        new Error(
                            `Python falhou com código ${codigo}.\n` +
                            `STDERR: ${stderr}\n` +
                            `STDOUT: ${stdout}`
                        )
                    );

                    return;
                }

                resolve({
                    stdout,
                    stderr
                });
            });
        });
    }

    async preGerarTilesPrincipais(mrxsFile, mrxsPath) {
        const tilesDir = path.join(
            'uploads',
            'tiles',
            path.parse(mrxsFile).name
        );

        await fs.ensureDir(tilesDir);

        const resultado = await this.executarPython([
            'pre',
            path.resolve(mrxsPath),
            path.resolve(tilesDir)
        ]);

        const linhaMetadados = resultado.stdout
            .split(/\r?\n/)
            .find(linha =>
                linha.startsWith('METADADOS:')
            );

        if (!linhaMetadados) {
            throw new Error(
                'O Python não retornou os metadados da lâmina.'
            );
        }

        console.log(
            'Metadados da lâmina gerados com sucesso.'
        );

        // Mantém o retorno original: diretório dos tiles.
        return tilesDir;
    }

    async gerarTile(
        mrxsPath,
        tilesDir,
        level,
        x,
        cleanY
    ) {
        console.log('Iniciando geração de tile:');

        console.log('MRXS:', mrxsPath);
        console.log('Tiles Dir:', tilesDir);
        console.log(
            `Level: ${level}, X: ${x}, Y: ${cleanY}`
        );

        if (!(await fs.pathExists(mrxsPath))) {
            throw new Error(
                `Arquivo MRXS não encontrado: ${mrxsPath}`
            );
        }

        // Os níveis reais do OpenSlide vão de 0 a 9
        // para a lâmina que foi testada.
        if (
            !Number.isInteger(Number(level)) ||
            Number(level) < 0 ||
            Number(level) > 9
        ) {
            throw new Error(
                `Nível inválido: ${level}. Utilize níveis de 0 a 9.`
            );
        }

        if (
            !Number.isInteger(Number(x)) ||
            !Number.isInteger(Number(cleanY)) ||
            Number(x) < 0 ||
            Number(cleanY) < 0
        ) {
            throw new Error(
                'As coordenadas X e Y devem ser inteiros não negativos.'
            );
        }

        const resultado = await this.executarPython([
            'tile',
            path.resolve(mrxsPath),
            path.resolve(tilesDir),
            Number(level),
            Number(x),
            Number(cleanY)
        ]);

        const linhaTile = resultado.stdout
            .split(/\r?\n/)
            .find(linha =>
                linha.startsWith('TILE_PATH:')
            );

        if (!linhaTile) {
            throw new Error(
                'Saída do Python não contém TILE_PATH.\n' +
                resultado.stdout
            );
        }

        const generatedPath = linhaTile
            .substring('TILE_PATH:'.length)
            .trim();

        // Converte o caminho absoluto para relativo,
        // facilitando o envio pela rota Express.
        const caminhoAbsoluto = path.resolve(
            generatedPath
        );

        const relativePath = path.relative(
            process.cwd(),
            caminhoAbsoluto
        );

        const caminhoFinal = relativePath
            .replace(/\\/g, '/');

        console.log(
            'Tile gerado:',
            caminhoFinal
        );

        return caminhoFinal;
    }
}

module.exports = Imagem;
