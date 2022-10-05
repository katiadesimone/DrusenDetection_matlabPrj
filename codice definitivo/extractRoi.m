function maskedImage = extractRoi(mask,grayImage)
maskedImage = grayImage; % Initialize with the entire image.
maskedImage(~mask) = 0; % Zero image outside the circle mask.

props = regionprops(mask, 'BoundingBox');
maskedImage = imcrop(maskedImage, props.BoundingBox);