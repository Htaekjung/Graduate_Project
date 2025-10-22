import numpy as np
import matplotlib.pyplot as plt

# ====== 설정 ======
input_txt = 'trump_original.txt'    # 입력 파일 이름
img_width, img_height = 640, 480
tile_size = 16

# ====== Scharr 커널 ======
kernel_x = np.array([
    [-3, 0, 3],
    [-10, 0, 10],
    [-3, 0, 3]
], dtype=np.int32)

kernel_y = np.array([
    [-3, -10, -3],
    [ 0,   0,  0],
    [ 3,  10,  3]
], dtype=np.int32)

# ====== 데이터 불러오기 ======
with open(input_txt, 'r') as f:
    raw_data = f.read().split()

# 16진수 → 10진수 변환
data = np.array([int(x, 16) for x in raw_data], dtype=np.uint8)

# 1차원 → 2차원 이미지
img = data.reshape((img_height, img_width))

# ====== 결과 저장용 배열 ======
edge_img = np.zeros_like(img, dtype=np.uint8)

# ====== 타일 단위 Scharr 필터 적용 (제로패딩 추가) ======
for ty in range(0, img_height, tile_size):
    for tx in range(0, img_width, tile_size):
        tile = img[ty:ty+tile_size, tx:tx+tile_size]

        # --- 제로패딩 추가 (상하좌우 1픽셀) ---
        padded_tile = np.pad(tile, pad_width=1, mode='constant', constant_values=0)

        tile_edge = np.zeros_like(tile, dtype=np.uint8)

        # --- 패딩을 포함한 내부 영역 연산 ---
        for y in range(1, padded_tile.shape[0]-1):
            for x in range(1, padded_tile.shape[1]-1):
                region = padded_tile[y-1:y+2, x-1:x+2]
                gx = np.sum(region * kernel_x)
                gy = np.sum(region * kernel_y)
                val = np.sqrt(gx**2 + gy**2)
                tile_edge[y-1, x-1] = np.uint8(np.clip(val, 0, 255))

        edge_img[ty:ty+tile.shape[0], tx:tx+tile.shape[1]] = tile_edge

print("✅ Scharr edge detection 완료 (제로패딩 적용)")

# ====== 결과 표시 ======
plt.figure(figsize=(8, 6))
plt.imshow(edge_img, cmap='gray', vmin=0, vmax=255)
plt.title("Scharr Edge Detection (Zero Padding, 16x16 Tiles)")
plt.axis('off')
plt.show()

# ====== 결과 저장 ======
plt.imsave("scharr_edge_zero_padding.png", edge_img, cmap='gray', vmin=0, vmax=255)
print("💾 'scharr_edge_zero_padding.png' 파일로 저장 완료")
