
import openslide
import sys

mrxs_path = sys.argv[1]

try:
    slide = openslide.OpenSlide(mrxs_path)

    print("\nMRXS carregado com sucesso!")
    print("Fabricante:", slide.properties.get(
        openslide.PROPERTY_NAME_VENDOR
    ))

    print("\nDimensões da imagem original:")
    print(slide.dimensions)

    print("\nQuantidade de níveis:", slide.level_count)

    print("\nDimensões por nível:")

    for i, dimensoes in enumerate(slide.level_dimensions):
        print(
            f"Nível {i}: {dimensoes[0]} x {dimensoes[1]} "
            f"| Downsample: {slide.level_downsamples[i]}"
        )

    slide.close()

except Exception as e:
    print("Erro ao abrir MRXS:", e)
