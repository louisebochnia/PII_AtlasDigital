
import os
import sys
import json
import math
import traceback
import openslide
from PIL import Image

TILE_SIZE = 256


def resolver_caminho(caminho):
    """Converte caminhos relativos em caminhos absolutos."""
    if os.path.isabs(caminho):
        return caminho

    return os.path.abspath(caminho)


def carregar_mrxs(caminho):
    """Abre a lâmina usando OpenSlide."""
    caminho = resolver_caminho(caminho)

    if not os.path.isfile(caminho):
        raise FileNotFoundError(
            f"Arquivo MRXS não encontrado: {caminho}"
        )

    slide = openslide.OpenSlide(caminho)

    print(
        f"MRXS carregado: "
        f"{slide.dimensions[0]}x{slide.dimensions[1]}"
    )

    return slide


def gerar_metadados(slide, output_dir):
    """Gera metadados usando os níveis reais do MRXS."""

    os.makedirs(output_dir, exist_ok=True)

    levels = {}

    for nivel, dimensoes in enumerate(slide.level_dimensions):
        largura, altura = dimensoes

        levels[str(nivel)] = {
            "width": largura,
            "height": altura,
            "tiles_x": math.ceil(largura / TILE_SIZE),
            "tiles_y": math.ceil(altura / TILE_SIZE),
            "downsample": slide.level_downsamples[nivel]
        }

    metas = {
        "width": slide.dimensions[0],
        "height": slide.dimensions[1],
        "levels": slide.level_count,
        "tile_size": TILE_SIZE,
        "level_metas": levels
    }

    meta_path = os.path.join(output_dir, "meta.json")

    with open(meta_path, "w", encoding="utf-8") as arquivo:
        json.dump(metas, arquivo, indent=4, ensure_ascii=False)

    print("METADADOS:" + json.dumps(metas))

    return metas


def gerar_tile_sob_demanda(
    slide,
    nivel,
    tx,
    ty,
    output_dir
):
    """Gera somente o tile solicitado."""

    if nivel < 0 or nivel >= slide.level_count:
        raise ValueError(f"Nível inválido: {nivel}")

    if tx < 0 or ty < 0:
        raise ValueError("Coordenadas de tile não podem ser negativas.")

    largura, altura = slide.level_dimensions[nivel]

    x = tx * TILE_SIZE
    y = ty * TILE_SIZE

    if x >= largura or y >= altura:
        raise ValueError("Tile fora dos limites da imagem.")

    w = min(TILE_SIZE, largura - x)
    h = min(TILE_SIZE, altura - y)

    downsample = slide.level_downsamples[nivel]

    # read_region recebe a posição em coordenadas do nível 0.
    x_original = round(x * downsample)
    y_original = round(y * downsample)

    tile = slide.read_region(
        (x_original, y_original),
        nivel,
        (w, h)
    )

    # Converte RGBA para RGB com fundo branco.
    fundo = Image.new("RGBA", tile.size, "white")
    fundo.alpha_composite(tile)
    tile = fundo.convert("RGB")

    # Completa tiles das bordas para 256x256.
    if w < TILE_SIZE or h < TILE_SIZE:
        tile_final = Image.new(
            "RGB",
            (TILE_SIZE, TILE_SIZE),
            "white"
        )

        tile_final.paste(tile, (0, 0))
        tile = tile_final

    level_dir = os.path.join(
        output_dir,
        f"level_{nivel}"
    )

    os.makedirs(level_dir, exist_ok=True)

    tile_path = os.path.join(
        level_dir,
        f"{tx}_{ty}.jpg"
    )

    tile.save(
        tile_path,
        format="JPEG",
        quality=95,
        optimize=True
    )

    return tile_path


def main():
    if len(sys.argv) < 4:
        raise ValueError(
            "Uso: gerar_tiles.py [pre|tile] MRXS OUTPUT_DIR"
        )

    comando = sys.argv[1]
    mrxs_path = sys.argv[2]
    output_dir = resolver_caminho(sys.argv[3])

    slide = None

    try:
        slide = carregar_mrxs(mrxs_path)

        if comando == "pre":
            # Não gera toda a pirâmide antecipadamente.
            # Apenas registra dimensões e níveis disponíveis.
            gerar_metadados(slide, output_dir)

        elif comando == "tile":
            if len(sys.argv) < 7:
                raise ValueError(
                    "Uso: gerar_tiles.py tile MRXS OUTPUT_DIR LEVEL X Y"
                )

            nivel = int(sys.argv[4])
            tx = int(sys.argv[5])
            ty = int(sys.argv[6])

            tile_path = gerar_tile_sob_demanda(
                slide,
                nivel,
                tx,
                ty,
                output_dir
            )

            print(f"TILE_PATH:{tile_path}")

        else:
            raise ValueError(f"Comando inválido: {comando}")

    except Exception as erro:
        print(f"ERRO: {erro}", file=sys.stderr)
        traceback.print_exc()
        sys.exit(1)

    finally:
        if slide is not None:
            slide.close()


if __name__ == "__main__":
    main()
