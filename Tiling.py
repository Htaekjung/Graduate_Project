import numpy as np
import os

# ====== 설정 ======
input_txt = "result.txt"     # 원본 이미지 txt
output_dir = "result"        # 타일 txt 저장 폴더
tile_size = 16
img_width, img_height = 640, 480

# ====== 1. 폴더 생성 ======
os.makedirs(output_dir, exist_ok=True)

# ====== 2. txt 파일 읽기 ======
with open(input_txt, 'r') as f:
    raw_data = f.read().split()

# 16진수 → 10진수 uint8 배열
data = np.array([int(x, 16) for x in raw_data], dtype=np.uint8)
img = data.reshape((img_height, img_width))

# ====== 3. 타일링 후 개별 txt 저장 ======
tile_index = 0
for ty in range(0, img_height, tile_size):
    for tx in range(0, img_width, tile_size):
        tile = img[ty:ty+tile_size, tx:tx+tile_size]
        tile_hex = [f"{val:02X}" for val in tile.flatten()]

        tile_filename = os.path.join(output_dir, f"tile_{tile_index:04d}.txt")
        with open(tile_filename, 'w') as f:
            for i in range(0, len(tile_hex), 16):  # 한 줄에 16개
                f.write(" ".join(tile_hex[i:i+16]) + "\n")

        tile_index += 1

print(f"✅ 총 {tile_index}개의 타일 txt 파일 생성 완료: '{output_dir}' 폴더")
