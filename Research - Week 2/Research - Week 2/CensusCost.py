import numpy as np
from PIL import Image

def visualizeCensus(census_image, kernel, fileName):
    kernel_half = int(kernel / 2)

    h,w,d = census_image.shape
    print("\n",h,w,d)

    # Depth (or disparity) map
    image = np.zeros((h, w), np.uint8)

    for y in range(kernel_half, h - kernel_half):
        for x in range(kernel_half, w - kernel_half):
            sum = 0
            for c in range(0,kernel*kernel-1):
                value = census_image[y,x,c]
                if(value == 1):
                    sum = sum + pow(2,c)
            # print(x,y,sum,"\n")
            image[y,x] = sum


    # maxval = np.amax(image)
    # image = int(255/maxval)*image

    Image.fromarray(image).save(fileName)


def computeCensus(left_img, right_img, kernel):
    # Load in both images, assumed to be RGBA 8bit per channel images
    left_img = Image.open(left_img).convert('L')
    left = np.asarray(left_img)
    right_img = Image.open(right_img).convert('L')
    right = np.asarray(right_img)
    w, h = left_img.size  # assume that both images are same size

    kernel_half = int(kernel / 2)
    shape = (h, w, kernel*kernel-1)

    # print(shape)
    left_census = np.zeros(shape)
    right_census = np.zeros(shape)

    for y in range(kernel_half, h - kernel_half):
        print("\rProcessing.. %d%% complete" % (y / (h - kernel_half) * 100), end="", flush=True)

        for x in range(kernel_half, w - kernel_half):

            index = 0
            for v in range(-kernel_half, kernel_half+1):
                for u in range(-kernel_half, kernel_half+1):
                    if (not (v == 0 and u == 0)):

                        if (int(left[y + v, x + u]) >= int(left[y + 0, x + 0])):
                            left_census[y,x,index] = 1
                        else:
                            left_census[y, x, index] = 0

                        if (int(right[y + v, (x + u)]) >= int(right[y + 0, (x + 0)])):
                            right_census[y,x,index] = 1
                        else:
                            right_census[y, x, index] = 0

                        index = index + 1




    return left_census, right_census


def stereo_match(left_census, right_census, kernel, max_offset):
    h, w, d = left_census.shape

    # Depth (or disparity) map
    depth = np.zeros((w, h), np.uint8)
    depth.shape = h, w

    kernel_half = int(kernel / 2)
    offset_adjust = 255 / max_offset  # this is used to map depth map output to 0-255 range


    for y in range(kernel_half, h - kernel_half):
        print("\rProcessing.. %d%% complete" % (y / (h - kernel_half) * 100), end="", flush=True)

        for x in range(kernel_half, w - kernel_half):
            best_offset = 0
            prev_ssd = 65534

            for offset in range(max_offset):
                ssd = 0
                ssd_temp = 0

                # v and u are the x,y of our local window search, used to ensure a good match
                # because the squared differences of two pixels alone is not enough ot go on

                sumHammingDistance = 0
                for v in range(-kernel_half, kernel_half+1):
                    for u in range(-kernel_half, kernel_half+1):

                        hammdingDistance = 0
                        for c in range(0, 8):
                            leftValue = left_census[y+v,x+u,c]
                            rightValue = right_census[y + v, x + u-offset, c]
                            if(leftValue != rightValue):
                                hammdingDistance = hammdingDistance + 1

                        sumHammingDistance += hammdingDistance

                
                ssd = sumHammingDistance
                if ssd < prev_ssd:
                    prev_ssd = ssd
                    best_offset = offset

            # set depth output for this x,y location to the best match
            depth[y, x] = best_offset * 8

    # Convert to PIL and save it
    Image.fromarray(depth).save('hamming_disparity.png')

if __name__ == '__main__':
    left_census, right_census = computeCensus("view1_d.png", "view5_d.png", 3)
    visualizeCensus(left_census, 3, "left_census.png")
    visualizeCensus(right_census, 3, "right_census.png")
    stereo_match(left_census,right_census,5, 32)
