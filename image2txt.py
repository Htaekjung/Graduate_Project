import numpy as np
from PIL import Image

# ====== 설정 ======
input_image = "scharr_edge_no_padding.png"   # 입력 이미지 파일명
output_txt = "trump_scharr.txt"    # 출력 txt 파일명
width, height = 640, 480    # 목표 해상도

# ====== 1. 이미지 불러오기 및 크기 조정 ======
img = Image.open(input_image).convert('L')  # 'L' = 8bit grayscale
img = img.resize((width, height))

# ====== 2. numpy 배열로 변환 ======
data = np.array(img, dtype=np.uint8)

# ====== 3. 8비트 16진수 문자열로 변환 ======
# 각 픽셀 값을 2자리 16진수(예: 00~FF)로 표현
hex_values = [f"{val:02X}" for val in data.flatten()]

# ====== 4. 한 줄에 16개씩 저장 (가독성용) ======
with open(output_txt, 'w') as f:
    for i in range(0, len(hex_values), 16):
        f.write(" ".join(hex_values[i:i+16]) + "\n")

print(f"✅ 변환 완료: '{output_txt}' 생성됨")
