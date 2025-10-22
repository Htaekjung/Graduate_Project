import numpy as np
import matplotlib.pyplot as plt

# ====== 설정 ======
input_txt = 'result.txt'   # 입력 txt 파일 경로
img_width, img_height = 640, 480  # 이미지 크기

# ====== 데이터 불러오기 ======
with open(input_txt, 'r') as f:
    raw_data = f.read().split()

# --- 데이터가 16진수인지 자동 감지 ---
def is_hex(s):
    try:
        int(s, 16)
        return True
    except ValueError:
        return False

if all(is_hex(x) for x in raw_data[:100]):  # 앞부분만 검사
    print("📘 입력 데이터 형식: 16진수")
    data = np.array([int(x, 16) for x in raw_data], dtype=np.uint8)
else:
    print("📘 입력 데이터 형식: 10진수")
    data = np.array([int(x) for x in raw_data], dtype=np.uint8)

# ====== 1D → 2D 변환 ======
img = data.reshape((img_height, img_width))

# ====== 이미지 표시 ======
plt.imshow(img, cmap='gray', vmin=0, vmax=255)
plt.axis('off')
plt.title("Restored Image (640×480)")
plt.show()

# ====== 이미지 파일로 저장 ======
plt.imsave('1.png', img, cmap='gray', vmin=0, vmax=255)
print("✅ 'restored_image.png' 파일로 저장 완료")
