import matplotlib.pyplot as plt
import numpy as np
from skimage.io import imread
from skimage import data, color
from skimage.transform import hough_circle
from skimage.feature import peak_local_max, canny
from skimage.draw import circle_perimeter
from skimage.util import *


image = img_as_ubyte(color.rgb2gray(imread("F:\_cercetare\segmentare\C1_S1_I7.tiff")))
# Compute the Canny filter for two values of sigma
edges = canny(image, sigma=3, low_threshold=5, high_threshold=50)



# Detect two radii
hough_radii = np.arange(20, 400, 20)
hough_res = hough_circle(edges, hough_radii)

centers = []
accums = []
radii = []

for radius, h in zip(hough_radii, hough_res):
    # For each radius, extract two circles
    num_peaks = 2
    peaks = peak_local_max(h, num_peaks=num_peaks)
    centers.extend(peaks)
    accums.extend(h[peaks[:, 0], peaks[:, 1]])
    radii.extend([radius] * num_peaks)

# Draw the most prominent 5 circles
image = color.gray2rgb(image)
for idx in np.argsort(accums)[::-1][:1]:
    center_x, center_y = centers[idx]
    radius = radii[idx]
    cx, cy = circle_perimeter(center_y, center_x, radius)
    image[cy, cx] = (220, 20, 20)

# display results
fig, (ax1, ax2) = plt.subplots(nrows=1, ncols=2, figsize=(8, 3), sharex=True, sharey=True)

ax1.imshow(edges, cmap=plt.cm.gray)
ax1.axis('off')
ax1.set_title('canny', fontsize=20)

ax2.imshow(image, cmap=plt.cm.jet)
ax2.axis('off')
ax2.set_title('iris detect', fontsize=20)

fig.subplots_adjust(wspace=0.02, hspace=0.02, top=0.9,
                    bottom=0.02, left=0.02, right=0.98)

plt.show()