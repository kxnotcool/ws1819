
using Images  # Basic image processing functions
using PyPlot  # Plotting and image loading
using FileIO  # Functions for loading and storing data in the ".jld2" format


# Load the image from the provided .jld2 file
function loaddata()
  data = load("imagedata.jld2", "data")
  return data::Array{Float64,2}
end


# Separate the image data into three images (one for each color channel),
# filling up all unknown values with 0
function separatechannels(data::Array{Float64,2})
  r = Array{Float64,2}(undef, 480, 320)
  g = Array{Float64,2}(undef, 480, 320)
  b = Array{Float64,2}(undef, 480, 320)
  for i = 1:480
    for j = 1:320
      if i%2!=0
        if j%2!=0
          r[i,j] = data[i,j]
          g[i,j] = 0
          b[i,j] = 0
        else
          r[i,j] = 0
          g[i,j] = data[i,j]
          b[i,j] = 0
        end
      else
        if j%2!=0
          r[i,j] = 0
          g[i,j] = 0
          b[i,j] = data[i,j]
        else
          r[i,j] = data[i,j]
          g[i,j] = 0
          b[i,j] = 0
        end
      end
    end
  end
  return r::Array{Float64,2},g::Array{Float64,2},b::Array{Float64,2}
end


# Combine three color channels into a single image
function makeimage(r::Array{Float64,2},g::Array{Float64,2},b::Array{Float64,2})
  imgSize = size(r)
  image = Array{Float64,3}(undef, imgSize[1], imgSize[2], 3)
  image[:,:,1] = r[:,:]
  image[:,:,2] = g[:,:]
  image[:,:,3] = b[:,:]
  return image::Array{Float64,3}
end


# Interpolate missing color values using bilinear interpolation
function interpolate(r::Array{Float64,2},g::Array{Float64,2},b::Array{Float64,2})
  ralt = zeros(Float64, size(r)[1]+2,size(r)[2]+2)
  galt = zeros(Float64, size(r)[1]+2,size(r)[2]+2)
  balt = zeros(Float64, size(r)[1]+2,size(r)[2]+2)

  image = Array{Float64, 3}(undef, size(r)[1], size(r)[2], 3)
  image[:,:,1] = r[:,:]
  image[:,:,2] = g[:,:]
  image[:,:,3] = b[:,:]
  colmnSize = size(ralt)[2]
  rowSize = size(ralt)[1]
  ralt[2:rowSize-1, 2:colmnSize-1] = r
  galt[2:rowSize-1, 2:colmnSize-1] = g
  balt[2:rowSize-1, 2:colmnSize-1] = b
  for i=1:2:rowSize-2
    n=i+1
    for j=1:2:colmnSize-2
      m=j+1
      image[i, j, 2] = (galt[n, m-1] + galt[n, m+1])/2
      image[i, j, 3] = (balt[n-1, m] + balt[n+1, m])/2
    #  image[i+1, j, 1] = (ralt[n-1, m] + ralt[n+1, m] + ralt[n, m-1] + ralt[n, m+1])/4
    #  image[i+1, j, 2] = (galt[n-1, m-1] + galt[n-1, m+1] + galt[n+1, m-1] + galt[n+1, m+1])/4
      image[i, j+1, 1] = (ralt[n-1, m+1] + ralt[n+1, m+1] + ralt[n, m] + ralt[n, m+2])/4
      image[i, j+1, 3] = (balt[n-1, m] + balt[n-1, m+2] + balt[n+1, m] + balt[n+1, m+2])/4
      image[i+1, j+1, 2] = (galt[n+2, m+1] + galt[n, m+1])/2
      image[i+1, j+1, 3] = (balt[n+1, m] + balt[n+1, m+2])/2
    end
  end

  return image::Array{Float64,3}
end


# Display two images in a single figure window
function displayimages(img1::Array{Float64,3}, img2::Array{Float64,3})
  fig, (ax1, ax2) = PyPlot.subplots(1,2)
  PyPlot.subplot(ax1)
  PyPlot.imshow(img1)
  PyPlot.subplot(ax2)
  PyPlot.imshow(img2)
  gcf()


end

#= Problem 2
Bayer Interpolation =#

function problem2()
  # load raw data
  data = loaddata()
  # separate data
  r,g,b = separatechannels(data)
  # merge raw pattern
  img1 = makeimage(r,g,b)
  # interpolate
  img2 = interpolate(r,g,b)
  # display images
  displayimages(img1, img2)
  
end
