import numpy as np
import matplotlib.pyplot as plt

# 파라미터
IMG_W, IMG_H = 640, 480
TILE_SIZE = 16
TILE_W, TILE_H = IMG_W // TILE_SIZE, IMG_H // TILE_SIZE  # 40, 30
INPUT_FILE = "result.txt"
OUTPUT_FILE = "result.png"

# txt 파일 읽기
try:
    with open(INPUT_FILE, "r") as f:
        hex_values = f.read().split()
except FileNotFoundError:
    print(f"오류: 입력 파일 '{INPUT_FILE}'을(를) 찾을 수 없습니다.")
    exit()

# 16진수 → 10진수로 변환
try:
    pixels = np.array([int(x, 16) for x in hex_values], dtype=np.uint8)
except ValueError:
    print("오류: 파일에 16진수 형식이 아닌 값이 포함되어 있습니다.")
    exit()

# 전체 픽셀 수 확인
expected_pixels = IMG_W * IMG_H
if len(pixels) != expected_pixels:
    print(f"데이터 개수 불일치: {len(pixels)}개 (예상: {expected_pixels}개)")
    # assert False, f"데이터 개수 불일치: {len(pixels)}개"
else:
    print(f"정보: 픽셀 {len(pixels)}개 로드 완료.")


# 타일별로 재배열
image = np.zeros((IMG_H, IMG_W), dtype=np.uint8)

for tile_idx in range(TILE_W * TILE_H):
    # 현재 타일의 행/열 위치
    tile_y = tile_idx // TILE_W
    tile_x = tile_idx % TILE_W

    # 현재 타일의 시작 인덱스
    start = tile_idx * TILE_SIZE * TILE_SIZE
    end = start + TILE_SIZE * TILE_SIZE
    
    if end > len(pixels):
        print(f"오류: 마지막 타일 ({tile_idx}) 처리 중 데이터가 부족합니다.")
        break

    # 16x16 타일 픽셀 블록
    tile_pixels = pixels[start:end].reshape(TILE_SIZE, TILE_SIZE)

    # 전체 이미지에 배치
    image[
        tile_y * TILE_SIZE : (tile_y + 1) * TILE_SIZE,
        tile_x * TILE_SIZE : (tile_x + 1) * TILE_SIZE
    ] = tile_pixels

# --- ⭐ 수정: 이미지 파일로 저장 ---
# plt.show()를 호출하기 전에 저장하는 것이 좋습니다.
try:
    plt.imsave(OUTPUT_FILE, image, cmap='gray')
    print(f"✅ '{OUTPUT_FILE}' 파일로 저장 완료")
except Exception as e:
    print(f"오류: 이미지 파일 저장 중 문제 발생 - {e}")

# --- 이미지 표시 ---
plt.imshow(image, cmap='gray')
plt.title(f"Restored Image from {INPUT_FILE}")
plt.axis('off')
plt.show()
